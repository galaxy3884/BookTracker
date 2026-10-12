import SwiftUI
import SwiftData

@main
struct BookTrackerApp: App {
    private let container: Result<ModelContainer, Error> = Result { try SharedModelContainer.make() }

    var body: some Scene {
        WindowGroup {
            switch container {
            case .success(let container):
                MainTabView()
                    .modelContainer(container)
            case .failure(let error):
                StoreUnavailableView(details: error.localizedDescription)
            }
        }
    }
}
