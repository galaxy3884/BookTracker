import SwiftUI
import SwiftData
import Charts

struct StatisticsView: View {
    @Query private var books: [Book]
    @State private var viewModel: StatisticsViewModel

    init(statisticsService: StatisticsService) {
        _viewModel = State(initialValue: StatisticsViewModel(statisticsService: statisticsService))
    }

    private var genreData: [GenreCount] { viewModel.genreData }
    private var moodData: [MoodCount] { viewModel.moodData }
    private var paceData: [PaceCount] { viewModel.paceData }
    private var monthlyData: [MonthlyCount] { viewModel.monthlyData }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    genreCard
                    moodCard
                    paceCard
                    monthlyCard
                }
                .padding()
            }
            .navigationTitle(Strings.Statistics.title)
            .task(id: books.count) {
                await viewModel.refresh(books: books)
            }
        }
    }

    private var genreCard: some View {
        StatisticsCard(title: Strings.Statistics.genresCard) {
            if genreData.isEmpty {
                StatisticsEmptyState(message: Strings.Statistics.genresEmpty)
            } else {
                Chart(genreData) { item in
                    BarMark(
                        x: .value(Strings.Statistics.booksAxisLabel, item.count),
                        y: .value(Strings.Statistics.genreAxisLabel, item.genre)
                    )
                }
                .frame(height: CGFloat(genreData.count) * 32 + 20)
            }
        }
    }

    private var moodCard: some View {
        StatisticsCard(title: Strings.Statistics.moodCard) {
            if moodData.isEmpty {
                StatisticsEmptyState(message: Strings.Statistics.moodEmpty)
            } else {
                Chart(moodData) { item in
                    SectorMark(
                        angle: .value(Strings.Statistics.booksAxisLabel, item.count),
                        innerRadius: .ratio(0.55)
                    )
                    .foregroundStyle(by: .value(Strings.Statistics.moodAxisLabel, item.mood.displayName))
                }
                .frame(height: 220)
            }
        }
    }

    private var paceCard: some View {
        StatisticsCard(title: Strings.Statistics.paceCard) {
            if paceData.isEmpty {
                StatisticsEmptyState(message: Strings.Statistics.paceEmpty)
            } else {
                Chart(paceData) { item in
                    BarMark(
                        x: .value(Strings.Statistics.paceAxisLabel, item.pace.displayName),
                        y: .value(Strings.Statistics.booksAxisLabel, item.count)
                    )
                }
                .frame(height: 200)
            }
        }
    }

    private var monthlyCard: some View {
        StatisticsCard(title: Strings.Statistics.monthlyCard) {
            if monthlyData.allSatisfy({ $0.count == 0 }) {
                StatisticsEmptyState(message: Strings.Statistics.monthlyEmpty)
            } else {
                Chart(monthlyData) { item in
                    BarMark(
                        x: .value(Strings.Statistics.monthAxisLabel, item.monthStart, unit: .month),
                        y: .value(Strings.Statistics.booksAxisLabel, item.count)
                    )
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month, count: 2)) { value in
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .frame(height: 200)
            }
        }
    }
}
