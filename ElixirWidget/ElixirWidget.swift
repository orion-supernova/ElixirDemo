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
            widgetState: .upcoming(nextDoseName: "Vitamin D", secondsUntil: 3600)
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ElixirWidgetEntry) -> Void) {
        let summary = WidgetDoseSummary.readFromSharedContainer() ?? .placeholder
        completion(ElixirWidgetEntry(date: .now, summary: summary, widgetState: .from(summary)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ElixirWidgetEntry>) -> Void) {
        let now = Date()
        let calendar = Calendar.current
        let summary = WidgetDoseSummary.readFromSharedContainer() ?? .placeholder
        let midnight = calendar.startOfDay(for: calendar.date(byAdding: .day, value: 1, to: now)!)

        var entries: [ElixirWidgetEntry] = []

        // Generate hourly entries until midnight so the countdown stays fresh
        var cursor = now
        while cursor < midnight {
            entries.append(makeEntry(at: cursor, summary: summary))
            cursor = calendar.date(byAdding: .hour, value: 1, to: cursor) ?? midnight
        }

        // Midnight reset — triggers a fresh getTimeline call next morning
        entries.append(ElixirWidgetEntry(date: midnight, summary: .empty, widgetState: .empty))

        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func makeEntry(at date: Date, summary: WidgetDoseSummary) -> ElixirWidgetEntry {
        guard !summary.isEmpty, !summary.isAllDone else {
            return ElixirWidgetEntry(date: date, summary: summary, widgetState: .from(summary))
        }

        // Recompute secondsUntil live so the countdown is accurate for each entry
        if let nextDose = summary.nextDose {
            let gracePeriodEnd = nextDose.scheduledTime.addingTimeInterval(15 * 60)
            if date >= gracePeriodEnd {
                return ElixirWidgetEntry(date: date, summary: summary,
                                        widgetState: .overdue(count: summary.overdueCount + 1))
            } else {
                let secs = max(0, nextDose.scheduledTime.timeIntervalSince(date))
                return ElixirWidgetEntry(date: date, summary: summary,
                                        widgetState: .upcoming(nextDoseName: nextDose.medicationName, secondsUntil: secs))
            }
        }

        return ElixirWidgetEntry(date: date, summary: summary, widgetState: .from(summary))
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
    let kind: String = "ElixirWidget"

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
