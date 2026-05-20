import Foundation

enum RakutenAPI {
    private static let baseURL = "https://openapi.rakuten.co.jp/services/api/BooksMagazine/Search/20170404"
    private static let applicationId = "4f1c5ecd-cbbd-41d0-bb92-5cd8bc5aedb7"
    private static let accessKey = "pk_k4pXFAmyNlBcLH1Gdrlh4BDfOLiW0gtPtuELsJ2oH1b"
    private static let affiliateId = "51e03d3d.388db312.51e03d3e.8f3294ba"
    private static let referer = "https://snarfnet.github.io/"

    static func searchMagazines(
        genreId: String = "007",
        keyword: String = "",
        page: Int = 1,
        sort: String = "-releaseDate"
    ) async throws -> MagazineResponse {
        var components = URLComponents(string: baseURL)!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "applicationId", value: applicationId),
            URLQueryItem(name: "booksGenreId", value: genreId),
            URLQueryItem(name: "sort", value: sort),
            URLQueryItem(name: "hits", value: "30"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "affiliateId", value: affiliateId),
        ]

        if !keyword.isEmpty {
            queryItems.append(URLQueryItem(name: "title", value: keyword))
        }

        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.setValue(accessKey, forHTTPHeaderField: "accessKey")
        request.setValue(referer, forHTTPHeaderField: "Referer")
        request.setValue(referer, forHTTPHeaderField: "Origin")

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try decoder.decode(MagazineResponse.self, from: data)
    }
}
