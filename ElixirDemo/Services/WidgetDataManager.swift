//
//  WidgetDataManager.swift
//  Elixir: Daily Ritual
//
//  Bridge service that serializes today's dose state from SwiftData into a
//  JSON snapshot written to the shared App Group UserDefaults container.
//  The widget extension reads this snapshot — it never touches SwiftData directly.
//

import Foundation
import SwiftData
import WidgetKit

@MainActor
final class WidgetDataManager {
    static let shared = WidgetDataManager()
    private static let summaryDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private let sharedDefaults: UserDefaults?

    private init() {
        self.sharedDefaults = UserDefaults(suiteName: WidgetConstants.appGroupID)
        if sharedDefaults == nil {
            print("⚠️ WidgetDataManager: App Group '\(WidgetConstants.appGroupID)' not configured. Widget will show placeholder data.")
        }
    }

    // MARK: - Primary Sync (called from main app on every dose mutation)

    func syncToWidget(modelContext: ModelContext) {
        let calendar = Calendar.current
        let now = Date()
        let dayRange = makeDayRange(startingAt: now, dayCount: 7)
        DoseLogGenerator(modelContext: modelContext).ensureLogsExist(for: dayRange)

        var summariesByDay: [String: WidgetDoseSummary] = [:]
        var dayCursor = calendar.startOfDay(for: dayRange.lowerBound)

        for _ in 0..<7 {
            if let summary = makeSummary(for: dayCursor, now: now, modelContext: modelContext) {
                summariesByDay[Self.dayKey(for: dayCursor)] = summary
            }

            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: dayCursor) else { break }
            dayCursor = nextDay
        }

        let store = WidgetSummaryStore(
            summariesByDay: summariesByDay,
            lastUpdated: now
        )

        persist(store)
        syncWaterToWidget(modelContext: modelContext)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetConstants.widgetKind)
    }

    // MARK: - Water Sync

    func syncWaterToWidget(modelContext: ModelContext) {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else { return }

        let waterDescriptor = FetchDescriptor<WaterEntry>(
            predicate: #Predicate { entry in
                entry.date >= startOfDay && entry.date < endOfDay
            },
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        guard let todayEntries = try? modelContext.fetch(waterDescriptor) else { return }

        let settingsDescriptor = FetchDescriptor<WaterSettings>()
        let settings = (try? modelContext.fetch(settingsDescriptor))?.first

        let goalLiters = settings?.dailyGoalLiters ?? 2.0
        let goalMl = Int(goalLiters * 1000)
        let totalMl = todayEntries.reduce(0) { $0 + Int($1.amountLiters * 1000) }
        let progress = goalMl > 0 ? min(Double(totalMl) / Double(goalMl), 1.0) : 0

        let recentItems = todayEntries.prefix(10).map { entry in
            WidgetWaterEntryItem(
                id: entry.id,
                amountMl: Int(entry.amountLiters * 1000),
                date: entry.date
            )
        }

        let streak = computeWaterStreak(modelContext: modelContext, calendar: calendar)
        let reminderInterval = settings?.frequencyHours ?? 1

        let summary = WidgetWaterSummary(
            totalIntakeMl: totalMl,
            goalMl: goalMl,
            progress: progress,
            streak: streak,
            lastDrinkTime: todayEntries.first?.date,
            reminderIntervalHours: reminderInterval,
            recentEntries: recentItems,
            lastUpdated: now
        )

        persistWater(summary)
        WidgetCenter.shared.reloadTimelines(ofKind: WidgetConstants.widgetKind)
    }

    private func persistWater(_ summary: WidgetWaterSummary) {
        guard let defaults = sharedDefaults else { return }
        if let data = try? JSONEncoder().encode(summary) {
            defaults.set(data, forKey: WidgetConstants.waterSummaryKey)
        }
    }

    private func computeWaterStreak(modelContext: ModelContext, calendar: Calendar) -> Int {
        let allWaterDescriptor = FetchDescriptor<WaterEntry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        guard let allEntries = try? modelContext.fetch(allWaterDescriptor) else { return 0 }

        let groupedByDay = Dictionary(grouping: allEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        if groupedByDay[checkDate] == nil {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: checkDate) else { return 0 }
            checkDate = yesterday
        }

        while groupedByDay[checkDate] != nil {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        return streak
    }

    // MARK: - Write

    private func persist(_ store: WidgetSummaryStore) {
        guard let defaults = sharedDefaults else { return }
        if let data = try? JSONEncoder().encode(store) {
            defaults.set(data, forKey: WidgetConstants.summaryKey)
        }
    }

    // MARK: - Read (called from both app + widget process)

    static func readStore() -> WidgetSummaryStore? {
        guard
            let defaults = UserDefaults(suiteName: WidgetConstants.appGroupID),
            let data = defaults.data(forKey: WidgetConstants.summaryKey)
        else { return nil }

        if let store = try? JSONDecoder().decode(WidgetSummaryStore.self, from: data) {
            return store
        }

        guard let legacySummary = try? JSONDecoder().decode(WidgetDoseSummary.self, from: data) else {
            return nil
        }

        return WidgetSummaryStore(
            summariesByDay: [dayKey(for: Date()): legacySummary],
            lastUpdated: legacySummary.lastUpdated
        )
    }

    private func makeSummary(for date: Date, now: Date, modelContext: ModelContext) -> WidgetDoseSummary? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return nil
        }

        let descriptor = FetchDescriptor<DoseLog>(
            predicate: #Predicate { log in
                log.scheduledTime >= startOfDay && log.scheduledTime < endOfDay
            },
            sortBy: [SortDescriptor(\.scheduledTime, order: .forward)]
        )

        guard let logs = try? modelContext.fetch(descriptor) else { return nil }

        let totalToday = logs.count
        let takenToday = logs.filter { $0.status == .taken }.count
        let missedToday = logs.filter { $0.status == .missed }.count
        let pendingToday = logs.filter { $0.status == .pending }.count

        let graceCutoff = now.addingTimeInterval(-15 * 60)
        let overdueCount = logs.filter {
            $0.status == .pending && $0.scheduledTime <= graceCutoff
        }.count

        let nextDose: WidgetNextDose? = logs
            .filter { $0.status == .pending && $0.scheduledTime > now }
            .min(by: { $0.scheduledTime < $1.scheduledTime })
            .flatMap { log in
                guard let med = log.medication else { return nil }
                return WidgetNextDose(
                    medicationName: med.name,
                    dosage: med.dosage,
                    scheduledTime: log.scheduledTime,
                    iconName: med.iconName,
                    colorHex: med.colorHex,
                    secondsUntilDue: log.scheduledTime.timeIntervalSince(now)
                )
            }

        let doseItems: [WidgetDoseItem] = logs.map { log in
            let med = log.medication
            return WidgetDoseItem(
                id: log.id,
                medicationName: med?.name ?? "Unknown",
                scheduledTime: log.scheduledTime,
                status: wireStatus(for: log.status).rawValue,
                iconName: med?.iconName ?? "pills.fill",
                colorHex: med?.colorHex ?? "8E44AD"
            )
        }

        let theme = ThemeManager.shared.currentTheme
        return WidgetDoseSummary(
            totalToday: totalToday,
            takenToday: takenToday,
            missedToday: missedToday,
            pendingToday: pendingToday,
            overdueCount: overdueCount,
            nextDose: nextDose,
            todayDoseItems: doseItems,
            lastUpdated: now,
            themeAccentHex: theme.accentColor.hexString,
            themePrimaryHex: theme.primaryColor.hexString,
            themeSecondaryHex: theme.secondaryColor.hexString
        )
    }

    private func makeDayRange(startingAt date: Date, dayCount: Int) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: max(dayCount - 1, 0), to: start) ?? start
        return start...end
    }

    private func wireStatus(for status: DoseStatus) -> WidgetDoseStatus {
        switch status {
        case .pending:
            return .pending
        case .taken:
            return .taken
        case .missed:
            return .missed
        case .skipped:
            return .skipped
        }
    }

    private static func dayKey(for date: Date) -> String {
        summaryDayFormatter.string(from: date)
    }
}
