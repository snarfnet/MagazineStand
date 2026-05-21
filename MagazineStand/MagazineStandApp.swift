import SwiftUI

@main
struct MagazineStandApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
                .preferredColorScheme(.dark)
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

            MyShelfView()
                .tabItem {
                    Label("マイ棚", systemImage: "bookmark.fill")
                }
                .tag(1)
        }
        .tint(Kiosk.gold)
    }
}
