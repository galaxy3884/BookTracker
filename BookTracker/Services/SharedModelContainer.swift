import Foundation
import SwiftData

enum AppWidget {
    static let kind = "BookTrackerWidget"
}

enum SharedModelContainer {
    static let appGroupID = "group.com.olegvornicesku.BookTracker"

    enum StoreError: LocalizedError {
        case appGroupUnavailable

        var errorDescription: String? {
            switch self {
            case .appGroupUnavailable: Strings.Store.appGroupUnavailable
            }
        }
    }

    /// The app and the widget must read the same store, so the App Group container is
    /// mandatory: a silent fallback to a private store would give each process its own
    /// (diverging) database.
    static func make() throws -> ModelContainer {
        guard let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) else {
            throw StoreError.appGroupUnavailable
        }
        let schema = Schema([Book.self, Quote.self])
        let storeURL = groupURL.appendingPathComponent("BookTracker.sqlite")
        let configuration = ModelConfiguration(schema: schema, url: storeURL)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
