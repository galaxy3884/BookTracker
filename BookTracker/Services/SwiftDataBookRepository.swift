import Foundation
import SwiftData

final class SwiftDataBookRepository: BookRepository {
    private let modelContext: ModelContext
    private let onDataChanged: () -> Void

    init(modelContext: ModelContext, onDataChanged: @escaping () -> Void = WidgetRefresher.reload) {
        self.modelContext = modelContext
        self.onDataChanged = onDataChanged
    }

    func addBook(title: String, author: String, status: BookStatus, isbn: String?, isOwned: Bool) throws {
        let storedISBN = try isbn.map { try canonicalISBN($0) }
        let book = Book(title: title, author: author, status: status, isbn: storedISBN, isOwned: isOwned)
        book.applyDatesForCurrentStatus()
        modelContext.insert(book)
        try save()
    }

    func findBook(withISBN isbn: String) throws -> Book? {
        let target = try canonicalISBN(isbn)
        let candidates = try modelContext.fetch(FetchDescriptor<Book>(predicate: #Predicate { $0.isbn != nil }))
        return candidates.first { $0.isbn.flatMap(ISBN.canonical) == target }
    }

    func updateStatus(of book: Book, to status: BookStatus) throws {
        book.transition(to: status)
        try save()
    }

    func updateProgress(of book: Book, currentPage: Int?, totalPages: Int?) throws {
        if let currentPage, currentPage < 0 { throw BookValidationError.negativePage }
        if let totalPages, totalPages <= 0 { throw BookValidationError.nonPositiveTotalPages }
        if let currentPage, let totalPages, currentPage > totalPages {
            throw BookValidationError.currentPageExceedsTotal
        }
        book.currentPage = currentPage
        book.totalPages = totalPages
        try save()
    }

    func updateMetadata(of book: Book, genre: String?, mood: Mood?, pace: Pace?) throws {
        book.genre = genre
        book.mood = mood
        book.pace = pace
        try save()
    }

    func updateNotes(of book: Book, notes: String?) throws {
        book.notes = notes
        try save()
    }

    func updateOwnership(of book: Book, isOwned: Bool) throws {
        book.isOwned = isOwned
        try save()
    }

    func delete(_ book: Book) throws {
        modelContext.delete(book)
        try save()
    }

    private func save() throws {
        try modelContext.save()
        onDataChanged()
    }

    private func canonicalISBN(_ raw: String) throws -> String {
        guard let canonical = ISBN.canonical(raw) else { throw BookValidationError.invalidISBN }
        return canonical
    }
}
