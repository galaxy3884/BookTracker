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

    /// Recomputes all four aggregations, yielding between each so a large
    /// library doesn't block the UI in one long synchronous stretch.
    func refresh(books: [Book]) async {
        genreData = statisticsService.genreDistribution(for: books)
        await Task.yield()
        moodData = statisticsService.moodDistribution(for: books)
        await Task.yield()
        paceData = statisticsService.paceDistribution(for: books)
        await Task.yield()
        monthlyData = statisticsService.monthlyFinishedCounts(for: books)
    }
}
