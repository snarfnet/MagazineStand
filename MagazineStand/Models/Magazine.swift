import Foundation

struct MagazineResponse: Codable {
    let count: Int
    let page: Int
    let hits: Int
    let pageCount: Int
    let Items: [MagazineItem]
}

struct MagazineItem: Codable {
    let Item: Magazine
}

struct Magazine: Codable, Identifiable {
    var id: String { jan.isEmpty ? title : jan }

    let title: String
    let titleKana: String
    let publisherName: String
    let jan: String
    let itemCaption: String
    let salesDate: String
    let cycle: String
    let itemPrice: Int
    let itemUrl: String
    let affiliateUrl: String
    let smallImageUrl: String
    let mediumImageUrl: String
    let largeImageUrl: String
    let booksGenreId: String
    let reviewCount: Int
    let reviewAverage: String
    let availability: String

    var coverURL: URL? {
        let source = largeImageUrl.isEmpty ? mediumImageUrl : largeImageUrl
        let urlString = source
            .replacingOccurrences(of: "_ex=120x120", with: "_ex=500x500")
            .replacingOccurrences(of: "_ex=200x200", with: "_ex=500x500")
        return URL(string: urlString)
    }

    var purchaseURL: URL? {
        let url = affiliateUrl.isEmpty ? itemUrl : affiliateUrl
        return URL(string: url)
    }

    var formattedPrice: String {
        itemPrice > 0 ? "¥\(itemPrice.formatted())" : "価格未定"
    }

    var parsedSalesDate: Date? {
        let normalized = salesDate
            .replacingOccurrences(of: "年", with: "-")
            .replacingOccurrences(of: "月", with: "-")
            .replacingOccurrences(of: "日", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: normalized)
    }

    var displayDate: String {
        guard let date = parsedSalesDate else { return salesDate.isEmpty ? "発売日未定" : salesDate }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M/d発売"
        return formatter.string(from: date)
    }

    var releaseStatus: String {
        if isNewRelease { return "NEW" }
        if isUpcoming { return "予約" }
        return cycle.isEmpty ? "雑誌" : cycle
    }

    var isNewRelease: Bool {
        guard let date = parsedSalesDate else { return false }
        let calendar = Calendar.current
        return calendar.isDateInToday(date) || calendar.isDateInYesterday(date)
    }

    var isUpcoming: Bool {
        guard let date = parsedSalesDate else { return false }
        return date > Date()
    }

    static let samples: [Magazine] = [
        .mock(title: "TOKYO CULTURE FILE", publisher: "架空出版", date: "2026年05月20日", price: 780, genre: "007603", caption: "街の新店、音楽、映画、深夜のカルチャーを一冊で追える週末向けマガジン。"),
        .mock(title: "MODE NIGHT", publisher: "Kiosk Press", date: "2026年05月21日", price: 920, genre: "007601", caption: "夜の街に映える服、スニーカー、バッグを強い写真で見せるファッション特集。"),
        .mock(title: "DIGITAL EDGE", publisher: "Future Lab", date: "2026年05月18日", price: 1_100, genre: "007604", caption: "AI、ガジェット、仕事道具を短く濃く読むためのテック雑誌。"),
        .mock(title: "FOOD STAND", publisher: "Table Works", date: "2026年05月15日", price: 690, genre: "007606", caption: "駅前の名店から家の一皿まで、今日食べたいものが決まるグルメ特集。"),
        .mock(title: "COMIC SIGNAL", publisher: "Redline", date: "2026年05月19日", price: 540, genre: "007615", caption: "話題作、短編、インタビューをまとめて追えるコミック情報誌。"),
        .mock(title: "GARAGE LIFE JP", publisher: "Motor Shelf", date: "2026年05月10日", price: 980, genre: "007610", caption: "車とバイク、工具と旅。週末の予定まで変えてしまう一冊。")
    ]

    private static func mock(title: String, publisher: String, date: String, price: Int, genre: String, caption: String) -> Magazine {
        Magazine(
            title: title,
            titleKana: title,
            publisherName: publisher,
            jan: UUID().uuidString,
            itemCaption: caption,
            salesDate: date,
            cycle: "月刊",
            itemPrice: price,
            itemUrl: "https://books.rakuten.co.jp/",
            affiliateUrl: "https://books.rakuten.co.jp/",
            smallImageUrl: "",
            mediumImageUrl: "",
            largeImageUrl: "",
            booksGenreId: genre,
            reviewCount: 0,
            reviewAverage: "0",
            availability: "1"
        )
    }
}

struct MagazineGenre: Identifiable, Equatable {
    let id: String
    let name: String
    let icon: String

    static let all: [MagazineGenre] = [
        MagazineGenre(id: "007", name: "すべて", icon: "books.vertical.fill"),
        MagazineGenre(id: "007601", name: "女性ファッション", icon: "tshirt.fill"),
        MagazineGenre(id: "007602", name: "男性ファッション", icon: "figure.stand"),
        MagazineGenre(id: "007603", name: "ニュース", icon: "newspaper.fill"),
        MagazineGenre(id: "007604", name: "PC・IT", icon: "desktopcomputer"),
        MagazineGenre(id: "007606", name: "グルメ", icon: "fork.knife"),
        MagazineGenre(id: "007609", name: "スポーツ", icon: "sportscourt.fill"),
        MagazineGenre(id: "007610", name: "車・バイク", icon: "car.fill"),
        MagazineGenre(id: "007611", name: "趣味", icon: "sparkles"),
        MagazineGenre(id: "007612", name: "住まい", icon: "house.fill"),
        MagazineGenre(id: "007615", name: "コミック", icon: "book.closed.fill"),
        MagazineGenre(id: "007616", name: "音楽", icon: "music.note")
    ]
}
