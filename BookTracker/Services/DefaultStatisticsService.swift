import Foundation

final class DefaultStatisticsService: StatisticsService {
    func genreDistribution(for books: [Book]) -> [GenreCount] {
        let genres = finishedBooks(from: books).compactMap { book -> String? in
            let trimmed = book.genre?.trimmingCharacters(in: .whitespacesAndNewlines)
            return (trimmed?.isEmpty ?? true) ? nil : trimmed
        }
        let grouped = Dictionary(grouping: genres, by: { $0 })
        return grouped
            .map { GenreCount(genre: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    func moodDistribution(for books: [Book]) -> [MoodCount] {
        let moods = finishedBooks(from: books).compactMap(\.mood)
        let grouped = Dictionary(grouping: moods, by: { $0 })
        return Mood.allCases.compactMap { mood in
            guard let count = grouped[mood]?.count else { return nil }
            return MoodCount(mood: mood, count: count)
        }
    }

    func paceDistribution(for books: [Book]) -> [PaceCount] {
        let paces = finishedBooks(from: books).compactMap(\.pace)
        let grouped = Dictionary(grouping: paces, by: { $0 })
        return Pace.allCases.compactMap { pace in
            guard let count = grouped[pace]?.count else { return nil }
            return PaceCount(pace: pace, count: count)
        }
    }

    func monthlyFinishedCounts(for books: [Book]) -> [MonthlyCount] {
        let calendar = Calendar.current
        let currentMonthStart = calendar.startOfMonth(for: .now)
        guard let rangeStart = calendar.date(byAdding: .month, value: -11, to: currentMonthStart) else {
            return []
        }

        var countsByMonth: [Date: Int] = [:]
        for book in finishedBooks(from: books) {
            guard let dateFinished = book.dateFinished else { continue }
            let monthStart = calendar.startOfMonth(for: dateFinished)
            guard monthStart >= rangeStart else { continue }
            countsByMonth[monthStart, default: 0] += 1
        }

        var result: [MonthlyCount] = []
        var cursor = rangeStart
        for _ in 0..<12 {
            result.append(MonthlyCount(monthStart: cursor, count: countsByMonth[cursor] ?? 0))
            cursor = calendar.date(byAdding: .month, value: 1, to: cursor) ?? cursor
        }
        return result
    }

    private func finishedBooks(from books: [Book]) -> [Book] {
        books.filter { $0.status == .finished }
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        self.date(from: dateComponents([.year, .month], from: date)) ?? date
    }
}
