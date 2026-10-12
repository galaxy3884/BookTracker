import Testing
import Foundation
@testable import BookTracker

@Suite("Book rules")
struct BookRulesTests {
    private let earlier = Date(timeIntervalSince1970: 1_000)
    private let now = Date(timeIntervalSince1970: 5_000)

    // MARK: status transitions

    @Test("wantToRead → reading starts the book and leaves it unfinished")
    func wantToReadToReading() {
        let book = Book(title: "T", author: "A", status: .wantToRead)

        book.transition(to: .reading, at: now)

        #expect(book.dateStarted == now)
        #expect(book.dateFinished == nil)
    }

    @Test("reading → finished keeps the start date and stamps the finish date")
    func readingToFinished() {
        let book = Book(title: "T", author: "A", status: .reading, dateStarted: earlier)

        book.transition(to: .finished, at: now)

        #expect(book.dateStarted == earlier)
        #expect(book.dateFinished == now)
    }

    @Test("wantToRead → finished never leaves the start date empty")
    func wantToReadToFinished() {
        let book = Book(title: "T", author: "A", status: .wantToRead)

        book.transition(to: .finished, at: now)

        #expect(book.dateStarted == now)
        #expect(book.dateFinished == now)
    }

    @Test(
        "leaving finished clears the finish date and keeps the start date",
        arguments: [BookStatus.wantToRead, .didNotFinish, .reading]
    )
    func leavingFinished(target: BookStatus) {
        let book = Book(title: "T", author: "A", status: .finished, dateStarted: earlier, dateFinished: now)

        book.transition(to: target, at: Date(timeIntervalSince1970: 9_000))

        #expect(book.dateFinished == nil)
        #expect(book.dateStarted == earlier)
    }

    @Test("reading → didNotFinish keeps the start date")
    func readingToDidNotFinish() {
        let book = Book(title: "T", author: "A", status: .reading, dateStarted: earlier)

        book.transition(to: .didNotFinish, at: now)

        #expect(book.dateStarted == earlier)
        #expect(book.dateFinished == nil)
    }

    @Test("re-selecting the current status does not overwrite dates")
    func sameStatusIsNoOp() {
        let book = Book(title: "T", author: "A", status: .finished, dateStarted: earlier, dateFinished: earlier)

        book.transition(to: .finished, at: now)

        #expect(book.dateFinished == earlier)
    }

    // MARK: progress

    @Test("progress is clamped to 0...1")
    func progressClamped() {
        #expect(Book(title: "T", author: "A", status: .reading, currentPage: 50, totalPages: 200).progressFraction == 0.25)
        #expect(Book(title: "T", author: "A", status: .reading, currentPage: 500, totalPages: 200).progressFraction == 1)
        #expect(Book(title: "T", author: "A", status: .reading, currentPage: -5, totalPages: 200).progressFraction == 0)
    }

    @Test("progress is nil without a usable total")
    func progressNil() {
        #expect(Book(title: "T", author: "A", status: .reading, currentPage: 5).progressFraction == nil)
        #expect(Book(title: "T", author: "A", status: .reading, currentPage: 5, totalPages: 0).progressFraction == nil)
    }

    // MARK: widget selection

    @Test("the widget shows the most recently started book being read")
    func currentlyReadingPicksLatestStart() {
        let older = Book(title: "Older", author: "A", status: .reading, dateStarted: earlier)
        let newer = Book(title: "Newer", author: "A", status: .reading, dateStarted: now)
        let finished = Book(title: "Done", author: "A", status: .finished, dateStarted: Date(timeIntervalSince1970: 9_999))

        #expect(Book.currentlyReading(in: [older, finished, newer])?.title == "Newer")
        #expect(Book.currentlyReading(in: [newer, older])?.title == "Newer")
    }

    @Test("the widget shows nothing when no book is being read")
    func currentlyReadingNone() {
        #expect(Book.currentlyReading(in: [Book(title: "T", author: "A", status: .wantToRead)]) == nil)
    }
}
