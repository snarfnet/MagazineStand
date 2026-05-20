import SwiftUI

struct MainView: View {
    @StateObject private var viewModel = MagazineViewModel()
    @State private var showSearch = false

    private let columns = [
        GridItem(.adaptive(minimum: 104, maximum: 126), spacing: 8)
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                AwningHeader(showSearch: $showSearch, searchText: $viewModel.searchText) {
                    Task { await viewModel.search() }
                }

                GenreBarView(selectedGenre: $viewModel.selectedGenre) { genre in
                    Task { await viewModel.changeGenre(genre) }
                }

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        if viewModel.isLoading && viewModel.magazines.isEmpty {
                            loadingView
                        } else {
                            if let message = viewModel.errorMessage {
                                NoticeBar(message: message)
                            }
                            heroSection
                            magazineGrid
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 14)
                    .padding(.bottom, 24)
                }
                .background(Kiosk.screenBackground.ignoresSafeArea())

                if UIDevice.current.userInterfaceIdiom == .phone {
                    AdBannerContainer()
                        .frame(height: 50)
                        .background(Kiosk.ink)
                }
            }
            .background(Kiosk.ink)
            .navigationBarHidden(true)
            .task {
                if viewModel.magazines.isEmpty {
                    await viewModel.loadMagazines()
                }
            }
        }
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("TODAY'S FRONT RACK")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .tracking(2)
                        .foregroundStyle(Kiosk.signalCyan)
                    Text(viewModel.selectedGenre.name)
                        .font(.system(size: 26, weight: .black, design: .rounded))
                        .foregroundStyle(Kiosk.paper)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(viewModel.magazines.count)")
                        .font(.system(size: 24, weight: .black, design: .monospaced))
                        .foregroundStyle(Kiosk.gold)
                    Text("冊")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(Kiosk.paper.opacity(0.62))
                }
            }

            if let featured = viewModel.featured {
                NavigationLink(destination: MagazineDetailView(magazine: featured)) {
                    FeaturedRackCard(magazine: featured, newCount: viewModel.newReleaseCount)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var magazineGrid: some View {
        VStack(spacing: 10) {
            HStack {
                Label("新刊ラック", systemImage: "bolt.fill")
                    .font(.system(size: 15, weight: .black, design: .rounded))
                    .foregroundStyle(Kiosk.paper)
                Spacer()
                Text("RELEASE ORDER")
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .tracking(1.4)
                    .foregroundStyle(Kiosk.paper.opacity(0.44))
            }

            LazyVGrid(columns: columns, spacing: 2) {
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
            .padding(.horizontal, 4)
            .padding(.top, 8)
            .background {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Kiosk.shelf.opacity(0.72))
                    .overlay(Kiosk.halftone(color: .white.opacity(0.025)))
            }
            .overlay(alignment: .top) { Kiosk.shelfRail(height: 8) }
            .overlay(alignment: .bottom) { Kiosk.shelfRail(height: 8) }

            if viewModel.isLoading {
                ProgressView()
                    .tint(Kiosk.gold)
                    .padding(.vertical, 12)
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 14) {
            ProgressView()
                .tint(Kiosk.gold)
                .scaleEffect(1.35)
            Text("棚を組み替えています")
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Kiosk.paper.opacity(0.70))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 92)
    }
}

private struct FeaturedRackCard: View {
    let magazine: Magazine
    let newCount: Int

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Kiosk.heroGlow)
                .overlay(Kiosk.halftone(color: .white.opacity(0.10)))

            HStack(alignment: .bottom, spacing: 14) {
                MagazineCoverView(magazine: magazine, compact: true)
                    .rotationEffect(.degrees(-3))
                    .offset(y: 8)

                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 7) {
                        Badge(text: magazine.releaseStatus, color: Kiosk.neonRed)
                        Badge(text: magazine.displayDate, color: Kiosk.gold, darkText: true)
                    }

                    Text(magazine.title)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(3)
                        .minimumScaleFactor(0.72)

                    Text(magazine.itemCaption.isEmpty ? "表紙をタップして詳細を確認。" : magazine.itemCaption)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.78))
                        .lineLimit(3)

                    HStack(spacing: 12) {
                        MetricPill(value: "\(newCount)", label: "NEW")
                        MetricPill(value: magazine.formattedPrice, label: "PRICE")
                    }
                }

                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .frame(minHeight: 232)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.white.opacity(0.14), lineWidth: 1)
        }
        .shadow(color: Kiosk.neonRed.opacity(0.22), radius: 18, y: 10)
    }
}

private struct AwningHeader: View {
    @Binding var showSearch: Bool
    @Binding var searchText: String
    let onSearch: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<10, id: \.self) { index in
                    Rectangle()
                        .fill(index % 2 == 0 ? Kiosk.neonRed : Kiosk.paper)
                }
            }
            .frame(height: 10)
            .shadow(color: Kiosk.neonRed.opacity(0.38), radius: 10, y: 4)

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Kiosk.neonRed)
                    Image(systemName: "magazine.fill")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 1) {
                    Text("マガジンスタンド")
                        .font(.system(size: 23, weight: .black, design: .rounded))
                        .foregroundStyle(Kiosk.paper)
                    Text("MAGAZINE STAND")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .tracking(3)
                        .foregroundStyle(Kiosk.gold)
                }

                Spacer()

                Button {
                    withAnimation(.snappy) {
                        showSearch.toggle()
                        if !showSearch { searchText = "" }
                    }
                } label: {
                    Image(systemName: showSearch ? "xmark" : "magnifyingglass")
                        .font(.system(size: 16, weight: .black))
                        .foregroundStyle(Kiosk.paper)
                        .frame(width: 40, height: 40)
                        .background(.white.opacity(0.09), in: Circle())
                        .overlay(Circle().stroke(.white.opacity(0.12), lineWidth: 1))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            if showSearch {
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Kiosk.paper.opacity(0.5))
                    TextField("雑誌名で検索", text: $searchText)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Kiosk.paper)
                        .submitLabel(.search)
                        .onSubmit(onSearch)
                    Button("検索", action: onSearch)
                        .font(.system(size: 13, weight: .black, design: .rounded))
                        .foregroundStyle(Kiosk.ink)
                        .padding(.horizontal, 12)
                        .frame(height: 30)
                        .background(Kiosk.gold, in: Capsule())
                }
                .padding(10)
                .glassPanel()
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
        .background(Kiosk.ink)
    }
}

private struct NoticeBar: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "info.circle.fill")
            .font(.system(size: 12, weight: .bold, design: .rounded))
            .foregroundStyle(Kiosk.paper.opacity(0.86))
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Kiosk.signalCyan.opacity(0.13), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct Badge: View {
    let text: String
    let color: Color
    var darkText = false

    var body: some View {
        Text(text)
            .font(.system(size: 10, weight: .black, design: .rounded))
            .foregroundStyle(darkText ? Kiosk.ink : .white)
            .padding(.horizontal, 8)
            .frame(height: 24)
            .background(color, in: Capsule())
    }
}

private struct MetricPill: View {
    let value: String
    let label: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.system(size: 8, weight: .black, design: .monospaced))
                .foregroundStyle(.white.opacity(0.45))
            Text(value)
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(.black.opacity(0.24), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}
