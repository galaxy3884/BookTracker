import Foundation
import SwiftData

final class SwiftDataBookRepository: BookRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addBook(title: String, author: String, status: BookStatus, isbn: String?, isOwned: Bool) throws {
        let book = Book(title: title, author: author, status: status, isbn: isbn, isOwned: isOwned)
        if status == .reading {
            book.dateStarted = .now
        }
        modelContext.insert(book)
        try modelContext.save()
    }

    func updateStatus(of book: Book, to status: BookStatus) throws {
        book.status = status
        switch status {
        case .reading:
            if book.dateStarted == nil {
                book.dateStarted = .now
            }
            book.dateFinished = nil
        case .finished:
            book.dateFinished = .now
        case .didNotFinish, .wantToRead:
            break
        }
        try modelContext.save()
    }

    func updateProgress(of book: Book, currentPage: Int?, totalPages: Int?) throws {
        book.currentPage = currentPage
        book.totalPages = totalPages
        try modelContext.save()
    }

    func updateMetadata(of book: Book, genre: String?, mood: Mood?, pace: Pace?) throws {
        book.genre = genre
        book.mood = mood
        book.pace = pace
        try modelContext.save()
    }

    func updateOwnership(of book: Book, isOwned: Bool) throws {
        book.isOwned = isOwned
        try modelContext.save()
    }

    func delete(_ book: Book) throws {
        modelContext.delete(book)
        try modelContext.save()
    }
}
