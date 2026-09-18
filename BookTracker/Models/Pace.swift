import Foundation

enum Pace: String, Codable, CaseIterable, Identifiable {
    case slow
    case medium
    case fast

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .slow: String(localized: "Повільний")
        case .medium: String(localized: "Середній")
        case .fast: String(localized: "Швидкий")
        }
    }
}
