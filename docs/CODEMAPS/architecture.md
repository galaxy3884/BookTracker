<!-- Generated: 2026-09-18 | Files scanned: 49 | Token estimate: ~650 -->

# BookTracker — Architecture

Offline iOS 17+ book-tracking app. SwiftUI + SwiftData. Zero network/URLSession, zero
third-party deps. MVVM + protocol-oriented Services/Repositories.

## Targets (project.yml)

```
BookTracker (app)              BookTrackerWidgetExtension        BookTrackerTests
  sources: BookTracker/*          sources: BookTrackerWidget/*      sources: BookTrackerTests/*
                                   + BookTracker/Models/*            depends on: BookTracker
                                   + Services/SharedModelContainer.swift
                                   + BookTracker/DesignSystem/*
                                   + BookTracker/Resources/Assets.xcassets
  depends on ↑ WidgetExtension (embed)
```
DesignSystem/ and Models/ are physically shared (listed in both targets' `sources`),
not a separate framework — the only way code crosses the app/widget boundary.

## Data flow

```
   ┌─────────────┐  @Observable   ┌──────────────┐  protocol    ┌────────────────────┐
   │    View      │◄──────────────│  ViewModel    │─────────────►│ Repository/Service  │
   │  (SwiftUI)   │  @State owns   │ (business     │  (DI, ctor   │  (SwiftData /       │
   │              │  the VM        │  logic)       │  injected)   │   pure functions)   │
   └──────┬───────┘                └──────────────┘               └────────┬────────────┘
          │ @Query (live)                                                  │
          └────────────────────────────────────────────────────────────────┘
                                    SwiftData ModelContainer
                                    (App Group container when available)
                                             │
                              ┌──────────────┴───────────────┐
                              │                               │
                       BookTracker.app                 BookTrackerWidgetExtension
                       (read/write)                    (read-only, TimelineProvider)
```

- No ViewModel ever talks to another ViewModel; Views compose child Views and pass
  repositories down through initializers (see `frontend.md`).
- Widget and app are separate processes sharing one SQLite store via
  `SharedModelContainer` + App Group `group.com.olegvornicesku.BookTracker`.

## Layers → see other codemaps

| Layer | Codemap |
|---|---|
| View tree, navigation, sheets | `frontend.md` |
| ViewModel → Repository/Service calls | `backend.md` |
| SwiftData models, schema, relationships | `data.md` |
| Frameworks, App Group, localization | `dependencies.md` |

## Phase history (as implemented, not a roadmap)

1. Scaffold, 3-tab nav, manual add · 2. ISBN scan (VisionKit) · 3. Progress + auto
dates · 4. Genre/mood/pace + Quotes + Charts · 5. Widget + JSON export + tests ·
6. `isOwned` + 2-tab Library/Statistics + `FilterState` · 7. Design system (Theme,
BookCoverView, FilterChip, EmptyStateView) · 8. Localization (uk source → en,
String Catalog, plurals).
