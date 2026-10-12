import SwiftUI

/// Shown instead of crashing when the persistent store can't be opened. It deliberately
/// offers no "reset" action, so a startup failure can never silently wipe the user's data.
struct StoreUnavailableView: View {
    let details: String

    var body: some View {
        EmptyStateView(
            systemImage: "exclamationmark.triangle",
            title: Strings.Store.unavailableTitle,
            message: "\(Strings.Store.unavailableMessage)\n\(details)"
        )
    }
}
