//
//  ElixirWidget.swift
//  ElixirWidget
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct ElixirTimelineProvider: TimelineProvider {

    func placeholder(in context: Context) -> ElixirWidgetEntry {
        ElixirWidgetEntry(
            date: .now,
            summary: .placeholder,
            widgetState: .upcoming(nextDoseName: "Vitamin D", dueDate: .now.addingTimeInterval(3600))
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ElixirWidgetEntry) -> Void) {
        let summary = WidgetSummaryStore.readFromSharedContainer()?.summary(for: .now) ?? .placeholder
        completion(makeEntry(at: .now, summary: summary))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ElixirWidgetEntry>) -> Void) {
        let now = Date()
        let calendar = Calendar.current
        let store = WidgetSummaryStore.readFromSharedContainer()
        let currentSummary = store?.summary(for: now) ?? .placeholder
        let horizon = calendar.date(byAdding: .day, value: 2, to: calendar.startOfDay(for: now)) ?? now

        var entryDates = Set([now])
        entryDates.formUnion(relevantTransitionDates(store: store, from: now, through: horizon))

        let entries = entryDates
            .sorted()
            .compactMap { entryDate -> ElixirWidgetEntry? in
                let summary = store?.summary(for: entryDate) ?? fallbackSummary(for: entryDate, currentSummary: currentSummary)
                return makeEntry(at: entryDate, summary: summary)
            }

        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func makeEntry(at date: Date, summary: WidgetDoseSummary) -> ElixirWidgetEntry {
        ElixirWidgetEntry(
            date: date,
            summary: summary,
            widgetState: .projected(from: summary, at: date)
        )
    }

    private func relevantTransitionDates(
        store: WidgetSummaryStore?,
        from startDate: Date,
        through endDate: Date
    ) -> Set<Date> {
        let calendar = Calendar.current
        var dates: Set<Date> = []
        var dayCursor = calendar.startOfDay(for: startDate)

        while dayCursor < endDate {
            if let summary = store?.summary(for: dayCursor) {
                for item in summary.todayDoseItems where item.status == WidgetDoseStatus.pending.rawValue {
                    if item.scheduledTime > startDate && item.scheduledTime < endDate {
                        dates.insert(item.scheduledTime)
                    }

                    let graceEnd = item.scheduledTime.addingTimeInterval(15 * 60)
                    if graceEnd > startDate && graceEnd < endDate {
                        dates.insert(graceEnd)
                    }
                }
            }

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayCursor) else { break }
            if nextDay > startDate && nextDay < endDate {
                dates.insert(nextDay)
            }
            dayCursor = nextDay
        }

        return dates
    }

    private func fallbackSummary(for date: Date, currentSummary: WidgetDoseSummary) -> WidgetDoseSummary {
        Calendar.current.isDate(date, inSameDayAs: .now) ? currentSummary : .empty
    }
}

// MARK: - Entry View Router

struct ElixirWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: ElixirWidgetEntry

    var body: some View {
        switch family {
        case .systemSmall:  SmallWidgetView(entry: entry)
        case .systemMedium: MediumWidgetView(entry: entry)
        case .systemLarge:  LargeWidgetView(entry: entry)
        default:            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration

struct ElixirWidget: Widget {
    let kind: String = WidgetConstants.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ElixirTimelineProvider()) { entry in
            ElixirWidgetEntryView(entry: entry)
                .containerBackground(
                    LinearGradient(
                        colors: [Color(hex: "0F172A"), Color(hex: "1E293B")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    for: .widget
                )
        }
        .configurationDisplayName("Elixir")
        .description("Your daily ritual at a glance.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}
