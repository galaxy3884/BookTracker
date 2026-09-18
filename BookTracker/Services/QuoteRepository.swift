import Foundation

protocol QuoteRepository {
    func addQuote(to book: Book, text: String, page: Int?) throws
    func delete(_ quote: Quote) throws
}
