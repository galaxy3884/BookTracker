import SwiftUI

/// Cover artwork for a book: the real cover image when available, otherwise a
/// deterministic colorful gradient with the book's first letter. The app is fully
/// offline and never downloads covers, so the placeholder is the common case.
struct BookCoverView: View {
    let title: String
    let author: String
    let coverImageData: Data?
    var cornerRadius: CGFloat = Theme.CornerRadius.cover

    var body: some View {
        Group {
            if let coverImageData, let uiImage = UIImage(data: coverImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                BookCoverPlaceholder(title: title, author: author)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .accessibilityHidden(true)
    }
}

struct BookCoverPlaceholder: View {
    let title: String
    let author: String

    var body: some View {
        GeometryReader { proxy in
            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                .overlay {
                    Text(initial)
                        .font(.system(size: proxy.size.height * 0.42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white.opacity(0.95))
                }
        }
    }

    private var initial: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.first.map { String($0).uppercased() } ?? "?"
    }

    /// Two hues derived from a hash of the title+author, stable across app and
    /// widget processes (unlike Swift's randomly-seeded `String.hashValue`).
    private var gradientColors: [Color] {
        let hash = Self.fnv1aHash("\(title)|\(author)")
        let hue = Double(hash % 360) / 360
        let secondHue = (hue + 0.12).truncatingRemainder(dividingBy: 1)
        return [
            Color(hue: hue, saturation: 0.55, brightness: 0.62),
            Color(hue: secondHue, saturation: 0.65, brightness: 0.46)
        ]
    }

    private static func fnv1aHash(_ string: String) -> UInt64 {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in string.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 0x100000001b3
        }
        return hash
    }
}
