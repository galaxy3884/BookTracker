import Foundation

/// Central catalog of every user-facing string in the app and widget.
/// Every entry goes through `String(localized:)` so Xcode's build-time extractor
/// picks it up into Localizable.xcstrings — Ukrainian is the source language,
/// English is the translated language (see Phase 8).
enum Strings {
    enum Common {
        static let ok = String(localized: "OK")
        static let error = String(localized: "Помилка")
        static let cancel = String(localized: "Скасувати")
        static let save = String(localized: "Зберегти")
        static let done = String(localized: "Готово")
        static let notSpecified = String(localized: "Не вказано")
    }

    enum MainTab {
        static let library = String(localized: "Бібліотека")
        static let statistics = String(localized: "Статистика")
    }

    enum Library {
        static let title = String(localized: "Бібліотека")
        static let addBookAccessibility = String(localized: "Додати книгу вручну")
        static let scanAccessibility = String(localized: "Сканувати штрихкод")
        static let settingsAccessibility = String(localized: "Налаштування")
        static let emptyLibraryTitle = String(localized: "Бібліотека порожня")
        static let emptyLibraryMessage = String(localized: "Додайте книгу вручну або відскануйте штрихкод")
        static let addBookAction = String(localized: "Додати книгу")
        static let scanAction = String(localized: "Сканувати штрихкод")
        static let emptyFilterTitle = String(localized: "Нічого не знайдено за цим фільтром")
        static let emptyFilterMessage = String(localized: "Спробуйте змінити або скинути фільтри.")
        static let resetFiltersAction = String(localized: "Скинути фільтри")
        static let statusFilterAll = String(localized: "Всі")
        static let ownedOnlyFilter = String(localized: "Тільки куплені")
    }

    enum BookRow {
        static let ownedAccessibility = String(localized: "Куплена")
    }

    enum BookDetail {
        static let infoSection = String(localized: "Інформація")
        static let titleLabel = String(localized: "Назва")
        static let authorLabel = String(localized: "Автор")
        static let statusLabel = String(localized: "Статус")
        static let ownedToggle = String(localized: "Куплена")
        static let isbnLabel = String(localized: "ISBN")
        static let addedLabel = String(localized: "Додано")
        static let startedLabel = String(localized: "Розпочато")
        static let finishedLabel = String(localized: "Завершено")
        static let notesLabel = String(localized: "Нотатки")
        static let progressSection = String(localized: "Прогрес читання")
        static let currentPageLabel = String(localized: "Поточна сторінка")
        static let currentPagePlaceholder = String(localized: "0")
        static let totalPagesLabel = String(localized: "Усього сторінок")
        static let totalPagesPlaceholder = String(localized: "Необов'язково")
        static let detailsSection = String(localized: "Деталі")
        static let genrePlaceholder = String(localized: "Жанр (опційно)")
        static let moodLabel = String(localized: "Настрій")
        static let paceLabel = String(localized: "Темп")
        static let quotesSection = String(localized: "Цитати")
        static let newQuotePlaceholder = String(localized: "Текст цитати")
        static let newQuotePagePlaceholder = String(localized: "Сторінка (опційно)")
        static let addQuoteAction = String(localized: "Додати цитату")
        static let changeStatusAction = String(localized: "Змінити статус")

        static func quotePage(_ page: Int) -> String {
            String(localized: "Стор. \(page)")
        }
    }

    enum AddBook {
        static let title = String(localized: "Нова книга")
        static let dataSection = String(localized: "Дані книги")
        static let titlePlaceholder = String(localized: "Назва")
        static let authorPlaceholder = String(localized: "Автор")
        static let isbnPlaceholder = String(localized: "ISBN (опційно)")
        static let statusSection = String(localized: "Статус")
        static let ownedToggle = String(localized: "Куплена")
    }

    enum ScanBarcode {
        static let title = String(localized: "Сканувати штрихкод")
        static let scannerHint = String(localized: "Наведіть камеру на штрихкод книги (EAN-13/UPC)")
        static let unsupportedTitle = String(localized: "Не розпізнано")
        static let unsupportedCodeMessage = String(localized: "Штрихкод не розпізнано як книжковий код (EAN-13/UPC). Спробуйте ще раз або введіть ISBN вручну.")
        static let retryAction = String(localized: "Спробувати ще раз")
        static let enterManuallyAction = String(localized: "Ввести вручну")
        static let permissionNeededTitle = String(localized: "Потрібен доступ до камери")
        static let permissionNeededMessage = String(localized: "Щоб сканувати штрихкод книги, дозвольте застосунку використовувати камеру.")
        static let allowCameraAction = String(localized: "Дозволити доступ до камери")
        static let enterISBNManuallyAction = String(localized: "Ввести ISBN вручну")
        static let permissionDeniedTitle = String(localized: "Немає доступу до камери")
        static let permissionDeniedMessage = String(localized: "Дозвольте доступ до камери в Налаштуваннях, щоб сканувати штрихкоди книг.")
        static let openSettingsAction = String(localized: "Відкрити Налаштування")
        static let manualEntryHeader = String(localized: "Введіть ISBN вручну")
        static let manualEntryFooter = String(localized: "Камера недоступна на цьому пристрої. Введіть ISBN зі штрихкоду книги.")
        static let isbnFieldPlaceholder = String(localized: "ISBN")
        static let continueAction = String(localized: "Продовжити")
    }

    enum Settings {
        static let title = String(localized: "Налаштування")
        static let dataSection = String(localized: "Дані")
        static let exportAction = String(localized: "Експортувати бібліотеку")
        static let shareAction = String(localized: "Поділитися файлом")
        static let exportFooter = String(localized: "Створює JSON-файл з усіма книгами й цитатами без обкладинок.")
    }

    enum Statistics {
        static let title = String(localized: "Статистика")
        static let genresCard = String(localized: "Жанри")
        static let genresEmpty = String(localized: "Додайте жанр до прочитаних книг, щоб побачити розподіл")
        static let moodCard = String(localized: "Настрій")
        static let moodEmpty = String(localized: "Додайте настрій до прочитаних книг, щоб побачити розподіл")
        static let paceCard = String(localized: "Темп читання")
        static let paceEmpty = String(localized: "Додайте темп до прочитаних книг, щоб побачити розподіл")
        static let monthlyCard = String(localized: "Прочитано за місяцями")
        static let monthlyEmpty = String(localized: "Позначте книги як прочитані, щоб побачити динаміку за місяцями")

        // Swift Charts series/axis names (shown in accessibility descriptions and legends).
        static let booksAxisLabel = String(localized: "Книг")
        static let genreAxisLabel = String(localized: "Жанр")
        static let moodAxisLabel = String(localized: "Настрій")
        static let paceAxisLabel = String(localized: "Темп")
        static let monthAxisLabel = String(localized: "Місяць")
    }

    enum Widget {
        static let configurationDisplayName = String(localized: "Мій трекер книг")
        static let configurationDescription = String(localized: "Прогрес читання цього місяця та поточна книга.")
        static let monthlyCountLabel = String(localized: "Прочитано цього місяця")
        static let readingLabel = String(localized: "Зараз читаю")
        static let noActiveBook = String(localized: "Немає активної книги")
        static let placeholderTitle = String(localized: "Назва книги")

        static func monthlyCountAccessibility(_ count: Int) -> String {
            String(localized: "Прочитано \(count) книг цього місяця")
        }

        static func readingAccessibility(_ title: String) -> String {
            String(localized: "Зараз читаю: \(title)")
        }
    }
}
