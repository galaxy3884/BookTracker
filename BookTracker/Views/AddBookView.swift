import SwiftUI

struct AddBookView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: AddBookViewModel

    init(repository: BookRepository, defaultStatus: BookStatus, prefilledISBN: String? = nil) {
        _viewModel = State(initialValue: AddBookViewModel(repository: repository, defaultStatus: defaultStatus, prefilledISBN: prefilledISBN))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(Strings.AddBook.dataSection) {
                    TextField(Strings.AddBook.titlePlaceholder, text: $viewModel.title)
                    TextField(Strings.AddBook.authorPlaceholder, text: $viewModel.author)
                    TextField(Strings.AddBook.isbnPlaceholder, text: $viewModel.isbn)
                        .keyboardType(.numberPad)
                }
                Section(Strings.AddBook.statusSection) {
                    statusPicker
                }
                Section {
                    Toggle(Strings.AddBook.ownedToggle, isOn: $viewModel.isOwned)
                }
            }
            .navigationTitle(Strings.AddBook.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Strings.Common.cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.Common.save) {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                    .disabled(!viewModel.canSave)
                }
            }
            .alert(Strings.Common.error, isPresented: errorBinding) {
                Button(Strings.Common.ok, role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
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
                        isSelected: viewModel.status == status
                    ) {
                        viewModel.status = status
                    }
                }
            }
            .padding(.vertical, Theme.Spacing.xs)
        }
        .listRowInsets(EdgeInsets(top: Theme.Spacing.xs, leading: Theme.Spacing.md, bottom: Theme.Spacing.xs, trailing: 0))
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in if !isPresented { viewModel.errorMessage = nil } }
        )
    }
}
