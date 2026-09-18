import Foundation

@Observable
final class SettingsViewModel {
    private let exportService: LibraryExportService
    var exportedFileURL: URL?
    var errorMessage: String?

    init(exportService: LibraryExportService) {
        self.exportService = exportService
    }

    func exportLibrary(books: [Book]) {
        do {
            exportedFileURL = try exportService.exportLibrary(books: books)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
