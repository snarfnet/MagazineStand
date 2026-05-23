import SwiftUI

struct CalendarView: View {
    @StateObject private var viewModel = MagazineViewModel()
    @ObservedObject private var favoritesManager = FavoritesManager.shared
    @ObservedObject private var notificationManager = NotificationManager.shared
    @State private var displayedMonth = Date()
    @State private var selectedDay: Date?

    private let calendar = Calendar.current
    private let weekdays = ["日", "月", "火", "水", "木", "金", "土"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                calendarHeader

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        monthNavigation
                        weekdayHeader
                        calendarGrid
                        selectedDayMagazines
                        notificationSettings
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
                await viewModel.loadMagazines(reset: true)
            }
        }
    }

    private var calendarHeader: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                ForEach(0..<10, id: \.self) { index in
                    Rectangle()
                        .fill(index % 2 == 0 ? Kiosk.signalCyan : Kiosk.paper)
                }
            }
            .frame(height: 10)
            .shadow(color: Kiosk.signalCyan.opacity(0.38), radius: 10, y: 4)

            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Kiosk.signalCyan)
                    Image(systemName: "calendar")
                        .font(.system(size: 22, weight: .black))
                        .foregroundStyle(.white)
                }
                .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 1) {
                    Text("発売カレンダー")
                        .font(.system(size: 23, weight: .black, design: .rounded))
                        .foregroundStyle(Kiosk.paper)
                    Text("RELEASE CALENDAR")
                        .font(.system(size: 10, weight: .black, design: .monospaced))
                        .tracking(3)
                        .foregroundStyle(Kiosk.signalCyan)
                }

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Kiosk.ink)
    }

    private var monthNavigation: some View {
        HStack {
            Button {
                withAnimation(.snappy) {
                    displayedMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Kiosk.paper)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.09), in: Circle())
            }

            Spacer()

            VStack(spacing: 2) {
                Text(monthYearString)
                    .font(.system(size: 20, weight: .black, design: .rounded))
                    .foregroundStyle(Kiosk.paper)
                Text("\(magazinesThisMonth.count)冊の発売予定")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Kiosk.gold)
            }

            Spacer()

            Button {
                withAnimation(.snappy) {
                    displayedMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) ?? displayedMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .black))
                    .foregroundStyle(Kiosk.paper)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.09), in: Circle())
            }
        }
    }

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(weekdays, id: \.self) { day in
                Text(day)
                    .font(.system(size: 11, weight: .black, design: .rounded))
                    .foregroundStyle(day == "日" ? Kiosk.neonRed : day == "土" ? Kiosk.signalCyan : Kiosk.paper.opacity(0.5))
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendarGrid: some View {
        let days = daysInMonth()
        let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

        return LazyVGrid(columns: columns, spacing: 4) {
            ForEach(days, id: \.self) { day in
                if let day = day {
                    let magazines = magazinesFor(day)
                    let isSelected = selectedDay.map { calendar.isDate($0, inSameDayAs: day) } ?? false
                    let isToday = calendar.isDateInToday(day)

                    Button {
                        withAnimation(.snappy) {
                            selectedDay = isSelected ? nil : day
                        }
                    } label: {
                        VStack(spacing: 3) {
                            Text("\(calendar.component(.day, from: day))")
                                .font(.system(size: 14, weight: isToday ? .black : .bold, design: .rounded))
                                .foregroundStyle(isToday ? Kiosk.gold : Kiosk.paper)

                            if !magazines.isEmpty {
                                HStack(spacing: 2) {
                                    ForEach(0..<min(magazines.count, 3), id: \.self) { _ in
                                        Circle()
                                            .fill(Kiosk.neonRed)
                                            .frame(width: 5, height: 5)
                                    }
                                }
                            } else {
                                Spacer().frame(height: 5)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(isSelected ? Kiosk.signalCyan.opacity(0.2) : isToday ? Kiosk.gold.opacity(0.1) : .clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .stroke(isToday ? Kiosk.gold.opacity(0.4) : .clear, lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                } else {
                    Color.clear.frame(height: 44)
                }
            }
        }
        .padding(12)
        .glassPanel()
    }

    @ViewBuilder
    private var selectedDayMagazines: some View {
        if let day = selectedDay {
            let magazines = magazinesFor(day)
            if !magazines.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(dayString(day))
                            .font(.system(size: 16, weight: .black, design: .rounded))
                            .foregroundStyle(Kiosk.paper)
                        Spacer()
                        Text("\(magazines.count)冊")
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(Kiosk.gold)
                    }

                    ForEach(magazines) { magazine in
                        NavigationLink(destination: MagazineDetailView(magazine: magazine)) {
                            HStack(spacing: 12) {
                                AsyncImage(url: magazine.coverURL) { phase in
                                    if let image = phase.image {
                                        image.resizable().aspectRatio(contentMode: .fill)
                                    } else {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Kiosk.shelf)
                                    }
                                }
                                .frame(width: 44, height: 62)
                                .clipShape(RoundedRectangle(cornerRadius: 4))

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(magazine.title)
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundStyle(Kiosk.paper)
                                        .lineLimit(2)
                                    Text("\(magazine.publisherName) \(magazine.formattedPrice)")
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundStyle(Kiosk.paper.opacity(0.5))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(Kiosk.paper.opacity(0.3))
                            }
                            .padding(10)
                            .glassPanel()
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var notificationSettings: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bell.fill")
                    .foregroundStyle(Kiosk.gold)
                Text("新刊通知")
                    .font(.system(size: 16, weight: .black, design: .rounded))
                    .foregroundStyle(Kiosk.paper)
                Spacer()

                if !notificationManager.isAuthorized {
                    Button("許可する") {
                        Task { await notificationManager.requestPermission() }
                    }
                    .font(.system(size: 12, weight: .black, design: .rounded))
                    .foregroundStyle(Kiosk.ink)
                    .padding(.horizontal, 12)
                    .frame(height: 30)
                    .background(Kiosk.gold, in: Capsule())
                }
            }

            if notificationManager.isAuthorized {
                Text("お気に入りジャンルの新刊発売前日に通知します")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Kiosk.paper.opacity(0.5))

                ForEach(MagazineGenre.all.filter { $0.id != "007" }) { genre in
                    Button {
                        notificationManager.toggleGenre(genre.id)
                        updateNotifications()
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: genre.icon)
                                .frame(width: 24)
                                .foregroundStyle(notificationManager.isGenreEnabled(genre.id) ? Kiosk.gold : Kiosk.paper.opacity(0.4))
                            Text(genre.name)
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(Kiosk.paper)
                            Spacer()
                            Image(systemName: notificationManager.isGenreEnabled(genre.id) ? "bell.fill" : "bell.slash")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundStyle(notificationManager.isGenreEnabled(genre.id) ? Kiosk.gold : Kiosk.paper.opacity(0.3))
                        }
                        .padding(.vertical, 6)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(16)
        .glassPanel()
    }

    // MARK: - Helpers

    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy年M月"
        return formatter.string(from: displayedMonth)
    }

    private func dayString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日 (E)"
        return formatter.string(from: date)
    }

    private var magazinesThisMonth: [Magazine] {
        let range = calendar.range(of: .day, in: .month, for: displayedMonth)!
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        return viewModel.magazines.filter { mag in
            guard let date = mag.parsedSalesDate else { return false }
            let magComps = calendar.dateComponents([.year, .month], from: date)
            return magComps.year == comps.year && magComps.month == comps.month
        }
    }

    private func magazinesFor(_ day: Date) -> [Magazine] {
        viewModel.magazines.filter { mag in
            guard let date = mag.parsedSalesDate else { return false }
            return calendar.isDate(date, inSameDayAs: day)
        }
    }

    private func daysInMonth() -> [Date?] {
        let comps = calendar.dateComponents([.year, .month], from: displayedMonth)
        guard let firstDay = calendar.date(from: comps),
              let range = calendar.range(of: .day, in: .month, for: firstDay) else { return [] }

        let weekday = calendar.component(.weekday, from: firstDay)
        let leadingBlanks = weekday - 1

        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)
        for day in range {
            var dayComps = comps
            dayComps.day = day
            days.append(calendar.date(from: dayComps))
        }

        return days
    }

    private func updateNotifications() {
        let enabledGenres = notificationManager.notifyGenres
        let relevantMagazines = viewModel.magazines.filter { mag in
            enabledGenres.contains(where: { mag.booksGenreId.hasPrefix($0) })
        }
        notificationManager.scheduleRemindersForFavorites(relevantMagazines)
    }
}
