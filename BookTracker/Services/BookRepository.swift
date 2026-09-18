import Foundation

protocol BookRepository {
    func addBook(title: String, author: String, status: BookStatus, isbn: String?, isOwned: Bool) throws
    func updateStatus(of book: Book, to status: BookStatus) throws
    func updateProgress(of book: Book, currentPage: Int?, totalPages: Int?) throws
    func updateMetadata(of book: Book, genre: String?, mood: Mood?, pace: Pace?) throws
    func updateOwnership(of book: Book, isOwned: Bool) throws
    func delete(_ book: Book) throws
}
