import Testing
@testable import BookTracker

@Suite("ISBN")
struct ISBNTests {
    @Test("a valid ISBN-13 is returned unchanged")
    func validISBN13() {
        #expect(ISBN.canonical("9780306406157") == "9780306406157")
    }

    @Test("hyphens and spaces are ignored")
    func hyphensAndSpaces() {
        #expect(ISBN.canonical(" 978-0-306-40615-7 ") == "9780306406157")
    }

    @Test("a valid ISBN-10 is converted to ISBN-13")
    func isbn10Converts() {
        #expect(ISBN.canonical("0306406152") == "9780306406157")
    }

    @Test("an ISBN-10 ending in X is accepted, lower case too")
    func isbn10WithX() {
        #expect(ISBN.canonical("080442957X") == "9780804429573")
        #expect(ISBN.canonical("080442957x") == "9780804429573")
    }

    @Test(
        "invalid input is rejected",
        arguments: [
            "",
            "hello",
            "123",
            "9780306406158",   // wrong check digit
            "0306406153",      // wrong check digit (ISBN-10)
            "4006381333931",   // valid EAN-13, not a book prefix
            "97803064061５7"   // full-width digit
        ]
    )
    func invalid(input: String) {
        #expect(ISBN.canonical(input) == nil)
    }
}
