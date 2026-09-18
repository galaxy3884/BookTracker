<!-- Generated: 2026-09-18 | Files scanned: 49 | Token estimate: ~500 -->

# BookTracker — Dependencies

## Hard constraint (all phases): zero network requests, zero URLSession, zero
third-party packages/SPM deps. Nothing in this file talks to the internet.

## Apple frameworks in use
| Framework | Used for | Where |
|---|---|---|
| SwiftUI | entire UI | all Views |
| SwiftData | persistence | Models/, Services/SwiftData*Repository.swift |
| WidgetKit | home-screen widget | BookTrackerWidget/* |
| VisionKit (`DataScannerViewController`) | ISBN barcode scan | Services/DataScannerBarcodeScanningService.swift |
| Swift Charts | statistics (BarMark/SectorMark) | Views/StatisticsView.swift |
| Foundation (`String(localized:)`) | localization | DesignSystem/Strings.swift, Models/*.swift enums |

## Cross-process sharing: App Group
`group.com.olegvornicesku.BookTracker` (Services/SharedModelContainer.swift) — the
ONLY channel between the app and the widget extension process. Both read/write the
same SQLite file via SwiftData; the widget is read-only in practice (never mutates).
Requires the App Group entitlement on both targets
(`BookTracker.entitlements` / `BookTrackerWidget.entitlements`).

## Localization infra (Phase 8)
- `BookTracker/DesignSystem/Localizable.xcstrings` — String Catalog, source
  language uk, translated to en. Shared into BOTH targets by being physically
  inside `DesignSystem/` (which both targets' `sources` include in project.yml).
- `BookTracker/Resources/InfoPlist.xcstrings` — localizes
  `NSCameraUsageDescription` only; app target only (not shared with widget).
- `project.yml`: `options.developmentLanguage: uk`, `SWIFT_EMIT_LOC_STRINGS: YES`
  on both the app and widget targets.

## Build system
`xcodegen` generates `BookTracker.xcodeproj` from `project.yml` — the project file
itself is NOT hand-edited or committed as source of truth; `project.yml` is.
Run `xcodegen generate` after adding/moving files or changing target membership.

## Test doubles
`BookTrackerTests/Mocks/MockBarcodeScanningService.swift` — the only mock in the
suite; everything else (repositories, statistics) is tested against a real
in-memory `ModelConfiguration(isStoredInMemoryOnly: true)`, deliberately not mocked,
to exercise real business logic.
