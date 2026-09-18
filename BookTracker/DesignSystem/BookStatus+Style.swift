import SwiftUI

extension BookStatus {
    /// Semantic color for this status, defined in Assets.xcassets with light/dark variants.
    var color: Color {
        switch self {
        case .reading: Color("StatusReading")
        case .finished: Color("StatusFinished")
        case .wantToRead: Color("StatusWantToRead")
        case .didNotFinish: Color("StatusDidNotFinish")
        }
    }

    var symbolName: String {
        switch self {
        case .reading: "book.fill"
        case .finished: "checkmark.circle.fill"
        case .wantToRead: "bookmark.fill"
        case .didNotFinish: "xmark.circle.fill"
        }
    }
}
