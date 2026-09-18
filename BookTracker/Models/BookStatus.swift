import Foundation

enum BookStatus: String, Codable, CaseIterable, Identifiable {
    case reading
    case finished
    case wantToRead
    case didNotFinish

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .reading: String(localized: "Читаю")
        case .finished: String(localized: "Прочитано")
        case .wantToRead: String(localized: "Хочу прочитати")
        case .didNotFinish: String(localized: "Не дочитав")
        }
    }
}
