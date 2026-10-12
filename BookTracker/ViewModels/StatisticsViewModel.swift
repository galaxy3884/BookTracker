import Foundation

@Observable
final class StatisticsViewModel {
    private let statisticsService: StatisticsService

    var genreData: [GenreCount] = []
    var moodData: [MoodCount] = []
    var paceData: [PaceCount] = []
    var monthlyData: [MonthlyCount] = []

    init(statisticsService: StatisticsService) {
        self.statisticsService = statisticsService
    }

    /// Recomputes all four aggregations. They are cheap, in-memory passes over `Book` objects
    /// (which are bound to the main actor), so this stays synchronous.
    func refresh(books: [Book]) {
        genreData = statisticsService.genreDistribution(for: books)
        moodData = statisticsService.moodDistribution(for: books)
        paceData = statisticsService.paceDistribution(for: books)
        monthlyData = statisticsService.monthlyFinishedCounts(for: books)
    }
}
