import Foundation

// Single home for the book's state invariants (status ↔ dates ↔ progress).
extension Book {
    /// Moves the book to `newStatus` and brings the dates in line with it.
    /// Re-selecting the current status is a no-op, so it can't overwrite `dateFinished`.
    func transition(to newStatus: BookStatus, at now: Date = .now) {
        guard newStatus != status else { return }
        status = newStatus
        applyDatesForCurrentStatus(at: now)
    }

    /// Invariants per status:
    /// - reading:      started (kept if known), not finished
    /// - finished:     started (kept if known, else same instant), finished = now
    /// - wantToRead / didNotFinish: not finished; `dateStarted` is kept as history
    func applyDatesForCurrentStatus(at now: Date = .now) {
        switch status {
        case .reading:
            dateStarted = dateStarted ?? now
            dateFinished = nil
        case .finished:
            dateStarted = dateStarted ?? now
            dateFinished = now
        case .wantToRead, .didNotFinish:
            dateFinished = nil
        }
    }

    /// Reading progress clamped to 0...1, or nil when it can't be computed.
    var progressFraction: Double? {
        guard let currentPage, let totalPages, totalPages > 0 else { return nil }
        return min(max(Double(currentPage) / Double(totalPages), 0), 1)
    }

    /// The book the widget should show: the most recently started one being read.
    static func currentlyReading(in books: [Book]) -> Book? {
        books
            .filter { $0.status == .reading }
            .max { lhs, rhs in
                (lhs.dateStarted ?? lhs.dateAdded, lhs.dateAdded) < (rhs.dateStarted ?? rhs.dateAdded, rhs.dateAdded)
            }
    }
}
