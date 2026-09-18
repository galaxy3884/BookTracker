import Testing
@testable import BookTracker

@Suite("FilterState")
struct FilterStateTests {
    @Test("no filters returns every book unchanged")
    func noFilters() {
        let books = [
            Book(title: "A", author: "X", status: .reading),
            Book(title: "B", author: "Y", status: .finished, isOwned: true)
        ]

        let result = FilterState().apply(to: books)

        #expect(result.count == 2)
    }

    @Test("status filter narrows to the matching status only")
    func statusFilter() {
        let reading = Book(title: "A", author: "X", status: .reading)
        let finished = Book(title: "B", author: "Y", status: .finished)
        var state = FilterState()
        state.status = .reading

        let result = state.apply(to: [reading, finished])

        #expect(result.count == 1)
        #expect(result.first?.title == "A")
    }

    @Test("ownedOnly filter narrows to owned books only")
    func ownedOnlyFilter() {
        let owned = Book(title: "A", author: "X", status: .reading, isOwned: true)
        let notOwned = Book(title: "B", author: "Y", status: .reading, isOwned: false)
        var state = FilterState()
        state.ownedOnly = true

        let result = state.apply(to: [owned, notOwned])

        #expect(result.count == 1)
        #expect(result.first?.title == "A")
    }

    @Test("status and ownedOnly filters combine with AND semantics")
    func combinedFilters() {
        let match = Book(title: "A", author: "X", status: .wantToRead, isOwned: true)
        let wrongStatus = Book(title: "B", author: "Y", status: .reading, isOwned: true)
        let notOwned = Book(title: "C", author: "Z", status: .wantToRead, isOwned: false)
        var state = FilterState()
        state.status = .wantToRead
        state.ownedOnly = true

        let result = state.apply(to: [match, wrongStatus, notOwned])

        #expect(result.count == 1)
        #expect(result.first?.title == "A")
    }

    @Test("filtering an empty library always yields an empty result")
    func emptyLibrary() {
        var state = FilterState()
        state.status = .finished
        state.ownedOnly = true

        #expect(state.apply(to: []).isEmpty)
    }
}
