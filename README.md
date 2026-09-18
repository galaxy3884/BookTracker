# BookTracker

A fully offline iOS book-tracking app. SwiftUI + SwiftData, no network requests,
no third-party dependencies.

## Features

- **Library** with a single unified list, combinable filters (reading status +
  "owned only") shown as colored filter chips
- **ISBN barcode scanning** (VisionKit) with a manual-entry fallback
- **Reading progress tracking** — current/total pages, auto-stamped start/finish
  dates as status changes
- **Genre / mood / pace tagging** and a **quotes** collection per book
- **Statistics** screen with Swift Charts (genre, mood, pace, books read per month)
- **Home Screen widget** showing books finished this month and the book currently
  being read, backed by an App Group–shared SwiftData store
- **JSON export** of the whole library via the system Share Sheet — no upload,
  stays on-device
- Generated cover art (deterministic gradient + initial letter) wherever a real
  cover image isn't available — which is always, since the app never downloads one
- Localized in Ukrainian (source) and English, including plural forms

## Tech stack

- Swift 5.9+, SwiftUI, iOS 17+
- SwiftData for persistence, Swift Charts for statistics, WidgetKit for the
  widget, VisionKit for barcode scanning
- MVVM + protocol-oriented Services/Repositories, dependency injection via
  initializers (no container, no singletons)
- Swift Testing for unit tests (repositories run against a real in-memory
  SwiftData store, not mocks)
- Zero network requests, zero `URLSession`, zero third-party packages

## Architecture

See [`docs/CODEMAPS/`](docs/CODEMAPS/) for a token-lean map of the codebase:
[`architecture.md`](docs/CODEMAPS/architecture.md) (system overview),
[`backend.md`](docs/CODEMAPS/backend.md) (Service/Repository layer),
[`frontend.md`](docs/CODEMAPS/frontend.md) (View tree & state),
[`data.md`](docs/CODEMAPS/data.md) (SwiftData models),
[`dependencies.md`](docs/CODEMAPS/dependencies.md) (frameworks, App Group).

## Getting started

**Prerequisites:** Xcode 16+, [XcodeGen](https://github.com/yonaskolb/XcodeGen)
(`brew install xcodegen`).

The `.xcodeproj` is generated from [`project.yml`](project.yml) and isn't
committed — regenerate it after cloning or whenever you change file/target
membership:

```bash
xcodegen generate
open BookTracker.xcodeproj
```

Select the **BookTracker** scheme and run on an iOS 17+ simulator or device.

## Running tests

```bash
xcodebuild -project BookTracker.xcodeproj -scheme BookTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## Project structure

```
BookTracker/
├── App/            entry point (@main)
├── Models/         SwiftData models (Book, Quote) + enums (BookStatus, Mood, Pace)
├── Services/       protocol-oriented repositories & services
├── ViewModels/     @Observable view models, one per screen
├── Views/          SwiftUI views
├── DesignSystem/   Theme, Strings (localization), BookCoverView, FilterChip
└── Resources/      Assets.xcassets, InfoPlist.xcstrings

BookTrackerWidget/   Home Screen widget extension
BookTrackerTests/    Swift Testing unit tests
```
