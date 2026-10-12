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
    var notesInput: String
    var mood: Mood?
    var pace: Pace?
    var isOwned: Bool
    var newQuoteText: String = ""
    var newQuotePageInput: String = ""

    init(book: Book, repository: BookRepository, quoteRepository: QuoteRepository) {
        self.book = book
        self.repository = repository
        self.quoteRepository = quoteRepository
        self.currentPageInput = ""
        self.totalPagesInput = ""
        self.genreInput = ""
        self.notesInput = ""
        self.mood = book.mood
        self.pace = book.pace
        self.isOwned = book.isOwned
        syncTextInputs()
    }

    func changeStatus(to status: BookStatus) {
        do {
            try repository.updateStatus(of: book, to: status)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Text fields are edited locally and written once, when editing ends (focus leaves the
    /// field or the screen closes) — not on every keystroke.
    func commitPendingEdits() {
        commitPages()
        commitGenre()
        commitNotes()
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

    private func commitPages() {
        guard currentPageInput != Self.text(for: book.currentPage) || totalPagesInput != Self.text(for: book.totalPages) else {
            return
        }
        guard let current = Self.parsePage(currentPageInput), let total = Self.parsePage(totalPagesInput) else {
            syncTextInputs()
            return
        }
        do {
            try repository.updateProgress(of: book, currentPage: current.value, totalPages: total.value)
        } catch {
            errorMessage = error.localizedDescription
            syncTextInputs()
        }
    }

    private func commitGenre() {
        let trimmed = genreInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != (book.genre ?? "") else { return }
        updateMetadata(genre: trimmed.isEmpty ? nil : trimmed, mood: book.mood, pace: book.pace)
    }

    private func commitNotes() {
        let trimmed = notesInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed != (book.notes ?? "") else { return }
        do {
            try repository.updateNotes(of: book, notes: trimmed.isEmpty ? nil : trimmed)
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

    private func syncTextInputs() {
        currentPageInput = Self.text(for: book.currentPage)
        totalPagesInput = Self.text(for: book.totalPages)
        genreInput = book.genre ?? ""
        notesInput = book.notes ?? ""
    }

    private static func text(for page: Int?) -> String {
        page.map(String.init) ?? ""
    }

    private struct PageInput {
        let value: Int?
    }

    /// `nil` = not a number; otherwise the parsed input (`value == nil` means an empty field).
    private static func parsePage(_ text: String) -> PageInput? {
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return PageInput(value: nil) }
        guard let value = Int(trimmed) else { return nil }
        return PageInput(value: value)
    }
}
