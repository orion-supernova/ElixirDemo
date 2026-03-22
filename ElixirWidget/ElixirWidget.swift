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
        let summary = WidgetDoseSummary.readFromSharedContainer() ?? .placeholder
        let state = WidgetState.from(summary)

        var entries: [ElixirWidgetEntry] = []

        // Current state
        entries.append(ElixirWidgetEntry(date: now, summary: summary, widgetState: state))

        // Transition at grace period end: upcoming → overdue
        if let nextDose = summary.nextDose, nextDose.scheduledTime > now {
            let gracePeriodEnd = nextDose.scheduledTime.addingTimeInterval(15 * 60)
            entries.append(ElixirWidgetEntry(
                date: gracePeriodEnd,
                summary: summary,
                widgetState: .overdue(count: summary.overdueCount + 1)
            ))
        }

        // Midnight reset
        let midnight = Calendar.current.startOfDay(
            for: Calendar.current.date(byAdding: .day, value: 1, to: now)!
        )
        entries.append(ElixirWidgetEntry(date: midnight, summary: .empty, widgetState: .empty))

        completion(Timeline(entries: entries, policy: .atEnd))
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
