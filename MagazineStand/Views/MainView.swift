import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MagazineViewModel()
    @State private var showSearch = false

    private let columns = [
        GridItem(.adaptive(minimum: 110, maximum: 130), spacing: 10)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Awning header
                AwningHeader(showSearch: $showSearch, searchText: $viewModel.searchText) {
                    Task { await viewModel.search() }
                }

                // Genre bar
                GenreBarView(selectedGenre: $viewModel.selectedGenre) { genre in
                    Task { await viewModel.changeGenre(genre) }
                }

                // Magazine grid
                ScrollView {
                    if viewModel.isLoading && viewModel.magazines.isEmpty {
                        loadingView
                    } else if let error = viewModel.errorMessage, viewModel.magazines.isEmpty {
                        errorView(error)
                    } else {
                        magazineGrid
                    }
                }
                .background(Kiosk.backgroundGradient.ignoresSafeArea())

                // Ad banner
                if UIDevice.current.userInterfaceIdiom == .phone {
                    AdBannerContainer()
                        .frame(height: 50)
                        .background(Kiosk.woodDark.opacity(0.95))
                }
            }
            .background(Kiosk.woodDark)
            .navigationBarHidden(true)
            .task {
                if viewModel.magazines.isEmpty {
                    await viewModel.loadMagazines()
                }
            }
        }
    }

    private var magazineGrid: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(viewModel.magazines) { magazine in
                    NavigationLink(destination: MagazineDetailView(magazine: magazine)) {
                        MagazineCoverView(magazine: magazine)
                    }
                    .buttonStyle(.plain)
                    .task {
                        await viewModel.loadMoreIfNeeded(current: magazine)
                    }
                }
            }
            .padding(.horizontal, 10)
            .padding(.top, 10)
            .padding(.bottom, 16)

            if viewModel.isLoading {
                ProgressView()
                    .tint(Kiosk.cream)
                    .padding()
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Kiosk.cream)
                .scaleEffect(1.3)
            Text("棚に並べています...")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Kiosk.cream.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundColor(Kiosk.yellowPrice)
            Text(message)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(Kiosk.cream.opacity(0.7))
            Button("再読み込み") {
                Task { await viewModel.loadMagazines(reset: true) }
            }
            .font(.system(size: 14, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Kiosk.redAwning)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

private struct AwningHeader: View {
    @Binding var showSearch: Bool
    @Binding var searchText: String
    let onSearch: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Awning stripe
            HStack(spacing: 0) {
                ForEach(0..<12, id: \.self) { i in
                    Rectangle()
                        .fill(i % 2 == 0 ? Kiosk.redAwning : Kiosk.cream)
                        .frame(height: 6)
                }
            }

            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("マガジンスタンド")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                        .foregroundColor(Kiosk.cream)
                    Text("MAGAZINE STAND")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .tracking(3)
                        .foregroundColor(Kiosk.yellowPrice)
                }

                Spacer()

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showSearch.toggle()
                        if !showSearch { searchText = "" }
                    }
                } label: {
                    Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Kiosk.cream)
                        .frame(width: 36, height: 36)
                        .background(Kiosk.woodMid)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)

            if showSearch {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Kiosk.cream.opacity(0.5))
                    TextField("雑誌を検索...", text: $searchText)
                        .font(.system(size: 14, design: .rounded))
                        .foregroundColor(Kiosk.cream)
                        .submitLabel(.search)
                        .onSubmit(onSearch)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Kiosk.woodMid)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal, 14)
                .padding(.bottom, 8)
            }
        }
        .background(
            LinearGradient(
                colors: [Kiosk.woodDark, Kiosk.woodDark.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
