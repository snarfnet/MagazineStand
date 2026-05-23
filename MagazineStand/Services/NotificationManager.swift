import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()

    @Published var isAuthorized = false
    @Published var notifyGenres: Set<String> = []

    private let genreKey = "notify_genres"

    private init() {
        loadGenres()
        Task { await checkAuthorization() }
    }

    func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            isAuthorized = granted
        } catch {
            isAuthorized = false
        }
    }

    func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func toggleGenre(_ genreId: String) {
        if notifyGenres.contains(genreId) {
            notifyGenres.remove(genreId)
        } else {
            notifyGenres.insert(genreId)
        }
        saveGenres()
    }

    func isGenreEnabled(_ genreId: String) -> Bool {
        notifyGenres.contains(genreId)
    }

    func scheduleReleaseReminder(for magazine: Magazine) {
        guard let releaseDate = magazine.parsedSalesDate else { return }

        let calendar = Calendar.current
        guard let reminderDate = calendar.date(byAdding: .day, value: -1, to: releaseDate) else { return }

        // Don't schedule if reminder date is in the past
        guard reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "明日発売"
        content.body = "\(magazine.title) が明日発売です"
        content.sound = .default

        var dateComponents = calendar.dateComponents([.year, .month, .day], from: reminderDate)
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(
            identifier: "release_\(magazine.id)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func scheduleRemindersForFavorites(_ magazines: [Magazine]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for magazine in magazines {
            scheduleReleaseReminder(for: magazine)
        }
    }

    private func saveGenres() {
        UserDefaults.standard.set(Array(notifyGenres), forKey: genreKey)
    }

    private func loadGenres() {
        let saved = UserDefaults.standard.stringArray(forKey: genreKey) ?? []
        notifyGenres = Set(saved)
    }
}
