import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    private let scanningService: BarcodeScanningService = DataScannerBarcodeScanningService()
    private let statisticsService: StatisticsService = DefaultStatisticsService()
    private let exportService: LibraryExportService = JSONLibraryExportService()

    var body: some View {
        TabView {
            LibraryView(
                repository: repository,
                scanningService: scanningService,
                quoteRepository: quoteRepository,
                exportService: exportService
            )
            .tabItem {
                Label(Strings.MainTab.library, systemImage: "books.vertical.fill")
            }

            StatisticsView(statisticsService: statisticsService)
                .tabItem {
                    Label(Strings.MainTab.statistics, systemImage: "chart.bar.fill")
                }
        }
    }

    private var repository: BookRepository {
        SwiftDataBookRepository(modelContext: modelContext)
    }

    private var quoteRepository: QuoteRepository {
        SwiftDataQuoteRepository(modelContext: modelContext)
    }
}
