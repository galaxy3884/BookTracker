<!-- Generated: 2026-09-18 | Files scanned: 49 | Token estimate: ~550 -->

# BookTracker — Data Model

SwiftData only (no server DB). Schema = `[Book.self, Quote.self]`, stored in one
SQLite file in the App Group container (`SharedModelContainer.swift`), or a local
default store if the App Group is unavailable (e.g. some test/dev configs).

## Book (Models/Book.swift) — `@Model final class`

```
id            UUID (unique)
title         String
author        String
coverImageData Data?            — always nil in practice (offline app, no downloads);
                                   BookCoverView generates a placeholder instead
statusRawValue String           — backing store; `status: BookStatus` computed get/set
dateAdded     Date              = .now at creation
dateStarted   Date?             — set once when status becomes .reading
dateFinished  Date?             — set when status becomes .finished; cleared otherwise
currentPage   Int?
totalPages    Int?
notes         String?
isbn          String?
genre         String?           — free user text, NOT localized
mood          Mood?              (enum, see below)
pace          Pace?              (enum, see below)
isOwned       Bool = false      — independent of reading status (Phase 6)
quotes        [Quote]           @Relationship(deleteRule: .cascade, inverse: \Quote.book)
```

## Quote (Models/Quote.swift) — `@Model final class`
```
id         UUID (unique)
text       String
page       Int?
dateAdded  Date
book       Book?    — inverse of Book.quotes; cascade-deleted with its Book
```

## Enums (display names are `String(localized:)`, Phase 8)
```
BookStatus: reading | finished | wantToRead | didNotFinish
  .color (Asset Catalog: StatusReading/Finished/WantToRead/DidNotFinish, light+dark)
  .symbolName (SF Symbol per case)

Mood: happy | hopeful | tense | dark | sad | light | neutral
Pace: slow | medium | fast
```

## No migrations yet
Single schema version since Phase 1; `isOwned` (Phase 6) was added as a
non-optional stored property with a default value (`= false`), which SwiftData
handles as a lightweight/automatic migration — no explicit `SchemaMigrationPlan`
exists or is needed.

## Derived/DTO structs (not persisted)
- `GenreCount` / `MoodCount` / `PaceCount` / `MonthlyCount` (Services/StatisticsService.swift)
  — chart datasets computed on demand, never stored.
- `ExportedBook` / `ExportedQuote` (Services/LibraryExportService.swift) — Codable
  mirrors of Book/Quote for JSON export, deliberately excluding `coverImageData`.
