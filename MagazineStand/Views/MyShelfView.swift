import SwiftUI

struct MyShelfView: View {
    @ObservedObject var favoritesManager = FavoritesManager.shared

    private let columns = [
        GridItem(.adaptive(minimum: 104, maximum: 126), spacing: 8)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                shelfHeader

                if favoritesManager.favorites.isEmpty {
                    emptyState
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 10) {
                            HStack {
                                Label("\(favoritesManager.favorites.count)冊", systemImage: "bookmark.fill")
                                    .font(.system(size: 15, weight: .black, design: .rounded))
                                    .foregroundStyle(Kiosk.gold)
                                Spacer()
                            }

                            LazyVGrid(columns: columns, spacing: 2) {
                                ForEach(favoritesManager.favorites) { magazine in
                                    NavigationLink(destination: MagazineDetailView(magazine: magazine)) {
                                        MagazineCoverView(magazine: magazine)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            favoritesManager.toggle(magazine)
                                        } label: {
                                            Label("棚から外す", systemImage: "bookmark.slash")
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 4)
                            .padding(.top, 8)
                            .background {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .fill(Kiosk.shelf.opacity(0.72))
                                    .overlay(Kiosk.halftone(color: .white.opacity(0.025)))
                            }
                            .overlay(alignment: .top) { Kiosk.shelfRail(height: 8) }
                            .overlay(alignment: .bottom) { Kiosk.shelfRail(height: 8) }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 14)
                        .padding(.bottom, 24)
                    }
                }

                if UIDevice.current.userInterfaceIdiom == .phone {
                    AdBannerContainer()
                        .frame(height: 50)
                        .background(Kiosk.ink)
                }
            }
            .background(Kiosk.screenBackground.ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }

    private var shelfHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<10, id: \.self) { index in
                    Rectangle()
                        .fill(index % 2 == 0 ? Kiosk.gold : Kiosk.paper)
                }
            }
            .frame(height: 10)
            .shadow(color: Kiosk.gold.opacity(0.38), radius: 10, y: 4)

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Kiosk.gold)
                    Image(systemName: "bookmark.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(Kiosk.ink)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 1) {
                    Text("マイ棚")
                        .font(.system(size: 23, weight: .black, design: .rounded))
                        .foregroundStyle(Kiosk.paper)
                    Text("MY SHELF")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .tracking(3)
                        .foregroundStyle(Kiosk.gold)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Kiosk.ink)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "bookmark")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Kiosk.paper.opacity(0.3))
            Text("お気に入りの雑誌がまだありません")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Kiosk.paper.opacity(0.5))
            Text("雑誌の詳細画面からブックマークできます")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundStyle(Kiosk.paper.opacity(0.3))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
