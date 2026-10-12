# BookTracker

Офлайн iOS-застосунок для обліку книг. SwiftUI + SwiftData, iOS 17+, Swift 5.9. Мови інтерфейсу: українська (джерело) + англійська.

## Жорсткі обмеження
- Нуль мережі: без `URLSession`, без запитів до зовнішніх сервісів (метадані й обкладинки за ISBN — свідомо НЕ робимо).
- Нуль сторонніх залежностей: без SPM-пакетів, `Package.swift`, CocoaPods.
- Deployment target 17.0 (SwiftData). Не знижувати.

## Збірка
`.xcodeproj` НЕ в git — його генерує XcodeGen з `project.yml`. Джерело правди — `project.yml`.

```bash
xcodegen generate        # після додавання/переміщення файлів чи зміни таргетів
xcodebuild -project BookTracker.xcodeproj -scheme BookTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

`xcodebuild` потребує повного Xcode. Якщо `xcode-select -p` показує `/Library/Developer/CommandLineTools` — Xcode не вибраний або відсутній; Command Line Tools не збирають iOS-код. Не вигадувати обхідних шляхів (SwiftPM-пакет, `swiftc` напряму) — вони не працюють; сказати користувачеві.

## Архітектура
MVVM + протокол-орієнтовані сервіси, DI через ініціалізатори (без контейнерів і синглтонів). Детально — `docs/CODEMAPS/*.md`.

- `Models/` — `Book`, `Quote`, enum-и. Спільні з віджетом.
- `Models/Book+Rules.swift` — ЄДИНЕ місце правил «статус ↔ дати ↔ прогрес» і вибору книги для віджета. Не дублювати ці правила у View/ViewModel.
- `Services/` — репозиторії, `ISBN`, експорт/імпорт, `SharedModelContainer`.
- `ViewModels/` — `@Observable`, по одному на екран.
- `DesignSystem/` — `Theme`, `Strings`, `BookCoverView`, `FilterChip`. Спільна з віджетом.

## Правила, які легко зламати
- **Усі UI-тексти — тільки в `DesignSystem/Strings.swift`** через `String(localized: "…")`; ключ = український текст. Новий рядок = запис і в `Strings.swift`, і в `DesignSystem/Localizable.xcstrings` (uk + en; для залежних від числа — plural-варіанти). Жодних літералів кирилицею у View.
- **Кольори — лише з Asset Catalog** (`StatusReading` тощо, з light/dark). Відступи, радіуси, шрифти — з `Theme`.
- **Один `.sheet(item:)` з enum** у `LibraryView` (два `.sheet(isPresented:)` були нестабільні). Новий sheet = новий case.
- **App Group обов'язкова** (`SharedModelContainer.make() throws`): без тихого fallback, інакше застосунок і віджет матимуть різні бази.
- **Після кожної мутації даних** репозиторій викликає `onDataChanged` → `WidgetRefresher.reload()`. Нові мутації теж мають це робити.
- **ISBN зберігається канонічно** (ISBN-13, лише цифри) через `ISBN.canonical`. Порівнювати тільки в такому вигляді.
- Нові файли в `Models/` і `DesignSystem/` автоматично потрапляють і у віджет (спільні `sources` у `project.yml`) — вони не мають залежати від UIKit-only чи app-only коду.

## Тести
Swift Testing (`import Testing`, `@Test`, `#expect`). Репозиторії тестуються на справжньому in-memory SwiftData (`ModelConfiguration(isStoredInMemoryOnly: true)`), не на моках. Мок лише для сканера камери. Нова бізнес-логіка — з тестами.

## Робота зі мною
- Відповідати українською. Коротко.
- Не комітити й не пушити без прохання.
