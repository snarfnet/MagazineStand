import SwiftUI

struct MagazineCoverView: View {
    let magazine: Magazine

    var body: some View {
        VStack(spacing: 6) {
            // Cover image
            AsyncImage(url: magazine.coverURL) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: coverWidth, height: coverHeight)
                        .clipped()
                case .failure:
                    placeholder
                default:
                    placeholder
                        .overlay(ProgressView().tint(Kiosk.cream))
                }
            }
            .frame(width: coverWidth, height: coverHeight)
            .background(Kiosk.metalDark)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: 4, x: 2, y: 3)
            // "NEW" badge
            .overlay(alignment: .topLeading) {
                if magazine.isNewRelease {
                    Text("NEW")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Kiosk.redAwning)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .offset(x: -3, y: -3)
                }
            }

            // Title
            Text(magazine.title)
                .font(.system(size: 11, weight: .bold, design: .rounded))
                .foregroundColor(Kiosk.cream)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: coverWidth)
                .frame(minHeight: 30)

            // Date & Price
            HStack(spacing: 4) {
                Text(magazine.displayDate)
                    .font(.system(size: 9, weight: .semibold, design: .monospaced))
                    .foregroundColor(Kiosk.yellowPrice)

                if magazine.itemPrice > 0 {
                    Text(magazine.formattedPrice)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(Kiosk.cream.opacity(0.7))
                }
            }
        }
        .padding(.vertical, 6)
    }

    private var coverWidth: CGFloat { 105 }
    private var coverHeight: CGFloat { 148 }

    private var placeholder: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [Kiosk.metalDark, Kiosk.metalGray.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: coverWidth, height: coverHeight)
            .overlay(
                Image(systemName: "magazine")
                    .font(.system(size: 28))
                    .foregroundColor(Kiosk.cream.opacity(0.3))
            )
    }
}
