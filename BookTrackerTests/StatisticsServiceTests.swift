import Testing
import Foundation
@testable import BookTracker

@Suite("DefaultStatisticsService")
struct StatisticsServiceTests {
    private let service = DefaultStatisticsService()

    @Test("empty library produces empty distributions")
    func emptyLibrary() {
        #expect(service.genreDistribution(for: []).isEmpty)
        #expect(service.moodDistribution(for: []).isEmpty)
        #expect(service.paceDistribution(for: []).isEmpty)

        let monthly = service.monthlyFinishedCounts(for: [])
        #expect(monthly.count == 12)
        #expect(monthly.allSatisfy { $0.count == 0 })
    }

    @Test("only finished books are counted")
    func onlyFinishedBooksCounted() {
        let reading = Book(title: "R", author: "A", status: .reading, genre: "Drama")
        let finished = Book(title: "F", author: "A", status: .finished, dateFinished: .now, genre: "Drama")

        let result = service.genreDistribution(for: [reading, finished])

        #expect(result.count == 1)
        #expect(result.first?.count == 1)
    }

    @Test("books without a genre are excluded from the genre distribution")
    func booksWithoutGenreExcluded() {
        let noGenre = Book(title: "N", author: "A", status: .finished, dateFinished: .now)
        let blankGenre = Book(title: "B", author: "A", status: .finished, dateFinished: .now, genre: "   ")

        let result = service.genreDistribution(for: [noGenre, blankGenre])

        #expect(result.isEmpty)
    }

    @Test("mood distribution groups and counts correctly")
    func moodDistributionGroups() {
        let books = [
            Book(title: "1", author: "A", status: .finished, dateFinished: .now, mood: .happy),
            Book(title: "2", author: "A", status: .finished, dateFinished: .now, mood: .happy),
            Book(title: "3", author: "A", status: .finished, dateFinished: .now, mood: .sad)
        ]

        let result = service.moodDistribution(for: books)

        #expect(result.first { $0.mood == .happy }?.count == 2)
        #expect(result.first { $0.mood == .sad }?.count == 1)
    }

    @Test("monthly finished counts cover the last 12 months and bucket the current month")
    func monthlyFinishedCounts() {
        let book = Book(title: "M", author: "A", status: .finished, dateFinished: .now)

        let result = service.monthlyFinishedCounts(for: [book])

        #expect(result.count == 12)
        #expect(result.last?.count == 1)
    }

    @Test("a finished book without dateFinished is excluded from monthly counts")
    func finishedBookWithoutDateFinishedExcluded() {
        let book = Book(title: "M", author: "A", status: .finished)

        let result = service.monthlyFinishedCounts(for: [book])

        #expect(result.allSatisfy { $0.count == 0 })
    }
}
