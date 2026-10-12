import Foundation

@Observable
final class SettingsViewModel {
    private let exportService: LibraryExportService
    private let importService: LibraryImportService
    var exportedFileURL: URL?
    var importResultMessage: String?
    var errorMessage: String?

    init(exportService: LibraryExportService, importService: LibraryImportService) {
        self.exportService = exportService
        self.importService = importService
    }

    func exportLibrary(books: [Book]) {
        do {
            exportedFileURL = try exportService.exportLibrary(books: books)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func handleImportSelection(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            importLibrary(from: url)
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }

    private func importLibrary(from url: URL) {
        let isSecurityScoped = url.startAccessingSecurityScopedResource()
        defer {
            if isSecurityScoped { url.stopAccessingSecurityScopedResource() }
        }
        do {
            let summary = try importService.importLibrary(from: url)
            importResultMessage = Strings.Import.result(added: summary.added, skipped: summary.skipped)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
