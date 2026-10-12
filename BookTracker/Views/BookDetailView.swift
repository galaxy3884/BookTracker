import SwiftUI

struct BookDetailView: View {
    private enum Field: Hashable {
        case currentPage, totalPages, genre, notes, quoteText, quotePage
    }

    @State private var viewModel: BookDetailViewModel
    @FocusState private var focusedField: Field?

    init(book: Book, repository: BookRepository, quoteRepository: QuoteRepository) {
        _viewModel = State(initialValue: BookDetailViewModel(book: book, repository: repository, quoteRepository: quoteRepository))
    }

    var body: some View {
        Form {
            Section {
                heroHeader
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())

            statusSection
            if viewModel.book.status == .reading {
                progressSection
            }
            detailsSection
            quotesSection
        }
        .animation(.default, value: viewModel.book.status)
        .navigationTitle(viewModel.book.title)
        .navigationBarTitleDisplayMode(.inline)
        .onChange(of: focusedField) { _, _ in
            viewModel.commitPendingEdits()
        }
        .onDisappear {
            viewModel.commitPendingEdits()
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(Strings.Common.done) {
                    focusedField = nil
                }
            }
        }
        .alert(Strings.Common.error, isPresented: errorBinding) {
            Button(Strings.Common.ok, role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in if !isPresented { viewModel.errorMessage = nil } }
        )
    }

    private var heroHeader: some View {
        VStack(spacing: Theme.Spacing.md) {
            BookCoverView(
                title: viewModel.book.title,
                author: viewModel.book.author,
                coverImageData: viewModel.book.coverImageData,
                cornerRadius: Theme.CornerRadius.coverHero
            )
            .frame(width: 140, height: 210)
            .shadow(color: .black.opacity(0.18), radius: 10, y: 6)

            VStack(spacing: Theme.Spacing.xs) {
                Text(viewModel.book.title)
                    .font(.appBookHeroTitle)
                    .multilineTextAlignment(.center)
                Text(viewModel.book.author)
                    .font(.appBookAuthor)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, Theme.Spacing.lg)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.lg)
    }

    private var statusSection: some View {
        Section(Strings.BookDetail.statusLabel) {
            statusPicker
                .listRowInsets(EdgeInsets(top: Theme.Spacing.xs, leading: Theme.Spacing.md, bottom: Theme.Spacing.xs, trailing: 0))
            Toggle(Strings.BookDetail.ownedToggle, isOn: $viewModel.isOwned)
                .onChange(of: viewModel.isOwned) { _, _ in
                    viewModel.commitIsOwned()
                }
            if let isbn = viewModel.book.isbn, !isbn.isEmpty {
                LabeledContent(Strings.BookDetail.isbnLabel, value: isbn)
            }
            LabeledContent(Strings.BookDetail.addedLabel, value: viewModel.book.dateAdded.formatted(date: .abbreviated, time: .omitted))
            if let dateStarted = viewModel.book.dateStarted {
                LabeledContent(Strings.BookDetail.startedLabel, value: dateStarted.formatted(date: .abbreviated, time: .omitted))
            }
            if let dateFinished = viewModel.book.dateFinished {
                LabeledContent(Strings.BookDetail.finishedLabel, value: dateFinished.formatted(date: .abbreviated, time: .omitted))
            }
        }
    }

    private var statusPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: Theme.Spacing.sm) {
                ForEach(BookStatus.allCases) { status in
                    FilterChip(
                        title: status.displayName,
                        systemImage: status.symbolName,
                        color: status.color,
                        isSelected: viewModel.book.status == status
                    ) {
                        withAnimation {
                            viewModel.changeStatus(to: status)
                        }
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.xs)
        }
        .accessibilityLabel(Strings.BookDetail.changeStatusAction)
    }

    @ViewBuilder
    private var progressSection: some View {
        Section(Strings.BookDetail.progressSection) {
            HStack {
                Text(Strings.BookDetail.currentPageLabel)
                Spacer()
                TextField(Strings.BookDetail.currentPagePlaceholder, text: $viewModel.currentPageInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(minWidth: 44, maxWidth: 100)
                    .focused($focusedField, equals: .currentPage)
            }
            HStack {
                Text(Strings.BookDetail.totalPagesLabel)
                Spacer()
                TextField(Strings.BookDetail.totalPagesPlaceholder, text: $viewModel.totalPagesInput)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(minWidth: 44, maxWidth: 120)
                    .focused($focusedField, equals: .totalPages)
            }
            if let progress = viewModel.book.progressFraction {
                ProgressView(value: progress)
                    .tint(viewModel.book.status.color)
                Text("\(Int((progress * 100).rounded()))%")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var detailsSection: some View {
        Section(Strings.BookDetail.detailsSection) {
            TextField(Strings.BookDetail.genrePlaceholder, text: $viewModel.genreInput)
                .focused($focusedField, equals: .genre)
            Picker(Strings.BookDetail.moodLabel, selection: $viewModel.mood) {
                Text(Strings.Common.notSpecified).tag(Mood?.none)
                ForEach(Mood.allCases) { mood in
                    Text(mood.displayName).tag(Mood?.some(mood))
                }
            }
            .onChange(of: viewModel.mood) { _, _ in
                viewModel.commitMood()
            }
            Picker(Strings.BookDetail.paceLabel, selection: $viewModel.pace) {
                Text(Strings.Common.notSpecified).tag(Pace?.none)
                ForEach(Pace.allCases) { pace in
                    Text(pace.displayName).tag(Pace?.some(pace))
                }
            }
            .onChange(of: viewModel.pace) { _, _ in
                viewModel.commitPace()
            }
            TextField(Strings.BookDetail.notesLabel, text: $viewModel.notesInput, axis: .vertical)
                .lineLimit(2...6)
                .focused($focusedField, equals: .notes)
        }
    }

    private var sortedQuotes: [Quote] {
        viewModel.book.quotes.sorted { $0.dateAdded < $1.dateAdded }
    }

    private var quotesSection: some View {
        Section(Strings.BookDetail.quotesSection) {
            ForEach(sortedQuotes) { quote in
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(quote.text)
                    if let page = quote.page {
                        Text(Strings.BookDetail.quotePage(page))
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .combine)
            }
            .onDelete { offsets in
                let quotes = sortedQuotes
                for index in offsets {
                    viewModel.deleteQuote(quotes[index])
                }
            }
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                TextField(Strings.BookDetail.newQuotePlaceholder, text: $viewModel.newQuoteText, axis: .vertical)
                    .focused($focusedField, equals: .quoteText)
                TextField(Strings.BookDetail.newQuotePagePlaceholder, text: $viewModel.newQuotePageInput)
                    .keyboardType(.numberPad)
                    .focused($focusedField, equals: .quotePage)
                Button(Strings.BookDetail.addQuoteAction) {
                    viewModel.addQuote()
                }
                .disabled(viewModel.newQuoteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}
