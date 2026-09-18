import Testing
import SwiftData
@testable import BookTracker

@Suite("SwiftDataQuoteRepository")
struct SwiftDataQuoteRepositoryTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([Book.self, Quote.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }

    @Test("addQuote links the quote to the book")
    func addQuoteLinksToBook() throws {
        let context = try makeContext()
        let book = Book(title: "T", author: "A", status: .reading)
        context.insert(book)
        let repository = SwiftDataQuoteRepository(modelContext: context)

        try repository.addQuote(to: book, text: "Hello", page: 12)

        #expect(book.quotes.count == 1)
        #expect(book.quotes.first?.text == "Hello")
        #expect(book.quotes.first?.page == 12)
    }

    @Test("addQuote without a page stores nil page")
    func addQuoteWithoutPage() throws {
        let context = try makeContext()
        let book = Book(title: "T", author: "A", status: .reading)
        context.insert(book)
        let repository = SwiftDataQuoteRepository(modelContext: context)

        try repository.addQuote(to: book, text: "No page", page: nil)

        #expect(book.quotes.first?.page == nil)
    }

    @Test("delete removes the quote from the book")
    func deleteRemovesQuote() throws {
        let context = try makeContext()
        let book = Book(title: "T", author: "A", status: .reading)
        context.insert(book)
        let repository = SwiftDataQuoteRepository(modelContext: context)
        try repository.addQuote(to: book, text: "Bye", page: nil)
        let quote = try #require(book.quotes.first)

        try repository.delete(quote)

        #expect(book.quotes.isEmpty)
    }
}
