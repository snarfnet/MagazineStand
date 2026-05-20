import Foundation
import SwiftUI

@MainActor
final class MagazineViewModel: ObservableObject {
    @Published var magazines: [Magazine] = []
    @Published var isLoading = false
    @Published var searchText = ""
    @Published var selectedGenre: MagazineGenre = MagazineGenre.all[0]
    @Published var errorMessage: String?

    private var currentPage = 1
    private var totalPages = 1
    private var loadedJans: Set<String> = []

    var featured: Magazine? { magazines.first }
    var newReleaseCount: Int { magazines.filter(\.isNewRelease).count }
    var canLoadMore: Bool { currentPage < totalPages && !isLoading }

    func loadMagazines(reset: Bool = false) async {
        if reset {
            currentPage = 1
            totalPages = 1
            magazines = []
            loadedJans = []
        }

        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            let response = try await RakutenAPI.searchMagazines(
                genreId: selectedGenre.id,
                keyword: searchText,
                page: currentPage
            )
            let newMagazines = response.Items.map(\.Item).filter { !loadedJans.contains($0.id) }
            for magazine in newMagazines { loadedJans.insert(magazine.id) }
            magazines.append(contentsOf: newMagazines)
            totalPages = max(response.pageCount, currentPage)
            currentPage += 1

            if magazines.isEmpty {
                useSampleData(message: "表示できる雑誌がありません。サンプル棚を表示しています。")
            }
        } catch {
            useSampleData(message: "通信に失敗しました。サンプル棚を表示しています。")
        }

        isLoading = false
    }

    func search() async {
        await loadMagazines(reset: true)
    }

    func changeGenre(_ genre: MagazineGenre) async {
        selectedGenre = genre
        searchText = ""
        await loadMagazines(reset: true)
    }

    func loadMoreIfNeeded(current: Magazine) async {
        guard let last = magazines.last, last.id == current.id, canLoadMore else { return }
        await loadMagazines()
    }

    private func useSampleData(message: String) {
        if magazines.isEmpty {
            magazines = Magazine.samples
            loadedJans = Set(magazines.map(\.id))
        }
        errorMessage = message
        totalPages = 1
    }
}
