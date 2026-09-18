import Foundation
import SwiftData

@Model
final class Quote {
    @Attribute(.unique) var id: UUID
    var text: String
    var page: Int?
    var dateAdded: Date
    var book: Book?

    init(text: String, page: Int? = nil, dateAdded: Date = .now, book: Book? = nil) {
        self.id = UUID()
        self.text = text
        self.page = page
        self.dateAdded = dateAdded
        self.book = book
    }
}
