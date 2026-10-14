# BookTracker

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[English](README.md) · **Українська**

Повністю офлайн застосунок для iOS для обліку прочитаних книг. SwiftUI + SwiftData, без мережевих
запитів і без сторонніх залежностей.

## Можливості

- **Бібліотека** з єдиним списком і комбінованими фільтрами (статус читання + «тільки куплені»),
  які показані кольоровими чіпами
- **Сканування ISBN-штрихкоду** (VisionKit) з ручним введенням як запасним варіантом
- **Прогрес читання**: поточна й загальна кількість сторінок, дати початку й завершення
  проставляються автоматично при зміні статусу
- **Жанр, настрій і темп** для кожної книги та **колекція цитат**
- **Статистика** з графіками Swift Charts (жанри, настрої, темп, прочитане за місяцями)
- **Віджет на екрані Home**, що показує книги, прочитані цього місяця, і поточну книгу; дані
  зберігаються в сховищі, спільному для застосунку й віджета через App Group
- **Експорт бібліотеки в JSON** через системний «Поділитися» без вивантаження в мережу, файл лишається
  на пристрої; **імпорт** з такого файлу (лише додавання, без перезапису наявних книг)
- Згенеровані обкладинки (градієнт і перша літера назви), бо справжні обкладинки застосунок
  не завантажує
- Інтерфейс українською (основна мова) й англійською, включно з формами множини

## Технологічний стек

- Swift 5.9+, SwiftUI, iOS 17+
- SwiftData для збереження, Swift Charts для статистики, WidgetKit для віджета, VisionKit для
  сканування штрихкодів
- MVVM і протокол-орієнтовані сервіси й репозиторії, впровадження залежностей через ініціалізатори
  (без контейнерів і синглтонів)
- Swift Testing для юніт-тестів; репозиторії тестуються на справжньому in-memory SwiftData, а не на
  моках
- Нуль мережевих запитів, нуль `URLSession`, нуль сторонніх пакетів

## Архітектура

Карта кодової бази (стисла, для швидкого огляду):
[`architecture.md`](docs/CODEMAPS/architecture.md) (загальна схема),
[`backend.md`](docs/CODEMAPS/backend.md) (шар сервісів і репозиторіїв),
[`frontend.md`](docs/CODEMAPS/frontend.md) (дерево View і стан),
[`data.md`](docs/CODEMAPS/data.md) (моделі SwiftData),
[`dependencies.md`](docs/CODEMAPS/dependencies.md) (фреймворки, App Group).

Правила проєкту для розробки з Claude Code — у [`CLAUDE.md`](CLAUDE.md).

## Початок роботи

**Вимоги:** Xcode 16+, [XcodeGen](https://github.com/yonaskolb/XcodeGen)
(`brew install xcodegen`).

`.xcodeproj` генерується з [`project.yml`](project.yml) і в репозиторій не комітиться. Після клонування
або зміни складу файлів чи таргетів його треба згенерувати заново:

```bash
xcodegen generate
open BookTracker.xcodeproj
```

Оберіть схему **BookTracker** і запустіть на симуляторі або пристрої з iOS 17+.

## Запуск тестів

```bash
xcodebuild -project BookTracker.xcodeproj -scheme BookTracker \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test
```

## Структура проєкту

```
BookTracker/
├── App/            точка входу (@main)
├── Models/         моделі SwiftData (Book, Quote), enum-и (BookStatus, Mood, Pace), правила книги
├── Services/       протокольні репозиторії та сервіси, ISBN, експорт і імпорт
├── ViewModels/     @Observable-моделі подання, по одній на екран
├── Views/          SwiftUI-подання
├── DesignSystem/   Theme, Strings (тексти інтерфейсу), BookCoverView, FilterChip, Localizable.xcstrings
└── Resources/      Assets.xcassets, InfoPlist.xcstrings

BookTrackerWidget/   розширення віджета на екрані Home
BookTrackerTests/    юніт-тести на Swift Testing
```

## Ліцензія

[MIT](LICENSE)
