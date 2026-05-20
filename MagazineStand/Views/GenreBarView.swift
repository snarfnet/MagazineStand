import SwiftUI

struct GenreBarView: View {
    @Binding var selectedGenre: MagazineGenre
    let onSelect: (MagazineGenre) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(MagazineGenre.all) { genre in
                    GenreChip(
                        genre: genre,
                        isSelected: genre.id == selectedGenre.id
                    ) {
                        onSelect(genre)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .background(Kiosk.woodDark.opacity(0.95))
    }
}

private struct GenreChip: View {
    let genre: MagazineGenre
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: genre.icon)
                    .font(.system(size: 11, weight: .bold))
                Text(genre.name)
                    .font(.system(size: 12, weight: .bold, design: .rounded))
            }
            .foregroundColor(isSelected ? .white : Kiosk.cream.opacity(0.7))
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(isSelected ? Kiosk.redAwning : Kiosk.woodMid)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(isSelected ? Kiosk.yellowPrice.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}
