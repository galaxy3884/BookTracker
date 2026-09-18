import Foundation

struct GenreCount: Identifiable {
    let id = UUID()
    let genre: String
    let count: Int
}

struct MoodCount: Identifiable {
    let id = UUID()
    let mood: Mood
    let count: Int
}

struct PaceCount: Identifiable {
    let id = UUID()
    let pace: Pace
    let count: Int
}

struct MonthlyCount: Identifiable {
    let id = UUID()
    let monthStart: Date
    let count: Int
}

protocol StatisticsService {
    func genreDistribution(for books: [Book]) -> [GenreCount]
    func moodDistribution(for books: [Book]) -> [MoodCount]
    func paceDistribution(for books: [Book]) -> [PaceCount]
    func monthlyFinishedCounts(for books: [Book]) -> [MonthlyCount]
}
