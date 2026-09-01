//
//  ElixirWidget.swift
//  ElixirWidget
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct ElixirTimelineProvider: AppIntentTimelineProvider {

    func placeholder(in context: Context) -> ElixirWidgetEntry {
        .medication(summary: .placeholder, state: .upcoming(nextDoseName: "Vitamin D", dueDate: .now.addingTimeInterval(3600)))
    }

    func snapshot(for configuration: ElixirWidgetIntent, in context: Context) async -> ElixirWidgetEntry {
        makeEntry(for: configuration, at: .now)
    }

    func timeline(for configuration: ElixirWidgetIntent, in context: Context) async -> Timeline<ElixirWidgetEntry> {
        switch configuration.displayType {
        case .medication:
            return medicationTimeline()
        case .water:
            return waterTimeline()
        case .both:
            return bothTimeline()
        }
    }

    // MARK: - Medication Timeline

    private func medicationTimeline() -> Timeline<ElixirWidgetEntry> {
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
                return .medication(date: entryDate, summary: summary, state: .projected(from: summary, at: entryDate))
            }

        return Timeline(entries: entries, policy: .atEnd)
    }

    // MARK: - Water Timeline

    private func waterTimeline() -> Timeline<ElixirWidgetEntry> {
        let now = Date()
        let summary = WidgetWaterSummary.readFromSharedContainer() ?? .empty
        let state = WaterHydrationState.from(progress: summary.progress, hasGoal: summary.goalMl > 0)

        var entries: [ElixirWidgetEntry] = [
            .water(date: now, summary: summary, state: state)
        ]

        // If celebrating (last drink < 5 min ago), add a transition entry to end celebration
        if let lastDrink = summary.lastDrinkTime {
            let celebrationEnd = lastDrink.addingTimeInterval(5 * 60)
            if celebrationEnd > now {
                entries.append(.water(date: celebrationEnd, summary: summary, state: state))
            }
        }

        // Refresh every 30 minutes to keep "last drink" timestamp current
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 30, to: now) ?? now
        return Timeline(entries: entries, policy: .after(refreshDate))
    }

    // MARK: - Both Timeline

    private func bothTimeline() -> Timeline<ElixirWidgetEntry> {
        let now = Date()
        let calendar = Calendar.current
        let store = WidgetSummaryStore.readFromSharedContainer()
        let currentDoseSummary = store?.summary(for: now) ?? .placeholder
        let waterSummary = WidgetWaterSummary.readFromSharedContainer() ?? .empty
        let hydrationState = WaterHydrationState.from(progress: waterSummary.progress, hasGoal: waterSummary.goalMl > 0)
        let horizon = calendar.date(byAdding: .day, value: 2, to: calendar.startOfDay(for: now)) ?? now

        var entryDates = Set([now])
        entryDates.formUnion(relevantTransitionDates(store: store, from: now, through: horizon))

        // Add celebration-end transition for water
        if let lastDrink = waterSummary.lastDrinkTime {
            let celebrationEnd = lastDrink.addingTimeInterval(5 * 60)
            if celebrationEnd > now && celebrationEnd < horizon {
                entryDates.insert(celebrationEnd)
            }
        }

        // Also add 30-minute refresh points for water freshness
        var waterRefresh = now
        for _ in 0..<4 {
            guard let next = calendar.date(byAdding: .minute, value: 30, to: waterRefresh) else { break }
            if next < horizon { entryDates.insert(next) }
            waterRefresh = next
        }

        let entries = entryDates
            .sorted()
            .compactMap { entryDate -> ElixirWidgetEntry? in
                let doseSummary = store?.summary(for: entryDate) ?? fallbackSummary(for: entryDate, currentSummary: currentDoseSummary)
                let doseState = WidgetState.projected(from: doseSummary, at: entryDate)
                return .both(date: entryDate, doseSummary: doseSummary, widgetState: doseState, waterSummary: waterSummary, hydrationState: hydrationState)
            }

        return Timeline(entries: entries, policy: .atEnd)
    }

    // MARK: - Helpers

    private func makeEntry(for configuration: ElixirWidgetIntent, at date: Date) -> ElixirWidgetEntry {
        switch configuration.displayType {
        case .medication:
            let summary = WidgetSummaryStore.readFromSharedContainer()?.summary(for: date) ?? .placeholder
            return .medication(date: date, summary: summary, state: .projected(from: summary, at: date))
        case .water:
            let summary = WidgetWaterSummary.readFromSharedContainer() ?? .empty
            return .water(date: date, summary: summary, state: .from(progress: summary.progress, hasGoal: summary.goalMl > 0))
        case .both:
            let doseSummary = WidgetSummaryStore.readFromSharedContainer()?.summary(for: date) ?? .placeholder
            let waterSummary = WidgetWaterSummary.readFromSharedContainer() ?? .empty
            return .both(date: date, doseSummary: doseSummary, widgetState: .projected(from: doseSummary, at: date), waterSummary: waterSummary, hydrationState: .from(progress: waterSummary.progress, hasGoal: waterSummary.goalMl > 0))
        }
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
        switch entry.displayType {
        case .medication:
            medicationView
        case .water:
            waterView
        case .both:
            bothView
        }
    }

    @ViewBuilder
    private var medicationView: some View {
        switch family {
        case .systemSmall:  SmallWidgetView(entry: entry)
        case .systemMedium: MediumWidgetView(entry: entry)
        case .systemLarge:  LargeWidgetView(entry: entry)
        default:            SmallWidgetView(entry: entry)
        }
    }

    @ViewBuilder
    private var waterView: some View {
        switch family {
        case .systemSmall:  SmallWaterWidgetView(entry: entry)
        case .systemMedium: MediumWaterWidgetView(entry: entry)
        case .systemLarge:  LargeWaterWidgetView(entry: entry)
        default:            SmallWaterWidgetView(entry: entry)
        }
    }

    @ViewBuilder
    private var bothView: some View {
        switch family {
        case .systemSmall:  SmallBothWidgetView(entry: entry)
        case .systemMedium: MediumBothWidgetView(entry: entry)
        case .systemLarge:  LargeBothWidgetView(entry: entry)
        default:            SmallBothWidgetView(entry: entry)
        }
    }
}

// MARK: - Widget Configuration

struct ElixirWidget: Widget {
    let kind: String = WidgetConstants.widgetKind

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ElixirWidgetIntent.self, provider: ElixirTimelineProvider()) { entry in
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
