import SwiftUI

/// Spacing, corner radius and typography tokens shared by every screen (app + widget).
enum Theme {
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
    }

    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let cover: CGFloat = 8
        static let coverHero: CGFloat = 20
    }
}

extension Font {
    static var appTitle: Font { .largeTitle.weight(.bold) }
    static var appBookHeroTitle: Font { .title2.weight(.bold) }
    static var appSectionHeader: Font { .headline }
    static var appBody: Font { .body }
    static var appBookTitle: Font { .body.weight(.semibold) }
    static var appBookAuthor: Font { .subheadline }
    static var appBadge: Font { .caption.weight(.semibold) }
    static var appCaption: Font { .caption }
}
