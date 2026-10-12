import Testing
import SwiftData
import Foundation
@testable import BookTracker

@Suite("ViewModels")
struct ViewModelTests {
    private func makeContext() throws -> ModelContext {
        let schema = Schema([Book.self, Quote.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return ModelContext(try ModelContainer(for: schema, configurations: [configuration]))
    }

    private func makeRepository(_ context: ModelContext) -> SwiftDataBookRepository {
        SwiftDataBookRepository(modelContext: context, onDataChanged: {})
    }

    // MARK: AddBookViewModel

    @Test("an invalid ISBN blocks saving and explains why; an empty one is fine")
    func addBookISBNValidation() throws {
        let viewModel = AddBookViewModel(repository: makeRepository(try makeContext()), defaultStatus: .wantToRead)
        viewModel.title = "T"
        viewModel.author = "A"

        viewModel.isbn = ""
        #expect(viewModel.canSave)

        viewModel.isbn = "12345"
        #expect(!viewModel.canSave)
        #expect(viewModel.isbnError != nil)

        viewModel.isbn = "978-0-306-40615-7"
        #expect(viewModel.canSave)
    }

    @Test("adding a book whose ISBN already exists is held back until the user confirms")
    func addBookDuplicateFlow() throws {
        let context = try makeContext()
        let repository = makeRepository(context)
        try repository.addBook(title: "Original", author: "A", status: .wantToRead, isbn: "9780306406157", isOwned: false)
        let viewModel = AddBookViewModel(repository: repository, defaultStatus: .wantToRead)
        viewModel.title = "Copy"
        viewModel.author = "A"
        viewModel.isbn = "0306406152"

        #expect(viewModel.save() == false)
        #expect(viewModel.duplicateBookTitle == "Original")
        #expect(try context.fetch(FetchDescriptor<Book>()).count == 1)

        #expect(viewModel.save(allowDuplicate: true))
        #expect(try context.fetch(FetchDescriptor<Book>()).count == 2)
    }

    // MARK: BookDetailViewModel

    private func makeDetail(_ context: ModelContext, book: Book) -> BookDetailViewModel {
        BookDetailViewModel(
            book: book,
            repository: makeRepository(context),
            quoteRepository: SwiftDataQuoteRepository(modelContext: context)
        )
    }

    @Test("text edits are written once via commitPendingEdits, and only when they changed")
    func commitPendingEdits() throws {
        let context = try makeContext()
        let book = Book(title: "T", author: "A", status: .reading)
        context.insert(book)
        let viewModel = makeDetail(context, book: book)

        viewModel.currentPageInput = "42"
        viewModel.totalPagesInput = "300"
        viewModel.genreInput = "  Fantasy  "
        viewModel.notesInput = "Nice"
        #expect(book.currentPage == nil)   // nothing is saved while typing

        viewModel.commitPendingEdits()

        #expect(book.currentPage == 42)
        #expect(book.totalPages == 300)
        #expect(book.genre == "Fantasy")
        #expect(book.notes == "Nice")
    }

    @Test("clearing a field clears the stored value")
    func clearingFields() throws {
        let context = try makeContext()
        let book = Book(title: "T", author: "A", status: .reading, currentPage: 10, totalPages: 100, notes: "x", genre: "G")
        context.insert(book)
        let viewModel = makeDetail(context, book: book)

        viewModel.currentPageInput = ""
        viewModel.genreInput = ""
        viewModel.notesInput = ""
        viewModel.commitPendingEdits()

        #expect(book.currentPage == nil)
        #expect(book.genre == nil)
        #expect(book.notes == nil)
    }

    @Test("an invalid page pair is rejected, reported, and the fields revert")
    func invalidPagesRevert() throws {
        let context = try makeContext()
        let book = Book(title: "T", author: "A", status: .reading, currentPage: 10, totalPages: 100)
        context.insert(book)
        let viewModel = makeDetail(context, book: book)

        viewModel.currentPageInput = "500"
        viewModel.commitPendingEdits()

        #expect(book.currentPage == 10)
        #expect(viewModel.currentPageInput == "10")
        #expect(viewModel.errorMessage != nil)
    }
}
