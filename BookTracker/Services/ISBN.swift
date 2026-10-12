import Foundation

/// Pure ISBN normalisation and validation. Everything is stored and compared
/// in canonical form: ISBN-13, digits only.
enum ISBN {
    /// Returns the canonical ISBN-13 for a valid ISBN-10 or ISBN-13 (spaces and
    /// hyphens ignored), or `nil` if the input isn't a valid ISBN.
    static func canonical(_ raw: String) -> String? {
        let cleaned = raw.uppercased().filter { !$0.isWhitespace && $0 != "-" }
        switch cleaned.count {
        case 10:
            guard isValidISBN10(cleaned) else { return nil }
            return isbn13(fromValidISBN10: cleaned)
        case 13:
            return isValidISBN13(cleaned) ? cleaned : nil
        default:
            return nil
        }
    }

    private static func isValidISBN13(_ value: String) -> Bool {
        let digits = value.compactMap(asciiDigit)
        guard digits.count == 13, value.hasPrefix("978") || value.hasPrefix("979") else { return false }
        let sum = digits.enumerated().reduce(0) { $0 + $1.element * ($1.offset.isMultiple(of: 2) ? 1 : 3) }
        return sum % 10 == 0
    }

    private static func isValidISBN10(_ value: String) -> Bool {
        let characters = Array(value)
        var sum = 0
        for (index, character) in characters.enumerated() {
            let digit: Int
            if index == 9, character == "X" {
                digit = 10
            } else if let parsed = asciiDigit(character) {
                digit = parsed
            } else {
                return false
            }
            sum += digit * (10 - index)
        }
        return sum % 11 == 0
    }

    private static func isbn13(fromValidISBN10 value: String) -> String {
        let body = "978" + value.prefix(9)
        let sum = body.compactMap(asciiDigit).enumerated().reduce(0) {
            $0 + $1.element * ($1.offset.isMultiple(of: 2) ? 1 : 3)
        }
        return body + String((10 - sum % 10) % 10)
    }

    private static func asciiDigit(_ character: Character) -> Int? {
        guard let scalar = character.unicodeScalars.first, character.unicodeScalars.count == 1,
              ("0"..."9").contains(scalar) else { return nil }
        return Int(scalar.value - 48)
    }
}

enum BookValidationError: LocalizedError, Equatable {
    case negativePage
    case nonPositiveTotalPages
    case currentPageExceedsTotal
    case invalidISBN

    var errorDescription: String? {
        switch self {
        case .negativePage: Strings.Validation.negativePage
        case .nonPositiveTotalPages: Strings.Validation.nonPositiveTotalPages
        case .currentPageExceedsTotal: Strings.Validation.currentPageExceedsTotal
        case .invalidISBN: Strings.Validation.invalidISBN
        }
    }
}
