from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter


ROOT = Path(__file__).resolve().parents[1]
ICON = ROOT / "MagazineStand" / "Assets.xcassets" / "AppIcon.appiconset" / "icon_1024.png"
W, H = 1290, 2796

INK = (12, 14, 17)
ASPHALT = (22, 26, 30)
STEEL = (56, 64, 70)
STEEL_DARK = (32, 37, 42)
PAPER = (246, 231, 202)
MUTED = (176, 164, 142)
RED = (178, 30, 24)
YELLOW = (244, 174, 34)
CYAN = (42, 158, 188)
WHITE = (255, 255, 255)


def font(size, bold=False):
    candidates = [
        r"C:\Windows\Fonts\YuGothB.ttc" if bold else r"C:\Windows\Fonts\YuGothM.ttc",
        r"C:\Windows\Fonts\meiryob.ttc" if bold else r"C:\Windows\Fonts\meiryo.ttc",
        r"C:\Windows\Fonts\msgothic.ttc",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            pass
    return ImageFont.load_default()


F = {
    "kicker": font(26, True),
    "hero": font(86, True),
    "title": font(58, True),
    "md": font(38, True),
    "body": font(31, False),
    "small": font(24, True),
    "tiny": font(20, True),
}


def text(draw, xy, value, key, fill=WHITE, anchor=None, align="left"):
    draw.multiline_text(xy, value, font=F[key], fill=fill, spacing=8, anchor=anchor, align=align)


def rounded(draw, box, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(box, radius=radius, fill=fill, outline=outline, width=width)


def gradient_bg():
    img = Image.new("RGB", (W, H), INK)
    draw = ImageDraw.Draw(img)
    for y in range(H):
        mix = y / H
        r = int(12 * (1 - mix) + 34 * mix)
        g = int(14 * (1 - mix) + 29 * mix)
        b = int(17 * (1 - mix) + 24 * mix)
        draw.line((0, y, W, y), fill=(r, g, b))
    for x in range(-200, W, 120):
        draw.line((x, 0, x + 620, H), fill=(30, 34, 38), width=5)
    return img


def top_awning(draw):
    stripe_w = W // 9
    for i in range(10):
        fill = RED if i % 2 == 0 else PAPER
        draw.rectangle((i * stripe_w, 0, (i + 1) * stripe_w, 92), fill=fill)
    draw.rectangle((0, 92, W, 106), fill=(80, 24, 18))


def app_title(draw, subtitle):
    text(draw, (92, 150), "MAGAZINE STAND", "kicker", YELLOW)
    text(draw, (92, 195), "マガジン\nスタンド", "hero", WHITE)
    text(draw, (96, 405), subtitle, "body", MUTED)


def cover(draw, x, y, w, h, title, colors, badge=None):
    top, bottom = colors
    for i in range(h):
        mix = i / max(1, h - 1)
        fill = tuple(int(top[j] * (1 - mix) + bottom[j] * mix) for j in range(3))
        draw.line((x, y + i, x + w, y + i), fill=fill)
    rounded(draw, (x, y, x + w, y + h), 18, fill=None, outline=(255, 255, 255), width=2)
    for yy in range(y + 38, y + 104, 18):
        draw.rectangle((x + 26, yy, x + w - 26, yy + 7), fill=(255, 255, 255))
    title_key = "small" if w < 130 else "md"
    title_y = y + h - (92 if w < 130 else 126)
    text(draw, (x + 25, title_y), title, title_key, WHITE)
    if badge:
        rounded(draw, (x + 18, y + 18, x + 120, y + 54), 10, RED)
        text(draw, (x + 35, y + 23), badge, "tiny", WHITE)


def phone_frame(img, x, y, w, h):
    draw = ImageDraw.Draw(img)
    rounded(draw, (x, y, x + w, y + h), 72, (7, 8, 10), (98, 104, 106), 4)
    rounded(draw, (x + 18, y + 18, x + w - 18, y + h - 18), 56, ASPHALT)
    return (x + 34, y + 42, w - 68, h - 84)


def draw_home_ui(draw, box):
    x, y, w, h = box
    rounded(draw, (x, y, x + w, y + h), 48, ASPHALT)
    for i in range(8):
        draw.rectangle((x + i * w / 8, y, x + (i + 1) * w / 8, y + 46), fill=RED if i % 2 == 0 else PAPER)
    text(draw, (x + 42, y + 85), "マガジンスタンド", "md", WHITE)
    text(draw, (x + 42, y + 135), "TODAY'S FRONT RACK", "tiny", YELLOW)
    rounded(draw, (x + 42, y + 190, x + w - 42, y + 500), 22, (60, 57, 47), (100, 104, 105), 2)
    cover(draw, x + 70, y + 224, 160, 226, "TOKYO\nFILE", (RED, (45, 15, 12)), "NEW")
    text(draw, (x + 260, y + 230), "今日の新刊を\n一気にチェック", "md", WHITE)
    text(draw, (x + 264, y + 335), "発売日順の棚で、\n気になる雑誌を\nすぐ見つけられます。", "small", MUTED)
    shelf_y = y + 600
    for row in range(3):
        draw.rounded_rectangle((x + 42, shelf_y + row * 310, x + w - 42, shelf_y + row * 310 + 12), radius=6, fill=(110, 111, 104))
        for col in range(3):
            cx = x + 70 + col * 178
            cy = shelf_y + row * 310 + 28
            palette = [(RED, (46, 16, 12)), (CYAN, (12, 42, 50)), (YELLOW, (68, 43, 8)), ((96, 75, 180), (24, 18, 46)), ((38, 150, 92), (10, 45, 26)), ((220, 96, 40), (50, 20, 8))][(row * 3 + col) % 6]
            cover(draw, cx, cy, 128, 182, "MAG", palette)


def draw_search_ui(draw, box):
    x, y, w, h = box
    rounded(draw, (x, y, x + w, y + h), 48, ASPHALT)
    text(draw, (x + 42, y + 80), "ジャンルで探す", "md", WHITE)
    rounded(draw, (x + 42, y + 150, x + w - 42, y + 210), 20, (38, 43, 48), (95, 104, 108), 2)
    text(draw, (x + 75, y + 166), "雑誌名で検索", "small", MUTED)
    genres = ["ニュース", "グルメ", "PC・IT", "コミック", "音楽", "車・バイク"]
    for i, genre in enumerate(genres):
        gx = x + 42 + (i % 2) * 250
        gy = y + 270 + (i // 2) * 92
        fill = YELLOW if i == 0 else (38, 43, 48)
        fg = INK if i == 0 else WHITE
        rounded(draw, (gx, gy, gx + 220, gy + 64), 24, fill)
        text(draw, (gx + 28, gy + 16), genre, "small", fg)
    text(draw, (x + 42, y + 600), "ニュースの新着", "md", WHITE)
    for i in range(3):
        yy = y + 680 + i * 230
        rounded(draw, (x + 42, yy, x + w - 42, yy + 184), 20, (31, 36, 41), (80, 86, 90), 2)
        cover(draw, x + 68, yy + 22, 98, 138, ["CITY", "WEEK", "EDGE"][i], [(CYAN, (12, 42, 50)), (RED, (46, 16, 12)), (YELLOW, (68, 43, 8))][i])
        text(draw, (x + 190, yy + 32), ["NYストリート特集", "今週のカルチャー", "ビジネス最前線"][i], "small", WHITE)
        text(draw, (x + 190, yy + 82), "発売日・価格・出版社をまとめて確認。", "tiny", MUTED)


def draw_detail_ui(draw, box):
    x, y, w, h = box
    rounded(draw, (x, y, x + w, y + h), 48, ASPHALT)
    rounded(draw, (x + 44, y + 78, x + w - 44, y + 560), 24, (60, 57, 47), (110, 112, 108), 2)
    cover(draw, x + 205, y + 118, 210, 300, "CITY\nFILE", (RED, (46, 16, 12)), "NEW")
    text(draw, (x + 82, y + 620), "雑誌詳細", "md", WHITE)
    text(draw, (x + 82, y + 680), "表紙、発売日、価格、出版社を一画面で確認できます。", "small", MUTED)
    labels = [("発売", "5/20"), ("価格", "¥780"), ("刊行", "月刊")]
    for i, (label, value) in enumerate(labels):
        bx = x + 42 + i * 174
        rounded(draw, (bx, y + 820, bx + 150, y + 930), 18, (31, 36, 41))
        text(draw, (bx + 22, y + 842), label, "tiny", MUTED)
        text(draw, (bx + 22, y + 878), value, "small", WHITE)
    rounded(draw, (x + 42, y + 1010, x + w - 42, y + 1140), 22, RED)
    text(draw, (x + 170, y + 1052), "楽天ブックスで見る", "small", WHITE)


def place_icon(img):
    icon = Image.open(ICON).convert("RGB").resize((340, 340), Image.Resampling.LANCZOS)
    mask = Image.new("L", icon.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, 340, 340), radius=72, fill=255)
    shadow = Image.new("RGBA", (420, 420), (0, 0, 0, 0))
    ImageDraw.Draw(shadow).rounded_rectangle((40, 40, 380, 380), radius=78, fill=(0, 0, 0, 150))
    shadow = shadow.filter(ImageFilter.GaussianBlur(18))
    img.paste(shadow.convert("RGB"), (W - 470, 132), shadow)
    img.paste(icon, (W - 430, 160), mask)


def save_home():
    img = gradient_bg()
    draw = ImageDraw.Draw(img)
    top_awning(draw)
    app_title(draw, "NYのニューススタンドみたいに、\n新刊雑誌を気持ちよく眺める。")
    place_icon(img)
    box = phone_frame(img, 310, 735, 670, 1720)
    draw_home_ui(draw, box)
    img.save(ROOT / "ss_1.png", quality=95)


def save_search():
    img = gradient_bg()
    draw = ImageDraw.Draw(img)
    top_awning(draw)
    app_title(draw, "ジャンルで絞る。\n気になる一冊へすぐ行ける。")
    box = phone_frame(img, 310, 735, 670, 1720)
    draw_search_ui(draw, box)
    img.save(ROOT / "ss_2.png", quality=95)


def save_detail():
    img = gradient_bg()
    draw = ImageDraw.Draw(img)
    top_awning(draw)
    app_title(draw, "表紙から詳細まで、\n買う前にサッと確認。")
    box = phone_frame(img, 310, 735, 670, 1720)
    draw_detail_ui(draw, box)
    img.save(ROOT / "ss_3.png", quality=95)


save_home()
save_search()
save_detail()
print(ROOT / "ss_1.png")
print(ROOT / "ss_2.png")
print(ROOT / "ss_3.png")
