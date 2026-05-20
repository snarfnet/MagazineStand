import SwiftUI

struct GenreBarView: View {
    @Binding var selectedGenre: MagazineGenre
    let onSelect: (MagazineGenre) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                ForEach(MagazineGenre.all) { genre in
                    GenreChip(
                        genre: genre,
                        isSelected: genre == selectedGenre
                    ) {
                        onSelect(genre)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
        .background(Kiosk.ink.opacity(0.94))
        .overlay(alignment: .bottom) {
            Kiosk.shelfRail(height: 5)
        }
    }
}

private struct GenreChip: View {
    let genre: MagazineGenre
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: genre.icon)
                    .font(.system(size: 12, weight: .black))
                Text(genre.name)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
            }
            .foregroundStyle(isSelected ? Kiosk.ink : Kiosk.paper.opacity(0.74))
            .padding(.horizontal, 13)
            .frame(height: 34)
            .background {
                Capsule()
                    .fill(isSelected ? Kiosk.gold : .white.opacity(0.08))
            }
            .overlay {
                Capsule()
                    .stroke(isSelected ? .white.opacity(0.35) : .white.opacity(0.10), lineWidth: 1)
            }
            .shadow(color: isSelected ? Kiosk.gold.opacity(0.32) : .clear, radius: 10, y: 4)
        }
        .buttonStyle(.plain)
    }
}
