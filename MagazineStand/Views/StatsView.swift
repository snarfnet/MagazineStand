import SwiftUI

struct StatsView: View {
    @ObservedObject private var favoritesManager = FavoritesManager.shared

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                statsHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        overviewCards
                        genreBreakdown
                        priceAnalysis
                        publisherRanking
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    .padding(.bottom, 24)
                }
                .background(Kiosk.screenBackground.ignoresSafeArea())

                if UIDevice.current.userInterfaceIdiom == .phone {
                    AdBannerContainer()
                        .frame(height: 50)
                        .background(Kiosk.ink)
                }
            }
            .background(Kiosk.ink)
            .navigationBarHidden(true)
        }
    }

    private var statsHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<10, id: \.self) { index in
                    Rectangle()
                        .fill(index % 2 == 0 ? Kiosk.violet : Kiosk.paper)
                }
            }
            .frame(height: 10)
            .shadow(color: Kiosk.violet.opacity(0.38), radius: 10, y: 4)

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Kiosk.violet)
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 1) {
                    Text("読書統計")
                        .font(.system(size: 23, weight: .black, design: .rounded))
                        .foregroundStyle(Kiosk.paper)
                    Text("READING STATS")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .tracking(3)
                        .foregroundStyle(Kiosk.violet)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Kiosk.ink)
    }

    private var overviewCards: some View {
        HStack(spacing: 10) {
            StatCard(
                icon: "bookmark.fill",
                value: "\(favoritesManager.favorites.count)",
                label: "お気に入り",
                color: Kiosk.gold
            )
            StatCard(
                icon: "building.2.fill",
                value: "\(uniquePublishers.count)",
                label: "出版社",
                color: Kiosk.signalCyan
            )
            StatCard(
                icon: "yensign",
                value: totalSpending,
                label: "合計額",
                color: Kiosk.neonRed
            )
        }
    }

    private var genreBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("ジャンル内訳", systemImage: "chart.pie.fill")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(Kiosk.paper)

            if genreCounts.isEmpty {
                Text("お気に入りに雑誌を追加すると統計が表示されます")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Kiosk.paper.opacity(0.4))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
            } else {
                ForEach(genreCounts, id: \.genre.id) { item in
                    HStack(spacing: 10) {
                        Image(systemName: item.genre.icon)
                            .frame(width: 24)
                            .foregroundStyle(barColor(for: item.genre.id))

                        Text(item.genre.name)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Kiosk.paper)
                            .frame(width: 80, alignment: .leading)

                        GeometryReader { geo in
                            RoundedRectangle(cornerRadius: 3, style: .continuous)
                                .fill(barColor(for: item.genre.id))
                                .frame(width: geo.size.width * item.ratio)
                        }
                        .frame(height: 14)

                        Text("\(item.count)")
                            .font(.system(size: 13, weight: .black, design: .monospaced))
                            .foregroundStyle(Kiosk.gold)
                            .frame(width: 28, alignment: .trailing)
                    }
                    .frame(height: 28)
                }
            }
        }
        .padding(16)
        .glassPanel()
    }

    private var priceAnalysis: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("価格帯", systemImage: "yensign.circle.fill")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(Kiosk.paper)

            if favoritesManager.favorites.isEmpty {
                Text("データなし")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Kiosk.paper.opacity(0.4))
                    .padding(.vertical, 10)
            } else {
                HStack(spacing: 10) {
                    PriceTile(label: "最安", value: cheapest, color: Kiosk.green)
                    PriceTile(label: "平均", value: average, color: Kiosk.gold)
                    PriceTile(label: "最高", value: expensive, color: Kiosk.neonRed)
                }
            }
        }
        .padding(16)
        .glassPanel()
    }

    private var publisherRanking: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("出版社ランキング", systemImage: "trophy.fill")
                .font(.system(size: 15, weight: .black, design: .rounded))
                .foregroundStyle(Kiosk.paper)

            ForEach(Array(topPublishers.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 10) {
                    Text("\(index + 1)")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundStyle(index == 0 ? Kiosk.gold : Kiosk.paper.opacity(0.5))
                        .frame(width: 24)

                    Text(item.name)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(Kiosk.paper)

                    Spacer()

                    Text("\(item.count)冊")
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(Kiosk.gold)
                }
                .padding(.vertical, 4)
            }

            if topPublishers.isEmpty {
                Text("データなし")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Kiosk.paper.opacity(0.4))
                    .padding(.vertical, 10)
            }
        }
        .padding(16)
        .glassPanel()
    }

    // MARK: - Data

    private var uniquePublishers: Set<String> {
        Set(favoritesManager.favorites.map(\.publisherName).filter { !$0.isEmpty })
    }

    private var totalSpending: String {
        let total = favoritesManager.favorites.reduce(0) { $0 + $1.itemPrice }
        return total > 0 ? "¥\(total.formatted())" : "¥0"
    }

    private var cheapest: String {
        let prices = favoritesManager.favorites.map(\.itemPrice).filter { $0 > 0 }
        guard let min = prices.min() else { return "-" }
        return "¥\(min.formatted())"
    }

    private var average: String {
        let prices = favoritesManager.favorites.map(\.itemPrice).filter { $0 > 0 }
        guard !prices.isEmpty else { return "-" }
        let avg = prices.reduce(0, +) / prices.count
        return "¥\(avg.formatted())"
    }

    private var expensive: String {
        let prices = favoritesManager.favorites.map(\.itemPrice).filter { $0 > 0 }
        guard let max = prices.max() else { return "-" }
        return "¥\(max.formatted())"
    }

    struct GenreCount {
        let genre: MagazineGenre
        let count: Int
        let ratio: CGFloat
    }

    private var genreCounts: [GenreCount] {
        var counts: [String: Int] = [:]
        for mag in favoritesManager.favorites {
            let genreId = mag.booksGenreId
            for genre in MagazineGenre.all where genre.id != "007" {
                if genreId.hasPrefix(genre.id) {
                    counts[genre.id, default: 0] += 1
                    break
                }
            }
        }

        let maxCount = counts.values.max() ?? 1
        return counts
            .sorted { $0.value > $1.value }
            .compactMap { id, count in
                guard let genre = MagazineGenre.all.first(where: { $0.id == id }) else { return nil }
                return GenreCount(genre: genre, count: count, ratio: CGFloat(count) / CGFloat(maxCount))
            }
    }

    struct PublisherCount {
        let name: String
        let count: Int
    }

    private var topPublishers: [PublisherCount] {
        var counts: [String: Int] = [:]
        for mag in favoritesManager.favorites where !mag.publisherName.isEmpty {
            counts[mag.publisherName, default: 0] += 1
        }
        return counts
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { PublisherCount(name: $0.key, count: $0.value) }
    }

    private func barColor(for genreId: String) -> Color {
        let colors: [Color] = [Kiosk.neonRed, Kiosk.signalCyan, Kiosk.gold, Kiosk.violet, Kiosk.green]
        let index = abs(genreId.hashValue) % colors.count
        return colors[index]
    }
}

private struct StatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 20, weight: .black, design: .rounded))
                .foregroundStyle(Kiosk.paper)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Text(label)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(Kiosk.paper.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassPanel()
    }
}

private struct PriceTile: View {
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 10, weight: .black, design: .rounded))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 16, weight: .black, design: .rounded))
                .foregroundStyle(Kiosk.paper)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.black.opacity(0.20), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
