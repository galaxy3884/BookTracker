import Foundation

@Observable
final class LibraryViewModel {
    private let repository: BookRepository
    var filterState = FilterState()
    var errorMessage: String?

    init(repository: BookRepository) {
        self.repository = repository
    }

    func resetFilters() {
        filterState = FilterState()
    }

    func delete(_ book: Book) {
        do {
            try repository.delete(book)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
