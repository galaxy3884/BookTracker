import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Query private var books: [Book]
    @State private var viewModel: SettingsViewModel
    @State private var isImporterPresented = false

    init(exportService: LibraryExportService, importService: LibraryImportService) {
        _viewModel = State(initialValue: SettingsViewModel(exportService: exportService, importService: importService))
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
                Section {
                    Button(Strings.Import.action) {
                        isImporterPresented = true
                    }
                } footer: {
                    Text(Strings.Import.footer)
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
            .fileImporter(isPresented: $isImporterPresented, allowedContentTypes: [.json]) { result in
                viewModel.handleImportSelection(result.map { [$0] })
            }
            .alert(Strings.Common.error, isPresented: errorBinding) {
                Button(Strings.Common.ok, role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .alert(Strings.Import.resultTitle, isPresented: importResultBinding) {
                Button(Strings.Common.ok, role: .cancel) {}
            } message: {
                Text(viewModel.importResultMessage ?? "")
            }
        }
    }

    private var errorBinding: Binding<Bool> {
        Binding(
            get: { viewModel.errorMessage != nil },
            set: { isPresented in if !isPresented { viewModel.errorMessage = nil } }
        )
    }

    private var importResultBinding: Binding<Bool> {
        Binding(
            get: { viewModel.importResultMessage != nil },
            set: { isPresented in if !isPresented { viewModel.importResultMessage = nil } }
        )
    }
}
