import Foundation
import SwiftData

struct ImportSummary: Equatable {
    let added: Int
    let skipped: Int
}

enum LibraryImportError: LocalizedError {
    case notABackup
    case newerVersion

    var errorDescription: String? {
        switch self {
        case .notABackup: Strings.Import.notABackup
        case .newerVersion: Strings.Import.newerVersion
        }
    }
}

protocol LibraryImportService {
    func importLibrary(from url: URL) throws -> ImportSummary
}

/// Merge-only restore: books already in the library (same ISBN, or same title + author) are
/// skipped, never overwritten, so an import can't destroy existing data.
final class JSONLibraryImportService: LibraryImportService {
    private let modelContext: ModelContext
    private let onDataChanged: () -> Void

    init(modelContext: ModelContext, onDataChanged: @escaping () -> Void = WidgetRefresher.reload) {
        self.modelContext = modelContext
        self.onDataChanged = onDataChanged
    }

    func importLibrary(from url: URL) throws -> ImportSummary {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let library: ExportedLibrary
        do {
            library = try decoder.decode(ExportedLibrary.self, from: Data(contentsOf: url))
        } catch {
            throw LibraryImportError.notABackup
        }
        guard library.version <= ExportedLibrary.currentVersion else { throw LibraryImportError.newerVersion }

        var known = try modelContext.fetch(FetchDescriptor<Book>()).map { fingerprint(for: $0) }
        var added = 0
        var skipped = 0
        for exported in library.books {
            let candidate = fingerprint(for: exported)
            if known.contains(where: { $0.matches(candidate) }) {
                skipped += 1
                continue
            }
            modelContext.insert(makeBook(from: exported))
            known.append(candidate)
            added += 1
        }
        try modelContext.save()
        if added > 0 { onDataChanged() }
        return ImportSummary(added: added, skipped: skipped)
    }

    private struct Fingerprint {
        let isbn: String?
        let titleAuthor: String

        func matches(_ other: Fingerprint) -> Bool {
            if let isbn, let otherISBN = other.isbn { return isbn == otherISBN }
            return titleAuthor == other.titleAuthor
        }
    }

    private func fingerprint(for book: Book) -> Fingerprint {
        fingerprint(title: book.title, author: book.author, isbn: book.isbn)
    }

    private func fingerprint(for book: ExportedBook) -> Fingerprint {
        fingerprint(title: book.title, author: book.author, isbn: book.isbn)
    }

    private func fingerprint(title: String, author: String, isbn: String?) -> Fingerprint {
        Fingerprint(
            isbn: isbn.flatMap(ISBN.canonical),
            titleAuthor: "\(title)|\(author)".trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        )
    }

    private func makeBook(from exported: ExportedBook) -> Book {
        let book = Book(
            title: exported.title,
            author: exported.author,
            status: BookStatus(rawValue: exported.status) ?? .wantToRead,
            dateAdded: exported.dateAdded,
            dateStarted: exported.dateStarted,
            dateFinished: exported.dateFinished,
            currentPage: exported.currentPage,
            totalPages: exported.totalPages,
            notes: exported.notes,
            isbn: exported.isbn.flatMap(ISBN.canonical),
            genre: exported.genre,
            mood: exported.mood.flatMap(Mood.init(rawValue:)),
            pace: exported.pace.flatMap(Pace.init(rawValue:)),
            isOwned: exported.isOwned
        )
        book.quotes = exported.quotes.map { Quote(text: $0.text, page: $0.page, dateAdded: $0.dateAdded) }
        return book
    }
}
