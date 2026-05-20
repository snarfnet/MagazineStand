import SwiftUI

struct MagazineCoverView: View {
    let magazine: Magazine
    var compact = false

    var body: some View {
        VStack(spacing: 7) {
            cover
            Text(magazine.title)
                .font(.system(size: compact ? 10 : 11, weight: .heavy, design: .rounded))
                .foregroundStyle(Kiosk.paper)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: coverWidth)
                .frame(minHeight: compact ? 26 : 32, alignment: .top)

            HStack(spacing: 5) {
                Text(magazine.displayDate)
                    .foregroundStyle(Kiosk.gold)
                Text(magazine.formattedPrice)
                    .foregroundStyle(Kiosk.paper.opacity(0.66))
            }
            .font(.system(size: 9, weight: .bold, design: .monospaced))
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(width: coverWidth)
        }
        .padding(.vertical, 7)
    }

    private var cover: some View {
        AsyncImage(url: magazine.coverURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            case .failure:
                placeholder
            default:
                placeholder
                    .overlay {
                        ProgressView()
                            .tint(Kiosk.gold)
                    }
            }
        }
        .frame(width: coverWidth, height: coverHeight)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay(alignment: .topLeading) {
            Text(magazine.releaseStatus)
                .font(.system(size: 9, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(badgeColor, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
                .padding(5)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .stroke(.white.opacity(0.16), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.55), radius: 9, x: 3, y: 8)
    }

    private var placeholder: some View {
        ZStack {
            LinearGradient(colors: Kiosk.palette(for: magazine.id), startPoint: .topLeading, endPoint: .bottomTrailing)
            Kiosk.halftone(color: .white.opacity(0.13))
            VStack(alignment: .leading, spacing: 8) {
                Text(magazine.publisherName.isEmpty ? "MAG" : magazine.publisherName.uppercased())
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.76))
                    .lineLimit(1)
                Spacer()
                Text(magazine.title)
                    .font(.system(size: compact ? 16 : 18, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(4)
                    .minimumScaleFactor(0.62)
                Rectangle()
                    .fill(.white.opacity(0.82))
                    .frame(height: 4)
                Rectangle()
                    .fill(.white.opacity(0.62))
                    .frame(width: coverWidth * 0.62, height: 4)
            }
            .padding(12)
        }
    }

    private var badgeColor: Color {
        magazine.isUpcoming ? Kiosk.signalCyan : Kiosk.neonRed
    }

    private var coverWidth: CGFloat { compact ? 92 : 108 }
    private var coverHeight: CGFloat { compact ? 130 : 154 }
}
