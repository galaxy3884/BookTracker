import SwiftUI
import SwiftData

@main
struct BookTrackerApp: App {
    let modelContainer = SharedModelContainer.make()

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(modelContainer)
    }
}
