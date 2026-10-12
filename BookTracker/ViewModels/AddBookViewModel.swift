import Foundation

@Observable
final class AddBookViewModel {
    private let repository: BookRepository
    var title: String = ""
    var author: String = ""
    var status: BookStatus
    var isbn: String
    var isOwned: Bool = false
    var errorMessage: String?
    var duplicateBookTitle: String?

    private var trimmedISBN: String {
        isbn.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var isbnError: String? {
        if trimmedISBN.isEmpty || ISBN.canonical(trimmedISBN) != nil {
            return nil
        }
        return Strings.Validation.invalidISBN
    }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        isbnError == nil
    }

    init(repository: BookRepository, defaultStatus: BookStatus, prefilledISBN: String? = nil) {
        self.repository = repository
        self.status = defaultStatus
        self.isbn = prefilledISBN ?? ""
    }

    /// Returns `true` when the book was saved. If a book with the same ISBN already exists the
    /// save is held back and `duplicateBookTitle` is set, so the user can confirm with `allowDuplicate`.
    @discardableResult
    func save(allowDuplicate: Bool = false) -> Bool {
        guard canSave else { return false }
        do {
            if !allowDuplicate, !trimmedISBN.isEmpty, let existing = try repository.findBook(withISBN: trimmedISBN) {
                duplicateBookTitle = existing.title
                return false
            }
            try repository.addBook(
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                author: author.trimmingCharacters(in: .whitespacesAndNewlines),
                status: status,
                isbn: trimmedISBN.isEmpty ? nil : trimmedISBN,
                isOwned: isOwned
            )
            return true
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
