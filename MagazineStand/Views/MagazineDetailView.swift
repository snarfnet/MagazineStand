import SwiftUI

struct MagazineDetailView: View {
    let magazine: Magazine
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Cover
                AsyncImage(url: magazine.coverURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 320)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Kiosk.metalDark)
                            .frame(height: 320)
                            .overlay(
                                Image(systemName: "magazine")
                                    .font(.system(size: 48))
                                    .foregroundColor(Kiosk.cream.opacity(0.3))
                            )
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(color: .black.opacity(0.6), radius: 12, y: 8)
                .padding(.top, 12)

                // Info card
                VStack(alignment: .leading, spacing: 14) {
                    Text(magazine.title)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(Kiosk.ink)

                    Divider()

                    infoRow(icon: "building.2", label: "出版社", value: magazine.publisherName)
                    infoRow(icon: "calendar", label: "発売日", value: magazine.salesDate)
                    infoRow(icon: "yensign.circle", label: "価格", value: magazine.formattedPrice)

                    if !magazine.cycle.isEmpty {
                        infoRow(icon: "arrow.clockwise", label: "発行", value: magazine.cycle)
                    }

                    if !magazine.itemCaption.isEmpty {
                        Divider()
                        Text(magazine.itemCaption)
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(Kiosk.ink.opacity(0.8))
                            .lineSpacing(4)
                    }
                }
                .padding(18)
                .background(Kiosk.warmWhite)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.2), radius: 8, y: 4)

                // Purchase button
                if let url = magazine.purchaseURL {
                    Link(destination: url) {
                        HStack(spacing: 8) {
                            Image(systemName: "cart")
                                .font(.system(size: 15, weight: .bold))
                            Text("楽天ブックスで見る")
                                .font(.system(size: 15, weight: .bold, design: .rounded))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Kiosk.redAwning)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Kiosk.redAwning.opacity(0.4), radius: 8, y: 4)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 24)
        }
        .background(
            LinearGradient(
                colors: [Kiosk.woodDark, Color(red: 0.14, green: 0.09, blue: 0.05)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Kiosk.woodDark, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Kiosk.redAwning)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Kiosk.ink.opacity(0.5))
                .frame(width: 50, alignment: .leading)
            Text(value)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Kiosk.ink)
        }
    }
}
