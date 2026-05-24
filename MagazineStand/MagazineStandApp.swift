import SwiftUI
import AppTrackingTransparency

@main
struct MagazineStandApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        ATTrackingManager.requestTrackingAuthorization { _ in }
                    }
                }
        }
    }
}

struct RootTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            MainView()
                .tabItem {
                    Label("メイン棚", systemImage: "magazine.fill")
                }
                .tag(0)

            NavigationStack {
                BarcodeScannerView()
            }
                .tabItem {
                    Label("スキャン", systemImage: "barcode.viewfinder")
                }
                .tag(1)

            CalendarView()
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
                .tag(2)

            StatsView()
                .tabItem {
                    Label("統計", systemImage: "chart.bar.fill")
                }
                .tag(3)

            MyShelfView()
                .tabItem {
                    Label("マイ棚", systemImage: "bookmark.fill")
                }
                .tag(4)
        }
        .tint(Kiosk.gold)
    }
}
