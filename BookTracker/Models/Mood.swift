import Foundation

enum Mood: String, Codable, CaseIterable, Identifiable {
    case happy
    case hopeful
    case tense
    case dark
    case sad
    case light
    case neutral

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .happy: String(localized: "Радісний")
        case .hopeful: String(localized: "Обнадійливий")
        case .tense: String(localized: "Напружений")
        case .dark: String(localized: "Похмурий")
        case .sad: String(localized: "Сумний")
        case .light: String(localized: "Легкий")
        case .neutral: String(localized: "Нейтральний")
        }
    }
}
