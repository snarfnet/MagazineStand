import SwiftUI

struct MagazineDetailView: View {
    let magazine: Magazine

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                hero
                infoPanel

                if let url = magazine.purchaseURL {
                    Link(destination: url) {
                        Label("楽天ブックスで見る", systemImage: "cart.fill")
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Kiosk.neonRed, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .shadow(color: Kiosk.neonRed.opacity(0.35), radius: 14, y: 7)
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 24)
        }
        .background(Kiosk.screenBackground.ignoresSafeArea())
        .navigationTitle("雑誌詳細")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Kiosk.ink, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Kiosk.heroGlow)
                .overlay(Kiosk.halftone(color: .white.opacity(0.10)))

            VStack(spacing: 14) {
                AsyncImage(url: magazine.coverURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else {
                        MagazineCoverView(magazine: magazine)
                    }
                }
                .frame(maxWidth: 220, maxHeight: 320)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .shadow(color: .black.opacity(0.55), radius: 16, y: 10)

                VStack(spacing: 7) {
                    Text(magazine.title)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                        .minimumScaleFactor(0.68)

                    Text(magazine.publisherName)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.68))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var infoPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                InfoTile(title: "発売", value: magazine.displayDate)
                InfoTile(title: "価格", value: magazine.formattedPrice)
                InfoTile(title: "刊行", value: magazine.cycle.isEmpty ? "雑誌" : magazine.cycle)
            }

            if !magazine.itemCaption.isEmpty {
                Text("内容")
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .tracking(1.4)
                    .foregroundStyle(Kiosk.gold)
                Text(magazine.itemCaption)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .lineSpacing(5)
                    .foregroundStyle(Kiosk.paper.opacity(0.84))
            }

            DetailRow(icon: "barcode", label: "JAN", value: magazine.jan)
            DetailRow(icon: "building.2.fill", label: "出版社", value: magazine.publisherName)
        }
        .padding(16)
        .glassPanel()
    }
}

private struct InfoTile: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(Kiosk.paper.opacity(0.50))
            Text(value)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(Kiosk.paper)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.black.opacity(0.20), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(Kiosk.signalCyan)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(Kiosk.paper.opacity(0.50))
                .frame(width: 54, alignment: .leading)
            Text(value.isEmpty ? "-" : value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Kiosk.paper.opacity(0.82))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
        }
    }
}
