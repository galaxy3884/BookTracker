import Foundation

struct ExportedQuote: Codable {
    let text: String
    let page: Int?
    let dateAdded: Date
}

struct ExportedBook: Codable {
    let title: String
    let author: String
    let status: String
    let isbn: String?
    let genre: String?
    let mood: String?
    let pace: String?
    let dateAdded: Date
    let dateStarted: Date?
    let dateFinished: Date?
    let currentPage: Int?
    let totalPages: Int?
    let notes: String?
    let quotes: [ExportedQuote]
}

protocol LibraryExportService {
    func exportLibrary(books: [Book]) throws -> URL
}

final class JSONLibraryExportService: LibraryExportService {
    func exportLibrary(books: [Book]) throws -> URL {
        let exportedBooks = books.map { book in
            ExportedBook(
                title: book.title,
                author: book.author,
                status: book.status.rawValue,
                isbn: book.isbn,
                genre: book.genre,
                mood: book.mood?.rawValue,
                pace: book.pace?.rawValue,
                dateAdded: book.dateAdded,
                dateStarted: book.dateStarted,
                dateFinished: book.dateFinished,
                currentPage: book.currentPage,
                totalPages: book.totalPages,
                notes: book.notes,
                quotes: book.quotes.map { ExportedQuote(text: $0.text, page: $0.page, dateAdded: $0.dateAdded) }
            )
        }

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let data = try encoder.encode(exportedBooks)

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("book-tracker-export-\(Int(Date.now.timeIntervalSince1970))")
            .appendingPathExtension("json")
        try data.write(to: url, options: .atomic)
        return url
    }
}
