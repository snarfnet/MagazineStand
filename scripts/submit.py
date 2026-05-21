#!/usr/bin/env python3
"""Upload IPA and submit for App Store review."""
import subprocess, sys, time, json, jwt, requests, os, glob

APP_ID = "6771264388"
BUNDLE_ID = "com.tokyonasu.MagazineStand"
KEY_PATH = "/tmp/asc_key.p8"
KEY_ID = "WDXGY9WX55"
ISSUER = "2be0734f-943a-4d61-9dc9-5d9045c46fec"

build_number = sys.argv[1] if len(sys.argv) > 1 else None

# Upload IPA (skip if destination=upload already handled it)
ipa = glob.glob("build/export/*.ipa")
if ipa:
    print(f"Uploading {ipa[0]}...")
    r = subprocess.run([
        "xcrun", "altool", "--upload-app",
        "-f", ipa[0], "--type", "ios",
        "--apiKey", KEY_ID, "--apiIssuer", ISSUER
    ], capture_output=True, text=True)
    print(r.stdout)
    if r.returncode != 0:
        print(r.stderr)
else:
    print("No local IPA (uploaded via export step)")

def get_token():
    with open(KEY_PATH) as f:
        key = f.read()
    now = int(time.time())
    return jwt.encode(
        {"iss": ISSUER, "iat": now, "exp": now + 1200, "aud": "appstoreconnect-v1"},
        key, algorithm="ES256", headers={"kid": KEY_ID}
    )

def api(method, path, json_data=None):
    h = {"Authorization": f"Bearer {get_token()}", "Content-Type": "application/json"}
    url = f"https://api.appstoreconnect.apple.com/v1/{path}"
    r = getattr(requests, method)(url, headers=h, json=json_data)
    return r

# Wait for build processing
print("Waiting for build processing...")
for attempt in range(40):
    time.sleep(15)
    r = api("get", f"builds?filter[app]={APP_ID}&sort=-uploadedDate&limit=1")
    data = r.json().get("data", [])
    if not data:
        continue
    build = data[0]
    state = build["attributes"].get("processingState", "")
    ver = build["attributes"].get("version", "")
    print(f"  Build {ver}: {state}")
    if state == "VALID":
        break
else:
    print("Timed out waiting for build")
    sys.exit(1)

build_id = build["id"]

# Set encryption
api("patch", f"builds/{build_id}", {
    "data": {"type": "builds", "id": build_id, "attributes": {"usesNonExemptEncryption": False}}
})
print(f"Encryption set for build {build_id}")

# Get app store version
r = api("get", f"apps/{APP_ID}/appStoreVersions?filter[appStoreState]=REJECTED,DEVELOPER_REJECTED,PREPARE_FOR_SUBMISSION,READY_FOR_REVIEW&limit=1")
versions = r.json().get("data", [])
if not versions:
    r = api("get", f"apps/{APP_ID}/appStoreVersions?limit=1")
    versions = r.json().get("data", [])
asv = versions[0]
asv_id = asv["id"]
print(f"Version: {asv_id} state={asv['attributes']['appStoreState']}")

# Assign build
api("patch", f"appStoreVersions/{asv_id}/relationships/build", {
    "data": {"type": "builds", "id": build_id}
})
print("Build assigned to version")

# Submit for review
r = api("get", f"reviewSubmissions?filter[app]={APP_ID}&filter[state]=UNRESOLVED_ISSUES,WAITING_FOR_REVIEW,IN_REVIEW")
subs = r.json().get("data", [])
if subs:
    sub = subs[0]
    sub_id = sub["id"]
    state = sub["attributes"]["state"]
    print(f"Existing submission: {sub_id} state={state}")
    if state == "UNRESOLVED_ISSUES":
        r2 = api("get", f"reviewSubmissions/{sub_id}/items")
        for item in r2.json().get("data", []):
            api("patch", f"reviewSubmissionItems/{item['id']}", {
                "data": {"type": "reviewSubmissionItems", "id": item["id"], "attributes": {"resolved": True}}
            })
        api("patch", f"reviewSubmissions/{sub_id}", {
            "data": {"type": "reviewSubmissions", "id": sub_id, "attributes": {"submitted": True}}
        })
        print("Submitted via existing submission")
    else:
        print("Already in review")
else:
    r = api("post", "reviewSubmissions", {
        "data": {"type": "reviewSubmissions", "attributes": {"platform": "IOS"},
                 "relationships": {"app": {"data": {"type": "apps", "id": APP_ID}}}}
    })
    sub = r.json()["data"]
    sub_id = sub["id"]
    api("post", "reviewSubmissionItems", {
        "data": {"type": "reviewSubmissionItems",
                 "relationships": {
                     "reviewSubmission": {"data": {"type": "reviewSubmissions", "id": sub_id}},
                     "appStoreVersion": {"data": {"type": "appStoreVersions", "id": asv_id}}
                 }}
    })
    api("patch", f"reviewSubmissions/{sub_id}", {
        "data": {"type": "reviewSubmissions", "id": sub_id, "attributes": {"submitted": True}}
    })
    print("Created new submission and submitted")

print("Done!")
