<!-- Generated: 2026-09-18 | Files scanned: 49 | Token estimate: ~800 -->

# BookTracker — Service/Repository Layer

No network backend — this maps ViewModel → protocol call → concrete implementation,
the closest analog to "routes → controller → service" in this app.

## BookRepository (protocol, Services/BookRepository.swift)
Implementation: `SwiftDataBookRepository` (Services/SwiftDataBookRepository.swift)

| Method | Called from | Notable side effects |
|---|---|---|
| `addBook(title:author:status:isbn:isOwned:)` | AddBookViewModel.save() | sets `dateStarted` if status == .reading |
| `updateStatus(of:to:)` | BookDetailViewModel.changeStatus() | reading→sets dateStarted (once); finished→sets dateFinished; leaving finished clears dateFinished |
| `updateProgress(of:currentPage:totalPages:)` | BookDetailViewModel.commitCurrentPage/commitTotalPages() | plain field write + save |
| `updateMetadata(of:genre:mood:pace:)` | BookDetailViewModel.commitGenre/commitMood/commitPace() | plain field write + save |
| `updateOwnership(of:isOwned:)` | BookDetailViewModel.commitIsOwned() | plain field write + save |
| `delete(_:)` | LibraryViewModel.delete() | `modelContext.delete` + save |

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

## Persistence bootstrap
`SharedModelContainer.make()` (Services/SharedModelContainer.swift) — one function,
used by both the app (`BookTrackerApp.swift`) and the widget provider
(`BookTrackerWidgetProvider.swift`). Schema = `[Book.self, Quote.self]`; stores in the
App Group container when available, else a local default store.

## Repository injection
All repositories/services are constructed once in `MainTabView` from
`@Environment(\.modelContext)` and passed down by initializer through
`LibraryView → BookDetailView / AddBookView / ScanBarcodeView / SettingsView →
their ViewModels`. No singletons, no service locator.
