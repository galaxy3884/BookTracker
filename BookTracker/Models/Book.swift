import Foundation
import SwiftData

@Model
final class Book {
    @Attribute(.unique) var id: UUID
    var title: String
    var author: String
    var coverImageData: Data?
    var statusRawValue: String
    var dateAdded: Date
    var dateStarted: Date?
    var dateFinished: Date?
    var currentPage: Int?
    var totalPages: Int?
    var notes: String?
    var isbn: String?
    var genre: String?
    var mood: Mood?
    var pace: Pace?
    var isOwned: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \Quote.book)
    var quotes: [Quote] = []

    var status: BookStatus {
        get { BookStatus(rawValue: statusRawValue) ?? .wantToRead }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        title: String,
        author: String,
        status: BookStatus,
        coverImageData: Data? = nil,
        dateAdded: Date = .now,
        dateStarted: Date? = nil,
        dateFinished: Date? = nil,
        currentPage: Int? = nil,
        totalPages: Int? = nil,
        notes: String? = nil,
        isbn: String? = nil,
        genre: String? = nil,
        mood: Mood? = nil,
        pace: Pace? = nil,
        isOwned: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.author = author
        self.coverImageData = coverImageData
        self.statusRawValue = status.rawValue
        self.dateAdded = dateAdded
        self.dateStarted = dateStarted
        self.dateFinished = dateFinished
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.notes = notes
        self.isbn = isbn
        self.genre = genre
        self.mood = mood
        self.pace = pace
        self.isOwned = isOwned
    }
}
