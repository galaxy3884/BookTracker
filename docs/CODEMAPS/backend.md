<!-- Generated: 2026-09-18 | Files scanned: 49 | Token estimate: ~800 -->

# BookTracker — Service/Repository Layer

No network backend — this maps ViewModel → protocol call → concrete implementation,
the closest analog to "routes → controller → service" in this app.

## BookRepository (protocol, Services/BookRepository.swift)
Implementation: `SwiftDataBookRepository` (Services/SwiftDataBookRepository.swift)

| Method | Called from | Notable side effects |
|---|---|---|
| `addBook(title:author:status:isbn:isOwned:)` | AddBookViewModel.save() | stores canonical ISBN-13 (throws `.invalidISBN`); dates via `Book.applyDatesForCurrentStatus()` (finished ⇒ both dates set) |
| `findBook(withISBN:)` | AddBookViewModel.save() | matches ISBN-10/13 spellings via `ISBN.canonical`; duplicate ⇒ user confirms |
| `updateStatus(of:to:)` | BookDetailViewModel.changeStatus() | delegates to `Book.transition(to:)` (Models/Book+Rules.swift): same status = no-op; →reading: keeps/sets dateStarted, clears dateFinished; →finished: dateStarted kept-or-now, dateFinished = now; →wantToRead/didNotFinish: dateFinished cleared, dateStarted kept |
| `updateProgress(of:currentPage:totalPages:)` | BookDetailViewModel.commitPendingEdits() | validates (current ≥ 0, total > 0, current ≤ total) else throws `BookValidationError` |
| `updateMetadata(of:genre:mood:pace:)` | BookDetailViewModel.commitPendingEdits/commitMood/commitPace() | plain field write + save |
| `updateNotes(of:notes:)` | BookDetailViewModel.commitPendingEdits() | plain field write + save |
| `updateOwnership(of:isOwned:)` | BookDetailViewModel.commitIsOwned() | plain field write + save |
| `delete(_:)` | LibraryViewModel.delete() | `modelContext.delete` + save |

Every successful mutation calls `onDataChanged` (default `WidgetRefresher.reload` →
`WidgetCenter.reloadTimelines(ofKind: AppWidget.kind)`), so the widget updates immediately.

## QuoteRepository (protocol, Services/QuoteRepository.swift)
Implementation: `SwiftDataQuoteRepository` (Services/SwiftDataQuoteRepository.swift)

| Method | Called from |
|---|---|
| `addQuote(to:text:page:)` | BookDetailViewModel.addQuote() |
| `delete(_:)` | BookDetailViewModel.deleteQuote() |

## StatisticsService (protocol, Services/StatisticsService.swift)
Implementation: `DefaultStatisticsService` (Services/DefaultStatisticsService.swift) — pure
functions over `[Book]`, no persistence.

```
genreDistribution(for:)        -> [GenreCount]    (skips books with nil genre)
moodDistribution(for:)         -> [MoodCount]
paceDistribution(for:)         -> [PaceCount]
monthlyFinishedCounts(for:)    -> [MonthlyCount]  (last 12 months, needs dateFinished)
```
Called from `StatisticsViewModel.refresh(books:)`, which yields between each
aggregation (`Task.yield()`) to avoid blocking the view on a large library.

## LibraryExportService (protocol, Services/LibraryExportService.swift)
Implementation: `JSONLibraryExportService` — `exportLibrary(books:) -> URL`.
Encodes `ExportedBook`/`ExportedQuote` (no cover images) to a temp JSON file,
ISO8601 dates, sorted keys. Called from `SettingsViewModel.exportLibrary(books:)`,
shared via `ShareLink` — no upload, stays on-device.

## BarcodeScanningService (protocol, Services/BarcodeScanningService.swift)
Implementation: `DataScannerBarcodeScanningService` (VisionKit `DataScannerViewController`).
`isSupported` / `authorizationStatus()` / `requestCameraAccess()` /
`makeScannerViewController(onRecognize:)` → `BarcodeScanOutcome` (.isbn / .unsupportedCode /
.scanningUnavailable). Called from `ScanBarcodeViewModel`.

## ISBN (Services/ISBN.swift) — pure
`ISBN.canonical(_:)` strips spaces/hyphens, validates ISBN-10/13 checksums (13 must start 978/979),
converts ISBN-10 → ISBN-13; everything is stored/compared as canonical ISBN-13. Used by
AddBookViewModel (inline error), ScanBarcodeViewModel (scan + manual entry), repository.

## Import (Services/LibraryImportService.swift)
`JSONLibraryImportService.importLibrary(from:) -> ImportSummary(added, skipped)`: merge-only restore of an
`ExportedLibrary` (versioned, `version <= currentVersion`); duplicates (same ISBN, else same
title+author, case-insensitive) are skipped, never overwritten. Called from SettingsViewModel
(`.fileImporter`). Export now includes `isOwned` and is wrapped as `{version, exportedAt, books}`.

## Persistence bootstrap
`SharedModelContainer.make() throws` (Services/SharedModelContainer.swift) — used by the app
(`BookTrackerApp` shows `StoreUnavailableView` on failure instead of crashing) and the widget provider
(empty widget on failure). Schema = `[Book.self, Quote.self]`; the App Group container is REQUIRED
(no silent fallback to a private store, which would give app and widget different databases).

## Repository injection
All repositories/services are constructed once in `MainTabView` from
`@Environment(\.modelContext)` and passed down by initializer through
`LibraryView → BookDetailView / AddBookView / ScanBarcodeView / SettingsView →
their ViewModels`. No singletons, no service locator.
