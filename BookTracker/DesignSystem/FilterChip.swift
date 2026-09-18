import SwiftUI

/// A capsule filter toggle tinted with a semantic color, filled when selected.
struct FilterChip: View {
    let title: String
    var systemImage: String?
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.xs) {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
            }
            .font(.appBadge)
            .foregroundStyle(isSelected ? Color.white : color)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.sm)
            .background(isSelected ? color : color.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .animation(.default, value: isSelected)
    }
}
