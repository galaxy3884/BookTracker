import Testing
import SwiftData
import Foundation
@testable import BookTracker

@Suite("Library export / import")
struct LibraryExportImportTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([Book.self, Quote.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return ModelContext(try ModelContainer(for: schema, configurations: [configuration]))
    }

    private func decodeExport(at url: URL) throws -> ExportedLibrary {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(ExportedLibrary.self, from: Data(contentsOf: url))
    }

    private func sampleBook() -> Book {
        let book = Book(
            title: "Dune",
            author: "Frank Herbert",
            status: .finished,
            dateAdded: Date(timeIntervalSince1970: 1_000),
            dateStarted: Date(timeIntervalSince1970: 2_000),
            dateFinished: Date(timeIntervalSince1970: 3_000),
            currentPage: 600,
            totalPages: 600,
            notes: "Classic",
            isbn: "9780306406157",
            genre: "Sci-Fi",
            mood: .tense,
            pace: .slow,
            isOwned: true
        )
        book.quotes = [Quote(text: "Fear is the mind-killer", page: 12, dateAdded: Date(timeIntervalSince1970: 2_500))]
        return book
    }

    @Test("the export is versioned and carries every meaningful field, including isOwned")
    func exportIsComplete() throws {
        let url = try JSONLibraryExportService().exportLibrary(books: [sampleBook()])
        defer { try? FileManager.default.removeItem(at: url) }

        let library = try decodeExport(at: url)
        let exported = try #require(library.books.first)

        #expect(library.version == ExportedLibrary.currentVersion)
        #expect(exported.isOwned == true)
        #expect(exported.notes == "Classic")
        #expect(exported.mood == "tense")
        #expect(exported.quotes.count == 1)
    }

    @Test("export → import into an empty library restores everything")
    func roundTrip() throws {
        let url = try JSONLibraryExportService().exportLibrary(books: [sampleBook()])
        defer { try? FileManager.default.removeItem(at: url) }
        let context = try makeContext()

        let summary = try JSONLibraryImportService(modelContext: context, onDataChanged: {}).importLibrary(from: url)

        let restored = try #require(try context.fetch(FetchDescriptor<Book>()).first)
        #expect(summary == ImportSummary(added: 1, skipped: 0))
        #expect(restored.title == "Dune")
        #expect(restored.status == .finished)
        #expect(restored.isOwned == true)
        #expect(restored.mood == .tense)
        #expect(restored.pace == .slow)
        #expect(restored.dateFinished == Date(timeIntervalSince1970: 3_000))
        #expect(restored.quotes.map(\.text) == ["Fear is the mind-killer"])
    }

    @Test("importing the same file twice skips duplicates instead of doubling the library")
    func importTwiceSkips() throws {
        let url = try JSONLibraryExportService().exportLibrary(books: [sampleBook()])
        defer { try? FileManager.default.removeItem(at: url) }
        let context = try makeContext()
        let service = JSONLibraryImportService(modelContext: context, onDataChanged: {})

        _ = try service.importLibrary(from: url)
        let second = try service.importLibrary(from: url)

        #expect(second == ImportSummary(added: 0, skipped: 1))
        #expect(try context.fetch(FetchDescriptor<Book>()).count == 1)
    }

    @Test("books without an ISBN are matched by title and author")
    func matchesByTitleAndAuthor() throws {
        let context = try makeContext()
        context.insert(Book(title: "  the hobbit ", author: "J.R.R. Tolkien", status: .wantToRead))
        let incoming = Book(title: "The Hobbit", author: "j.r.r. tolkien", status: .reading)
        let url = try JSONLibraryExportService().exportLibrary(books: [incoming])
        defer { try? FileManager.default.removeItem(at: url) }

        let summary = try JSONLibraryImportService(modelContext: context, onDataChanged: {}).importLibrary(from: url)

        #expect(summary == ImportSummary(added: 0, skipped: 1))
    }

    @Test("a file that isn't a backup is rejected without touching the library")
    func rejectsGarbage() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("not-a-backup-\(UUID().uuidString).json")
        try Data("[1, 2, 3]".utf8).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let context = try makeContext()

        #expect(throws: LibraryImportError.self) {
            try JSONLibraryImportService(modelContext: context, onDataChanged: {}).importLibrary(from: url)
        }
        #expect(try context.fetch(FetchDescriptor<Book>()).isEmpty)
    }

    @Test("a backup from a newer app version is rejected")
    func rejectsNewerVersion() throws {
        let newer = ExportedLibrary(version: ExportedLibrary.currentVersion + 1, exportedAt: .now, books: [])
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("newer-\(UUID().uuidString).json")
        try encoder.encode(newer).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(throws: LibraryImportError.self) {
            try JSONLibraryImportService(modelContext: try makeContext(), onDataChanged: {}).importLibrary(from: url)
        }
    }
}
