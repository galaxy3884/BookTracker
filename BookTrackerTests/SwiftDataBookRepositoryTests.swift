import Testing
import SwiftData
import Foundation
@testable import BookTracker

@Suite("SwiftDataBookRepository")
struct SwiftDataBookRepositoryTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([Book.self, Quote.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    @Test("addBook sets dateStarted only when status is reading")
    func addBookSetsDateStartedForReading() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)

        try repository.addBook(title: "Title", author: "Author", status: .reading, isbn: nil, isOwned: false)
        try repository.addBook(title: "Title2", author: "Author2", status: .wantToRead, isbn: nil, isOwned: false)

        let books = try context.fetch(FetchDescriptor<Book>())
        let readingBook = try #require(books.first { $0.title == "Title" })
        let wantToReadBook = try #require(books.first { $0.title == "Title2" })

        #expect(readingBook.dateStarted != nil)
        #expect(wantToReadBook.dateStarted == nil)
    }

    @Test("updateStatus to reading sets dateStarted once and clears dateFinished")
    func updateStatusToReading() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let book = Book(title: "T", author: "A", status: .finished, dateFinished: .now)
        context.insert(book)

        try repository.updateStatus(of: book, to: .reading)

        #expect(book.status == .reading)
        #expect(book.dateStarted != nil)
        #expect(book.dateFinished == nil)
    }

    @Test("updateStatus to reading does not overwrite an existing dateStarted")
    func updateStatusToReadingKeepsExistingDateStarted() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let originalStart = Date(timeIntervalSince1970: 1_000)
        let book = Book(title: "T", author: "A", status: .wantToRead, dateStarted: originalStart)
        context.insert(book)

        try repository.updateStatus(of: book, to: .reading)

        #expect(book.dateStarted == originalStart)
    }

    @Test("updateStatus to finished sets dateFinished")
    func updateStatusToFinished() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let book = Book(title: "T", author: "A", status: .reading, dateStarted: .now)
        context.insert(book)

        try repository.updateStatus(of: book, to: .finished)

        #expect(book.status == .finished)
        #expect(book.dateFinished != nil)
    }

    @Test(
        "updateStatus to didNotFinish or wantToRead does not set dateFinished and keeps dateStarted",
        arguments: [BookStatus.didNotFinish, BookStatus.wantToRead]
    )
    func updateStatusToDidNotFinishOrWantToRead(status: BookStatus) throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let start = Date(timeIntervalSince1970: 500)
        let book = Book(title: "T", author: "A", status: .reading, dateStarted: start)
        context.insert(book)

        try repository.updateStatus(of: book, to: status)

        #expect(book.status == status)
        #expect(book.dateFinished == nil)
        #expect(book.dateStarted == start)
    }

    @Test("updateProgress sets currentPage and totalPages")
    func updateProgressSetsPages() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let book = Book(title: "T", author: "A", status: .reading)
        context.insert(book)

        try repository.updateProgress(of: book, currentPage: 42, totalPages: 300)

        #expect(book.currentPage == 42)
        #expect(book.totalPages == 300)
    }

    @Test("updateMetadata sets genre, mood and pace")
    func updateMetadataSetsFields() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let book = Book(title: "T", author: "A", status: .finished)
        context.insert(book)

        try repository.updateMetadata(of: book, genre: "Sci-Fi", mood: .happy, pace: .fast)

        #expect(book.genre == "Sci-Fi")
        #expect(book.mood == .happy)
        #expect(book.pace == .fast)
    }

    @Test("addBook stores the isOwned flag")
    func addBookStoresIsOwned() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)

        try repository.addBook(title: "Owned", author: "A", status: .wantToRead, isbn: nil, isOwned: true)

        let books = try context.fetch(FetchDescriptor<Book>())
        let ownedBook = try #require(books.first { $0.title == "Owned" })
        #expect(ownedBook.isOwned == true)
    }

    @Test("updateOwnership toggles isOwned")
    func updateOwnershipTogglesFlag() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let book = Book(title: "T", author: "A", status: .wantToRead, isOwned: false)
        context.insert(book)

        try repository.updateOwnership(of: book, isOwned: true)
        #expect(book.isOwned == true)

        try repository.updateOwnership(of: book, isOwned: false)
        #expect(book.isOwned == false)
    }

    @Test("delete removes the book from the store")
    func deleteRemovesBook() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let book = Book(title: "T", author: "A", status: .wantToRead)
        context.insert(book)
        try context.save()

        try repository.delete(book)

        let remaining = try context.fetch(FetchDescriptor<Book>())
        #expect(remaining.isEmpty)
    }

    // MARK: dates on creation and status changes

    @Test("addBook as finished stamps both dates so the book counts in statistics")
    func addFinishedBookStampsDates() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)

        try repository.addBook(title: "Done", author: "A", status: .finished, isbn: nil, isOwned: false)

        let book = try #require(try context.fetch(FetchDescriptor<Book>()).first)
        #expect(book.dateStarted != nil)
        #expect(book.dateFinished != nil)
    }

    @Test("re-selecting finished does not move dateFinished")
    func reselectFinishedKeepsDate() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let original = Date(timeIntervalSince1970: 1_000)
        let book = Book(title: "T", author: "A", status: .finished, dateStarted: original, dateFinished: original)
        context.insert(book)

        try repository.updateStatus(of: book, to: .finished)

        #expect(book.dateFinished == original)
    }

    @Test("finished → wantToRead clears the finish date")
    func finishedToWantToReadClearsDate() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let book = Book(title: "T", author: "A", status: .finished, dateStarted: .now, dateFinished: .now)
        context.insert(book)

        try repository.updateStatus(of: book, to: .wantToRead)

        #expect(book.dateFinished == nil)
    }

    // MARK: page validation

    @Test("updateProgress accepts a consistent pair")
    func updateProgressValid() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let book = Book(title: "T", author: "A", status: .reading)
        context.insert(book)

        try repository.updateProgress(of: book, currentPage: 300, totalPages: 300)

        #expect(book.currentPage == 300)
    }

    @Test(
        "updateProgress rejects invalid pages and leaves the book untouched",
        arguments: [
            (-1, 100, BookValidationError.negativePage),
            (10, 0, BookValidationError.nonPositiveTotalPages),
            (10, -5, BookValidationError.nonPositiveTotalPages),
            (101, 100, BookValidationError.currentPageExceedsTotal)
        ]
    )
    func updateProgressInvalid(current: Int, total: Int, expected: BookValidationError) throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let book = Book(title: "T", author: "A", status: .reading, currentPage: 5, totalPages: 50)
        context.insert(book)

        #expect(throws: expected) {
            try repository.updateProgress(of: book, currentPage: current, totalPages: total)
        }
        #expect(book.currentPage == 5)
        #expect(book.totalPages == 50)
    }

    // MARK: ISBN

    @Test("addBook stores the canonical ISBN-13")
    func addBookCanonicalISBN() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)

        try repository.addBook(title: "T", author: "A", status: .wantToRead, isbn: "0-306-40615-2", isOwned: false)

        let book = try #require(try context.fetch(FetchDescriptor<Book>()).first)
        #expect(book.isbn == "9780306406157")
    }

    @Test("addBook rejects an invalid ISBN and stores nothing")
    func addBookInvalidISBN() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)

        #expect(throws: BookValidationError.invalidISBN) {
            try repository.addBook(title: "T", author: "A", status: .wantToRead, isbn: "123", isOwned: false)
        }
        #expect(try context.fetch(FetchDescriptor<Book>()).isEmpty)
    }

    @Test("findBook matches the same ISBN written as ISBN-10 or ISBN-13")
    func findBookByISBN() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        try repository.addBook(title: "Known", author: "A", status: .wantToRead, isbn: "9780306406157", isOwned: false)
        try repository.addBook(title: "No ISBN", author: "A", status: .wantToRead, isbn: nil, isOwned: false)

        #expect(try repository.findBook(withISBN: "0306406152")?.title == "Known")
        #expect(try repository.findBook(withISBN: "978-0-306-40615-7")?.title == "Known")
        #expect(try repository.findBook(withISBN: "9780804429573") == nil)
    }

    // MARK: notes and widget refresh

    @Test("updateNotes stores and clears notes")
    func updateNotes() throws {
        let context = try makeContext()
        let repository = SwiftDataBookRepository(modelContext: context)
        let book = Book(title: "T", author: "A", status: .reading)
        context.insert(book)

        try repository.updateNotes(of: book, notes: "Great start")
        #expect(book.notes == "Great start")

        try repository.updateNotes(of: book, notes: nil)
        #expect(book.notes == nil)
    }

    @Test("every successful mutation asks the widget to refresh; a rejected one does not")
    func widgetRefreshOnMutations() throws {
        let context = try makeContext()
        var refreshCount = 0
        let repository = SwiftDataBookRepository(modelContext: context, onDataChanged: { refreshCount += 1 })

        try repository.addBook(title: "T", author: "A", status: .reading, isbn: nil, isOwned: false)
        let book = try #require(try context.fetch(FetchDescriptor<Book>()).first)
        try repository.updateStatus(of: book, to: .finished)
        try repository.updateOwnership(of: book, isOwned: true)
        try repository.delete(book)
        #expect(refreshCount == 4)

        _ = try? repository.updateProgress(of: Book(title: "X", author: "A", status: .reading), currentPage: -1, totalPages: nil)
        #expect(refreshCount == 4)
    }
}
