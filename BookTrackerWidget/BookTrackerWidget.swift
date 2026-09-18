import SwiftUI
import WidgetKit

struct BookTrackerWidget: Widget {
    let kind = "BookTrackerWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BookTrackerWidgetProvider()) { entry in
            BookTrackerWidgetView(entry: entry)
        }
        .configurationDisplayName(Strings.Widget.configurationDisplayName)
        .description(Strings.Widget.configurationDescription)
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
