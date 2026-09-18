import SwiftUI
import WidgetKit

struct BookTrackerWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: BookTrackerWidgetEntry

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                HStack(alignment: .top, spacing: Theme.Spacing.md) {
                    monthlyCountView
                    Divider()
                    readingView
                }
            default:
                VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                    monthlyCountView
                    Divider()
                    readingView
                }
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }

    private var monthlyCountView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(Strings.Widget.monthlyCountLabel)
                .font(.appCaption)
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
            Text("\(entry.booksFinishedThisMonth)")
                .font(.system(size: 32, weight: .bold))
                .accessibilityLabel(Strings.Widget.monthlyCountAccessibility(entry.booksFinishedThisMonth))
        }
    }

    private var readingView: some View {
        HStack(spacing: Theme.Spacing.sm) {
            if let title = entry.currentlyReadingTitle {
                BookCoverView(
                    title: title,
                    author: entry.currentlyReadingAuthor ?? "",
                    coverImageData: entry.currentlyReadingCoverData,
                    cornerRadius: Theme.CornerRadius.small
                )
                .frame(width: 28, height: 42)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(Strings.Widget.readingLabel)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .accessibilityHidden(true)
                Text(entry.currentlyReadingTitle ?? Strings.Widget.noActiveBook)
                    .font(.subheadline)
                    .lineLimit(2)
                    .accessibilityLabel(entry.currentlyReadingTitle.map(Strings.Widget.readingAccessibility) ?? Strings.Widget.noActiveBook)
            }
        }
    }
}
