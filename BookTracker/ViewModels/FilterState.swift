import Foundation

/// Combinable library filters. Pure data + a pure function, kept separate from
/// any View or persistence concern so it can be unit-tested on its own.
struct FilterState: Equatable {
    var status: BookStatus?
    var ownedOnly: Bool = false

    func apply(to books: [Book]) -> [Book] {
        books.filter { book in
            if let status, book.status != status {
                return false
            }
            if ownedOnly && !book.isOwned {
                return false
            }
            return true
        }
    }
}
