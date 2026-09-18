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

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !author.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    init(repository: BookRepository, defaultStatus: BookStatus, prefilledISBN: String? = nil) {
        self.repository = repository
        self.status = defaultStatus
        self.isbn = prefilledISBN ?? ""
    }

    @discardableResult
    func save() -> Bool {
        guard canSave else { return false }
        let trimmedISBN = isbn.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
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
