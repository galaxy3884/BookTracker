import SwiftUI
import SwiftData

private enum LibrarySheet: Identifiable {
    case add(isbn: String?)
    case scan
    case settings

    var id: String {
        switch self {
        case .add: "add"
        case .scan: "scan"
        case .settings: "settings"
        }
    }
}

struct LibraryView: View {
    private let repository: BookRepository
    private let scanningService: BarcodeScanningService
    private let quoteRepository: QuoteRepository
    private let exportService: LibraryExportService

    @Query(sort: \Book.dateAdded, order: .reverse) private var books: [Book]
    @State private var viewModel: LibraryViewModel
    @State private var activeSheet: LibrarySheet?
    @State private var pendingISBNForAdd: String?

    init(
        repository: BookRepository,
        scanningService: BarcodeScanningService,
        quoteRepository: QuoteRepository,
        exportService: LibraryExportService
    ) {
        self.repository = repository
        self.scanningService = scanningService
        self.quoteRepository = quoteRepository
        self.exportService = exportService
        _viewModel = State(initialValue: LibraryViewModel(repository: repository))
    }

    private var filteredBooks: [Book] {
        viewModel.filterState.apply(to: books)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !books.isEmpty {
                    filterBar
                    Divider()
                }
                content
            }
            .navigationTitle(Strings.Library.title)
            .navigationDestination(for: Book.self) { book in
                BookDetailView(book: book, repository: repository, quoteRepository: quoteRepository)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        activeSheet = .add(isbn: nil)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel(Strings.Library.addBookAccessibility)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        activeSheet = .scan
                    } label: {
                        Image(systemName: "barcode.viewfinder")
                    }
                    .accessibilityLabel(Strings.Library.scanAccessibility)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        activeSheet = .settings
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel(Strings.Library.settingsAccessibility)
                }
            }
            .sheet(item: $activeSheet, onDismiss: {
                if let isbn = pendingISBNForAdd {
                    pendingISBNForAdd = nil
                    activeSheet = .add(isbn: isbn)
                }
            }) { sheet in
                switch sheet {
                case .add(let isbn):
                    AddBookView(
                        repository: repository,
                        defaultStatus: viewModel.filterState.status ?? .wantToRead,
                        prefilledISBN: isbn
                    )
                case .scan:
                    ScanBarcodeView(scanningService: scanningService) { isbn in
                        pendingISBNForAdd = isbn
                        activeSheet = nil
                    }
                case .settings:
                    SettingsView(exportService: exportService)
                }
            }
            .alert(Strings.Common.error, isPresented: errorBinding) {
                Button(Strings.Common.ok, role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if books.isEmpty {
            EmptyStateView(
                systemImage: "books.vertical",
                title: Strings.Library.emptyLibraryTitle,
                message: Strings.Library.emptyLibraryMessage,
                primaryAction: (Strings.Library.addBookAction, { activeSheet = .add(isbn: nil) }),
                secondaryAction: (Strings.Library.scanAction, { activeSheet = .scan })
            )
        } else if filteredBooks.isEmpty {
            EmptyStateView(
                systemImage: "line.3.horizontal.decrease.circle",
                title: Strings.Library.emptyFilterTitle,
                message: Strings.Library.emptyFilterMessage,
                primaryAction: (Strings.Library.resetFiltersAction, { viewModel.resetFilters() })
            )
        } else {
            List {
                ForEach(filteredBooks) { book in
                    NavigationLink(value: book) {
                        BookRowView(book: book)
                    }
                }
                .onDelete { offsets in
                    let books = filteredBooks
                    for index in offsets {
                        viewModel.delete(books[index])
                    }
                }
            }
            .listStyle(.plain)
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                FilterChip(
                    title: Strings.Library.statusFilterAll,
                    color: .secondary,
                    isSelected: viewModel.filterState.status == nil
                ) {
                    viewModel.filterState.status = nil
                }
                ForEach(BookStatus.allCases) { status in
                    FilterChip(
                        title: status.displayName,
                        systemImage: status.symbolName,
                        color: status.color,
                        isSelected: viewModel.filterState.status == status
                    ) {
                        viewModel.filterState.status = status
                    }
                }
                Divider().frame(height: 20)
                FilterChip(
                    title: Strings.Library.ownedOnlyFilter,
                    systemImage: "bookmark.fill",
                    color: .accentColor,
                    isSelected: viewModel.filterState.ownedOnly
                ) {
                    viewModel.filterState.ownedOnly.toggle()
                }
            }
            .padding(.horizontal)
            .padding(.vertical, Theme.Spacing.sm)
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in if !isPresented { viewModel.errorMessage = nil } }
        )
    }
}
