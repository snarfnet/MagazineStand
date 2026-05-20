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

    var canLoadMore: Bool {
        currentPage < totalPages && !isLoading
    }

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
            let newMagazines = response.Items.map(\.Item).filter { !loadedJans.contains($0.jan) }
            for m in newMagazines { loadedJans.insert(m.jan) }
            magazines.append(contentsOf: newMagazines)
            totalPages = response.pageCount
            currentPage += 1
        } catch {
            errorMessage = "読み込みに失敗しました"
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
}
