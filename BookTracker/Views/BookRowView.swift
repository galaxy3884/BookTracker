import SwiftUI

struct BookRowView: View {
    let book: Book

    var body: some View {
        HStack(alignment: .center, spacing: Theme.Spacing.md) {
            coverWithOwnedBadge

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(book.title)
                    .font(.appBookTitle)
                    .lineLimit(2)
                Text(book.author)
                    .font(.appBookAuthor)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let progress {
                    ProgressView(value: progress)
                        .tint(book.status.color)
                        .padding(.top, Theme.Spacing.xs / 2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            statusBadge
        }
        .padding(.vertical, Theme.Spacing.xs)
        .accessibilityElement(children: .combine)
    }

    private var coverWithOwnedBadge: some View {
        ZStack(alignment: .bottomTrailing) {
            BookCoverView(title: book.title, author: book.author, coverImageData: book.coverImageData)
                .frame(width: 52, height: 78)

            Image(systemName: book.isOwned ? "bookmark.fill" : "bookmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(book.isOwned ? Color.accentColor : Color.secondary)
                .padding(4)
                .background(.background, in: Circle())
                .overlay(Circle().strokeBorder(.separator, lineWidth: 0.5))
                .offset(x: 4, y: 4)
                .accessibilityLabel(book.isOwned ? Strings.BookRow.ownedAccessibility : "")
                .accessibilityHidden(!book.isOwned)
        }
    }

    private var statusBadge: some View {
        HStack(spacing: Theme.Spacing.xs / 2) {
            Image(systemName: book.status.symbolName)
            Text(book.status.displayName)
        }
        .font(.appBadge)
        .foregroundStyle(book.status.color)
        .lineLimit(1)
        .fixedSize(horizontal: true, vertical: false)
        .padding(.horizontal, Theme.Spacing.sm)
        .padding(.vertical, 4)
        .background(book.status.color.opacity(0.15), in: Capsule())
    }

    private var progress: Double? {
        guard book.status == .reading, let currentPage = book.currentPage, let totalPages = book.totalPages, totalPages > 0 else {
            return nil
        }
        return Double(currentPage) / Double(totalPages)
    }
}
