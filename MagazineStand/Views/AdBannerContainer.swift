import SwiftUI
import GoogleMobileAds

struct AdBannerContainer: View {
    @State private var isReady = false

    var body: some View {
        Group {
            if isReady {
                BannerAdRepresentable()
                    .frame(height: 50)
            } else {
                Color.clear.frame(height: 50)
            }
        }
        .task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            isReady = true
        }
    }
}

private struct BannerAdRepresentable: UIViewRepresentable {
    // TODO: Replace with real ad unit ID after AdMob app registration
    private let adUnitID = "ca-app-pub-9404799280370656/PLACEHOLDER"

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIView(context: Context) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        return container
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        guard !context.coordinator.didLoad else { return }
        guard let rootVC = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })?
            .keyWindow?
            .rootViewController else { return }

        let banner = BannerView(adSize: AdSizeBanner)
        banner.adUnitID = adUnitID
        banner.rootViewController = rootVC
        banner.translatesAutoresizingMaskIntoConstraints = false
        uiView.addSubview(banner)
        NSLayoutConstraint.activate([
            banner.centerXAnchor.constraint(equalTo: uiView.centerXAnchor),
            banner.centerYAnchor.constraint(equalTo: uiView.centerYAnchor)
        ])
        banner.load(Request())
        context.coordinator.didLoad = true
    }

    final class Coordinator {
        var didLoad = false
    }
}
