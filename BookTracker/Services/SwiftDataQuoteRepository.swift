import Foundation
import SwiftData

final class SwiftDataQuoteRepository: QuoteRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func addQuote(to book: Book, text: String, page: Int?) throws {
        let quote = Quote(text: text, page: page, book: book)
        modelContext.insert(quote)
        try modelContext.save()
    }

    func delete(_ quote: Quote) throws {
        modelContext.delete(quote)
        try modelContext.save()
    }
}
