import Foundation
import SwiftData

enum SharedModelContainer {
    static let appGroupID = "group.com.olegvornicesku.BookTracker"

    static func make() -> ModelContainer {
        let schema = Schema([Book.self, Quote.self])
        let configuration: ModelConfiguration
        if let groupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID) {
            let storeURL = groupURL.appendingPathComponent("BookTracker.sqlite")
            configuration = ModelConfiguration(schema: schema, url: storeURL)
        } else {
            configuration = ModelConfiguration(schema: schema)
        }
        return try! ModelContainer(for: schema, configurations: [configuration])
    }
}
