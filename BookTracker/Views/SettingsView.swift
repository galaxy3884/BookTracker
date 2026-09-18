import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var books: [Book]
    @State private var viewModel: SettingsViewModel

    init(exportService: LibraryExportService) {
        _viewModel = State(initialValue: SettingsViewModel(exportService: exportService))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button(Strings.Settings.exportAction) {
                        viewModel.exportLibrary(books: books)
                    }
                    if let url = viewModel.exportedFileURL {
                        ShareLink(item: url) {
                            Label(Strings.Settings.shareAction, systemImage: "square.and.arrow.up")
                        }
                    }
                } header: {
                    Text(Strings.Settings.dataSection)
                } footer: {
                    Text(Strings.Settings.exportFooter)
                }
            }
            .navigationTitle(Strings.Settings.title)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Strings.Common.done) {
                        dismiss()
                    }
                }
            }
            .alert(Strings.Common.error, isPresented: errorBinding) {
                Button(Strings.Common.ok, role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in if !isPresented { viewModel.errorMessage = nil } }
        )
    }
}
