import SwiftUI

struct StatisticsCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text(title)
                .font(.appSectionHeader)
            content()
        }
        .padding(Theme.Spacing.md)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: Theme.CornerRadius.large))
    }
}

struct StatisticsEmptyState: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.appBookAuthor)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 80)
    }
}
