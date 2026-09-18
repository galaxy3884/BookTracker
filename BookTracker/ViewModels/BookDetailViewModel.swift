import Foundation

@Observable
final class BookDetailViewModel {
    private let repository: BookRepository
    private let quoteRepository: QuoteRepository
    var book: Book
    var errorMessage: String?
    var currentPageInput: String
    var totalPagesInput: String
    var genreInput: String
    var mood: Mood?
    var pace: Pace?
    var isOwned: Bool
    var newQuoteText: String = ""
    var newQuotePageInput: String = ""

    init(book: Book, repository: BookRepository, quoteRepository: QuoteRepository) {
        self.book = book
        self.repository = repository
        self.quoteRepository = quoteRepository
        self.currentPageInput = book.currentPage.map(String.init) ?? ""
        self.totalPagesInput = book.totalPages.map(String.init) ?? ""
        self.genreInput = book.genre ?? ""
        self.mood = book.mood
        self.pace = book.pace
        self.isOwned = book.isOwned
    }

    func changeStatus(to status: BookStatus) {
        do {
            try repository.updateStatus(of: book, to: status)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func commitCurrentPage() {
        updateProgress(currentPage: Int(currentPageInput), totalPages: book.totalPages)
    }

    func commitTotalPages() {
        updateProgress(currentPage: book.currentPage, totalPages: Int(totalPagesInput))
    }

    func commitGenre() {
        let trimmed = genreInput.trimmingCharacters(in: .whitespacesAndNewlines)
        updateMetadata(genre: trimmed.isEmpty ? nil : trimmed, mood: book.mood, pace: book.pace)
    }

    func commitMood() {
        updateMetadata(genre: book.genre, mood: mood, pace: book.pace)
    }

    func commitPace() {
        updateMetadata(genre: book.genre, mood: book.mood, pace: pace)
    }

    func commitIsOwned() {
        do {
            try repository.updateOwnership(of: book, isOwned: isOwned)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addQuote() {
        let trimmedText = newQuoteText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        do {
            try quoteRepository.addQuote(to: book, text: trimmedText, page: Int(newQuotePageInput))
            newQuoteText = ""
            newQuotePageInput = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func deleteQuote(_ quote: Quote) {
        do {
            try quoteRepository.delete(quote)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateProgress(currentPage: Int?, totalPages: Int?) {
        do {
            try repository.updateProgress(of: book, currentPage: currentPage, totalPages: totalPages)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func updateMetadata(genre: String?, mood: Mood?, pace: Pace?) {
        do {
            try repository.updateMetadata(of: book, genre: genre, mood: mood, pace: pace)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
