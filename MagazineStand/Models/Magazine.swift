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
    var id: String { jan }

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
        // Request larger image by replacing size parameter
        let urlStr = largeImageUrl.replacingOccurrences(of: "_ex=200x200", with: "_ex=400x400")
        return URL(string: urlStr)
    }

    var purchaseURL: URL? {
        let url = affiliateUrl.isEmpty ? itemUrl : affiliateUrl
        return URL(string: url)
    }

    var formattedPrice: String {
        "¥\(itemPrice.formatted())"
    }

    var parsedSalesDate: Date? {
        // salesDate format: "2026年05月20日" (with possible encoding issues)
        let cleaned = salesDate
            .replacingOccurrences(of: "年", with: "-")
            .replacingOccurrences(of: "月", with: "-")
            .replacingOccurrences(of: "日", with: "")
            .replacingOccurrences(of: "頃", with: "")
            .trimmingCharacters(in: .whitespaces)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.date(from: cleaned)
    }

    var displayDate: String {
        guard let date = parsedSalesDate else { return salesDate }
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d（E）"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    var isNewRelease: Bool {
        guard let date = parsedSalesDate else { return false }
        return Calendar.current.isDateInToday(date) || Calendar.current.isDateInYesterday(date)
    }

    var isUpcoming: Bool {
        guard let date = parsedSalesDate else { return false }
        return date > Date()
    }
}

struct MagazineGenre: Identifiable {
    let id: String
    let name: String
    let icon: String

    static let all: [MagazineGenre] = [
        MagazineGenre(id: "007", name: "すべて", icon: "books.vertical"),
        MagazineGenre(id: "007601", name: "女性ファッション", icon: "tshirt"),
        MagazineGenre(id: "007602", name: "男性ファッション", icon: "figure.stand"),
        MagazineGenre(id: "007603", name: "ニュース・ビジネス", icon: "newspaper"),
        MagazineGenre(id: "007604", name: "パソコン・IT", icon: "desktopcomputer"),
        MagazineGenre(id: "007606", name: "グルメ・料理", icon: "fork.knife"),
        MagazineGenre(id: "007609", name: "スポーツ", icon: "sportscourt"),
        MagazineGenre(id: "007610", name: "車・バイク", icon: "car"),
        MagazineGenre(id: "007611", name: "趣味・テレビ", icon: "tv"),
        MagazineGenre(id: "007612", name: "住まい・インテリア", icon: "house"),
        MagazineGenre(id: "007615", name: "コミック", icon: "book.closed"),
        MagazineGenre(id: "007616", name: "音楽", icon: "music.note"),
    ]
}
