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
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<DoseLog>(
            predicate: #Predicate { log in
                log.scheduledTime >= startOfDay && log.scheduledTime < endOfDay
            },
            sortBy: [SortDescriptor(\.scheduledTime, order: .forward)]
        )

        guard let logs = try? modelContext.fetch(descriptor) else { return }

        let totalToday = logs.count
        let takenToday = logs.filter { $0.status == .taken }.count
        let missedToday = logs.filter { $0.status == .missed }.count
        let pendingToday = logs.filter { $0.status == .pending }.count

        // 15-minute grace period: a dose is "overdue" if still pending
        // and its scheduled time was more than 15 minutes ago.
        let graceCutoff = now.addingTimeInterval(-15 * 60)
        let overdueCount = logs.filter {
            $0.status == .pending && $0.scheduledTime <= graceCutoff
        }.count

        // Next upcoming dose: first pending log scheduled in the future
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

        // Up to 5 items for the dose list in medium/large widget
        let doseItems: [WidgetDoseItem] = logs.prefix(5).map { log in
            let med = log.medication
            return WidgetDoseItem(
                id: log.id,
                medicationName: med?.name ?? "Unknown",
                scheduledTime: log.scheduledTime,
                status: log.status.rawValue,
                iconName: med?.iconName ?? "pills.fill",
                colorHex: med?.colorHex ?? "8E44AD"
            )
        }

        // Capture theme colors (safe: @MainActor matches ThemeManager.shared)
        let theme = ThemeManager.shared.currentTheme
        let summary = WidgetDoseSummary(
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

        persist(summary)
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Write

    private func persist(_ summary: WidgetDoseSummary) {
        guard let defaults = sharedDefaults else { return }
        if let data = try? JSONEncoder().encode(summary) {
            defaults.set(data, forKey: WidgetConstants.summaryKey)
        }
    }

    // MARK: - Read (called from both app + widget process)

    static func readSummary() -> WidgetDoseSummary? {
        guard
            let defaults = UserDefaults(suiteName: WidgetConstants.appGroupID),
            let data = defaults.data(forKey: WidgetConstants.summaryKey),
            let summary = try? JSONDecoder().decode(WidgetDoseSummary.self, from: data)
        else { return nil }
        return summary
    }
}
