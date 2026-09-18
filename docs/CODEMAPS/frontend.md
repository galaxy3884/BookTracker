<!-- Generated: 2026-09-18 | Files scanned: 49 | Token estimate: ~900 -->

# BookTracker — View Tree & State

SwiftUI only. Each View owns its ViewModel via `@State private var viewModel` (no
external DI container); ViewModels are `@Observable` classes constructed in the
View's `init`.

## Page tree

```
BookTrackerApp (@main)
└─ MainTabView                                    (builds repository/service instances
   ├─ TabView                                       from @Environment(\.modelContext))
   │  ├─ "Бібліотека" → LibraryView
   │  └─ "Статистика" → StatisticsView
   │
   LibraryView                          [LibraryViewModel: filterState, errorMessage]
   ├─ @Query(Book, sort: dateAdded desc)         — unfiltered; filtering is a pure fn
   ├─ filterBar → FilterChip × (statuses + owned-only)   [DesignSystem]
   ├─ content (@ViewBuilder):
   │    books.isEmpty        → EmptyStateView (add/scan actions)
   │    filteredBooks.isEmpty→ EmptyStateView (reset-filters action)
   │    else                 → List[BookRowView] + NavigationLink(Book) + onDelete
   ├─ .navigationDestination(Book.self) → BookDetailView
   └─ .sheet(item: LibrarySheet)  — ONE sheet modifier, 3 cases (avoids the
        ├─ .add(isbn)   → AddBookView            two-.sheet-modifiers bug from Phase 2)
        ├─ .scan        → ScanBarcodeView(onISBNRecognized: → reopens .add with isbn)
        └─ .settings    → SettingsView

   BookDetailView                      [BookDetailViewModel: book, form-bound fields]
   ├─ heroHeader: BookCoverView (large) + title/author
   ├─ statusSection: statusPicker (FilterChip row, single-select) + Owned toggle +
   │    isbn/added/started/finished/notes
   ├─ progressSection (only if status == .reading): currentPage/totalPages fields
   ├─ detailsSection: genre TextField, mood/pace Picker
   └─ quotesSection: List + add-quote form

   AddBookView (sheet)                  [AddBookViewModel: title/author/isbn/status/isOwned]
   ScanBarcodeView (sheet)              [ScanBarcodeViewModel: state machine, see below]
   SettingsView (sheet)                 [SettingsViewModel: exportedFileURL]

   StatisticsView                       [StatisticsViewModel: 4 chart datasets]
   └─ ScrollView → StatisticsCard × 4 (genre/mood/pace/monthly), Swift Charts
        each card: data.isEmpty → StatisticsEmptyState, else → Chart(BarMark/SectorMark)
```

## ScanBarcodeView state machine (ScanBarcodeViewModel.state)
```
checkingPermission → needsPermission → scanning ──► onISBNRecognized(isbn)
                   ↘ cameraUnavailable (no camera)     └► unsupportedCode → alert
                   ↘ permissionDenied → "Open Settings" / manual entry
```

## DesignSystem/ (shared with widget — see architecture.md)
| File | Provides |
|---|---|
| `Theme.swift` | Spacing/CornerRadius constants, semantic `Font` statics |
| `Strings.swift` | Every UI string, `String(localized:)`-wrapped, namespaced by screen |
| `BookCoverView.swift` | Real cover image OR `BookCoverPlaceholder` (deterministic FNV-1a hash → gradient + initial) |
| `BookStatus+Style.swift` | `BookStatus.color` (Asset Catalog color) / `.symbolName` |
| `FilterChip.swift` | Capsule toggle, reused for library filters AND status-change picker |

## Views with no ViewModel (pure/presentational)
`EmptyStateView`, `StatisticsCard`, `StatisticsEmptyState`, `BookRowView`,
`BarcodeScannerContainerView` (UIViewControllerRepresentable wrapper).

## Widget (separate process, same DesignSystem)
`BookTrackerWidgetProvider` (TimelineProvider, 6h refresh) → `BookTrackerWidgetView`
(systemSmall/systemMedium) → reuses `BookCoverView` + `Strings.Widget`.
