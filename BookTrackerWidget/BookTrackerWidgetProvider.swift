import Foundation
import SwiftData
import WidgetKit

struct BookTrackerWidgetEntry: TimelineEntry {
    let date: Date
    let booksFinishedThisMonth: Int
    let currentlyReadingTitle: String?
    let currentlyReadingAuthor: String?
    let currentlyReadingCoverData: Data?
}

struct BookTrackerWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> BookTrackerWidgetEntry {
        BookTrackerWidgetEntry(
            date: .now,
            booksFinishedThisMonth: 3,
            currentlyReadingTitle: Strings.Widget.placeholderTitle,
            currentlyReadingAuthor: nil,
            currentlyReadingCoverData: nil
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BookTrackerWidgetEntry) -> Void) {
        completion(currentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BookTrackerWidgetEntry>) -> Void) {
        let entry = currentEntry()
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 6, to: .now) ?? .now.addingTimeInterval(6 * 3600)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }

    private func currentEntry() -> BookTrackerWidgetEntry {
        let container = SharedModelContainer.make()
        let context = ModelContext(container)
        let books = (try? context.fetch(FetchDescriptor<Book>())) ?? []

        let calendar = Calendar.current
        let now = Date.now
        let finishedThisMonth = books.filter { book in
            book.status == .finished
                && book.dateFinished.map { calendar.isDate($0, equalTo: now, toGranularity: .month) } == true
        }.count

        let readingBook = books.first { $0.status == .reading }

        return BookTrackerWidgetEntry(
            date: now,
            booksFinishedThisMonth: finishedThisMonth,
            currentlyReadingTitle: readingBook?.title,
            currentlyReadingAuthor: readingBook?.author,
            currentlyReadingCoverData: readingBook?.coverImageData
        )
    }
}
