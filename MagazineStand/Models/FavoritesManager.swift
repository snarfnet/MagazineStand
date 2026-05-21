import Foundation
import SwiftUI

@MainActor
final class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()

    @Published private(set) var favorites: [Magazine] = []
    private let key = "saved_favorites"

    private init() { load() }

    func isFavorite(_ magazine: Magazine) -> Bool {
        favorites.contains { $0.id == magazine.id }
    }

    func toggle(_ magazine: Magazine) {
        if let index = favorites.firstIndex(where: { $0.id == magazine.id }) {
            favorites.remove(at: index)
        } else {
            favorites.insert(magazine, at: 0)
        }
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(favorites) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Magazine].self, from: data) else { return }
        favorites = decoded
    }
}
