import SwiftUI

/// Reusable empty state: icon, title, message and up to two action buttons.
/// Used across the Library screen (empty library / empty filter result) and Statistics cards.
struct EmptyStateView: View {
    let systemImage: String
    let title: String
    let message: String
    var primaryAction: (title: String, action: () -> Void)?
    var secondaryAction: (title: String, action: () -> Void)?

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            Image(systemName: systemImage)
                .font(.system(size: 36))
                .foregroundStyle(Color.accentColor)
                .frame(width: 88, height: 88)
                .background(Color.accentColor.opacity(0.12), in: Circle())

            VStack(spacing: Theme.Spacing.xs) {
                Text(title)
                    .font(.appSectionHeader)
                Text(message)
                    .font(.appBookAuthor)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            if let primaryAction {
                Button(primaryAction.title, action: primaryAction.action)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, Theme.Spacing.xs)
            }
            if let secondaryAction {
                Button(secondaryAction.title, action: secondaryAction.action)
                    .buttonStyle(.bordered)
            }
        }
        .padding(Theme.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
