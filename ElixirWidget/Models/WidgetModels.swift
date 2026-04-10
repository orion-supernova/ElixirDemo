//
//  WidgetModels.swift
//  Elixir: Daily Ritual
//
//  Shared Codable types for the widget extension and main app.
//  Pure Foundation — no SwiftData, no SwiftUI, no UIKit imports.
//  This file is compiled into BOTH the ElixirDemo and ElixirWidget targets.
//

import Foundation
import WidgetKit

// MARK: - App Group Constants

enum WidgetConstants {
    static let appGroupID = "group.com.walhallaa.ElixirDemo"
    static let summaryKey = "widget_dose_summary_v1"
    static let waterSummaryKey = "widget_water_summary_v1"
    static let deepLinkDashboard = "elixir://dashboard"
    static let deepLinkWater = "elixir://water"
    static let widgetKind = "ElixirWidget"
}

// MARK: - Wire Types

struct WidgetSummaryStore: Codable {
    let summariesByDay: [String: WidgetDoseSummary]
    let lastUpdated: Date
}

/// A snapshot of today's medication adherence, serialized from SwiftData
/// by the main app and read by the widget extension.
struct WidgetDoseSummary: Codable {
    let totalToday: Int
    let takenToday: Int
    let missedToday: Int
    let pendingToday: Int
    /// Pending doses whose scheduled time passed more than 15 minutes ago.
    let overdueCount: Int
    let nextDose: WidgetNextDose?
    /// Ordered dose items used for list rendering and projected state changes.
    let todayDoseItems: [WidgetDoseItem]
    let lastUpdated: Date
    // Theme colors as hex strings (resolved in dark mode) so the widget
    // can reflect the user's chosen theme without importing ThemeManager.
    let themeAccentHex: String
    let themePrimaryHex: String
    let themeSecondaryHex: String

    var isEmpty: Bool { totalToday == 0 }
    var isAllDone: Bool { totalToday > 0 && takenToday == totalToday }
}

struct WidgetNextDose: Codable {
    let medicationName: String
    let dosage: String
    let scheduledTime: Date
    let iconName: String
    let colorHex: String
    let secondsUntilDue: TimeInterval
}

struct WidgetDoseItem: Codable, Identifiable {
    let id: UUID
    let medicationName: String
    let scheduledTime: Date
    /// Raw status string: "taken" | "pending" | "missed" | "skipped"
    let status: String
    let iconName: String
    let colorHex: String
}

enum WidgetDoseStatus: String {
    case pending
    case taken
    case missed
    case skipped
}

// MARK: - Water Widget Types

struct WidgetWaterSummary: Codable {
    let totalIntakeMl: Int
    let goalMl: Int
    let progress: Double
    let streak: Int
    let lastDrinkTime: Date?
    let reminderIntervalHours: Int
    let recentEntries: [WidgetWaterEntryItem]
    let lastUpdated: Date

    var isEmpty: Bool { goalMl == 0 }

    /// Whether the user hasn't had water within their reminder interval.
    func isWaterOverdue(at date: Date) -> Bool {
        guard reminderIntervalHours > 0, let lastDrink = lastDrinkTime else {
            return totalIntakeMl == 0
        }
        let intervalSeconds = Double(reminderIntervalHours) * 3600
        return date.timeIntervalSince(lastDrink) >= intervalSeconds
    }
}

struct WidgetWaterEntryItem: Codable, Identifiable {
    let id: UUID
    let amountMl: Int
    let date: Date
}

// MARK: - Water Hydration State

enum WaterHydrationState: Equatable {
    case dehydrated
    case thirsty
    case hydrating
    case fullyHydrated
    case empty

    static func from(progress: Double, hasGoal: Bool) -> WaterHydrationState {
        if !hasGoal { return .empty }
        switch progress {
        case ..<0.25:  return .dehydrated
        case ..<0.50:  return .thirsty
        case ..<0.75:  return .hydrating
        default:       return .fullyHydrated
        }
    }

    var stateLabel: String {
        switch self {
        case .dehydrated:    return "Drink up!"
        case .thirsty:       return "Stay hydrated!"
        case .hydrating:     return "Keep going!"
        case .fullyHydrated: return "Great job!"
        case .empty:         return "Set a goal"
        }
    }
}

// MARK: - Water Shared Container Read

extension WidgetWaterSummary {
    static func readFromSharedContainer() -> WidgetWaterSummary? {
        guard
            let defaults = UserDefaults(suiteName: WidgetConstants.appGroupID),
            let data = defaults.data(forKey: WidgetConstants.waterSummaryKey)
        else { return nil }
        return try? JSONDecoder().decode(WidgetWaterSummary.self, from: data)
    }
}

// MARK: - Shared Container Read

extension WidgetDoseSummary {
    static func readFromSharedContainer() -> WidgetDoseSummary? {
        WidgetSummaryStore.readFromSharedContainer()?.summary(for: Date())
    }
}

extension WidgetSummaryStore {
    private static let summaryDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func readFromSharedContainer() -> WidgetSummaryStore? {
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

    func summary(for date: Date) -> WidgetDoseSummary? {
        summariesByDay[Self.dayKey(for: date)]
    }

    private static func dayKey(for date: Date) -> String {
        summaryDayFormatter.string(from: date)
    }
}

// MARK: - Widget State

enum WidgetState: Equatable {
    case allDone
    case upcoming(nextDoseName: String, dueDate: Date)
    case overdue(count: Int)
    case empty

    static func from(_ summary: WidgetDoseSummary) -> WidgetState {
        projected(from: summary, at: .now)
    }

    static func projected(from summary: WidgetDoseSummary, at date: Date) -> WidgetState {
        if summary.isEmpty { return .empty }

        let pendingItems = summary.todayDoseItems
            .filter { $0.status == WidgetDoseStatus.pending.rawValue }
            .sorted { $0.scheduledTime < $1.scheduledTime }

        let overdueCount = pendingItems.filter {
            $0.scheduledTime.addingTimeInterval(15 * 60) <= date
        }.count + summary.missedToday

        if overdueCount > 0 {
            return .overdue(count: overdueCount)
        }

        if let nextPending = pendingItems.first(where: { $0.scheduledTime.addingTimeInterval(15 * 60) > date }) {
            return .upcoming(nextDoseName: nextPending.medicationName, dueDate: nextPending.scheduledTime)
        }

        if summary.pendingToday == 0 && summary.missedToday == 0 {
            return .allDone
        }

        return .empty
    }

    var stateLabel: String {
        switch self {
        case .allDone:
            return "All done today!"
        case .upcoming(let name, _):
            return "Next: \(name)"
        case .overdue(let count):
            return count == 1 ? "You missed 1 dose!" : "You missed \(count) doses!"
        case .empty:
            return "No doses today"
        }
    }
}

// MARK: - Display Type

enum WidgetDisplayType: String {
    case medication
    case water
    case both
}

// MARK: - Timeline Entry

struct ElixirWidgetEntry: TimelineEntry {
    let date: Date
    let displayType: WidgetDisplayType
    // Medication
    let doseSummary: WidgetDoseSummary
    let widgetState: WidgetState
    // Water
    let waterSummary: WidgetWaterSummary
    let hydrationState: WaterHydrationState

    /// Whether water was logged within the last 5 minutes — triggers celebration UI.
    var isCelebrating: Bool {
        guard displayType != .medication,
              let lastDrink = waterSummary.lastDrinkTime else { return false }
        return date.timeIntervalSince(lastDrink) < 5 * 60
    }

    /// Amount of the most recent water entry, used for the "+Xml" celebration badge.
    var lastDrinkAmountMl: Int? {
        waterSummary.recentEntries.first?.amountMl
    }

    /// Convenience for medication-mode entries and previews.
    static func medication(date: Date = .now, summary: WidgetDoseSummary, state: WidgetState) -> ElixirWidgetEntry {
        ElixirWidgetEntry(
            date: date, displayType: .medication,
            doseSummary: summary, widgetState: state,
            waterSummary: .empty, hydrationState: .empty
        )
    }

    /// Convenience for water-mode entries and previews.
    static func water(date: Date = .now, summary: WidgetWaterSummary, state: WaterHydrationState) -> ElixirWidgetEntry {
        ElixirWidgetEntry(
            date: date, displayType: .water,
            doseSummary: .empty, widgetState: .empty,
            waterSummary: summary, hydrationState: state
        )
    }

    /// Convenience for both-mode entries and previews.
    static func both(date: Date = .now, doseSummary: WidgetDoseSummary, widgetState: WidgetState, waterSummary: WidgetWaterSummary, hydrationState: WaterHydrationState) -> ElixirWidgetEntry {
        ElixirWidgetEntry(
            date: date, displayType: .both,
            doseSummary: doseSummary, widgetState: widgetState,
            waterSummary: waterSummary, hydrationState: hydrationState
        )
    }
}

// MARK: - Placeholder / Preview Data

extension WidgetDoseSummary {
    static var placeholder: WidgetDoseSummary {
        WidgetDoseSummary(
            totalToday: 3, takenToday: 1, missedToday: 0, pendingToday: 2,
            overdueCount: 0,
            nextDose: WidgetNextDose(
                medicationName: "Omega-3",
                dosage: "500mg",
                scheduledTime: Date().addingTimeInterval(3600),
                iconName: "drop.fill",
                colorHex: "60A5FA",
                secondsUntilDue: 3600
            ),
            todayDoseItems: [
                WidgetDoseItem(id: UUID(), medicationName: "Vitamin D", scheduledTime: Date().addingTimeInterval(-3600), status: "taken", iconName: "sun.max.fill", colorHex: "FCD34D"),
                WidgetDoseItem(id: UUID(), medicationName: "Omega-3", scheduledTime: Date().addingTimeInterval(3600), status: "pending", iconName: "drop.fill", colorHex: "60A5FA"),
                WidgetDoseItem(id: UUID(), medicationName: "Magnesium", scheduledTime: Date().addingTimeInterval(7200), status: "pending", iconName: "bolt.fill", colorHex: "A78BFA")
            ],
            lastUpdated: Date(),
            themeAccentHex: "FCD34D", themePrimaryHex: "FFD700", themeSecondaryHex: "3B82F6"
        )
    }

    static var allDone: WidgetDoseSummary {
        WidgetDoseSummary(
            totalToday: 3, takenToday: 3, missedToday: 0, pendingToday: 0,
            overdueCount: 0, nextDose: nil,
            todayDoseItems: [
                WidgetDoseItem(id: UUID(), medicationName: "Vitamin D", scheduledTime: Date().addingTimeInterval(-7200), status: "taken", iconName: "sun.max.fill", colorHex: "FCD34D"),
                WidgetDoseItem(id: UUID(), medicationName: "Omega-3", scheduledTime: Date().addingTimeInterval(-3600), status: "taken", iconName: "drop.fill", colorHex: "60A5FA"),
                WidgetDoseItem(id: UUID(), medicationName: "Magnesium", scheduledTime: Date().addingTimeInterval(-1800), status: "taken", iconName: "bolt.fill", colorHex: "A78BFA")
            ],
            lastUpdated: Date(),
            themeAccentHex: "FCD34D", themePrimaryHex: "FFD700", themeSecondaryHex: "3B82F6"
        )
    }

    static var overdue: WidgetDoseSummary {
        WidgetDoseSummary(
            totalToday: 3, takenToday: 1, missedToday: 0, pendingToday: 2,
            overdueCount: 2, nextDose: nil,
            todayDoseItems: [
                WidgetDoseItem(id: UUID(), medicationName: "Vitamin D", scheduledTime: Date().addingTimeInterval(-7200), status: "taken", iconName: "sun.max.fill", colorHex: "FCD34D"),
                WidgetDoseItem(id: UUID(), medicationName: "Omega-3", scheduledTime: Date().addingTimeInterval(-3600), status: "pending", iconName: "drop.fill", colorHex: "60A5FA"),
                WidgetDoseItem(id: UUID(), medicationName: "Magnesium", scheduledTime: Date().addingTimeInterval(-1800), status: "pending", iconName: "bolt.fill", colorHex: "A78BFA")
            ],
            lastUpdated: Date(),
            themeAccentHex: "FCA5A5", themePrimaryHex: "EF4444", themeSecondaryHex: "DC2626"
        )
    }

    static var empty: WidgetDoseSummary {
        WidgetDoseSummary(
            totalToday: 0, takenToday: 0, missedToday: 0, pendingToday: 0,
            overdueCount: 0, nextDose: nil, todayDoseItems: [],
            lastUpdated: Date(),
            themeAccentHex: "94A3B8", themePrimaryHex: "64748B", themeSecondaryHex: "475569"
        )
    }
}

// MARK: - Water Preview Data

extension WidgetWaterSummary {
    static var placeholder: WidgetWaterSummary {
        WidgetWaterSummary(
            totalIntakeMl: 1200, goalMl: 2000, progress: 0.6, streak: 3,
            lastDrinkTime: Date().addingTimeInterval(-1800),
            reminderIntervalHours: 1,
            recentEntries: [
                WidgetWaterEntryItem(id: UUID(), amountMl: 500, date: Date().addingTimeInterval(-1800)),
                WidgetWaterEntryItem(id: UUID(), amountMl: 200, date: Date().addingTimeInterval(-5400)),
                WidgetWaterEntryItem(id: UUID(), amountMl: 500, date: Date().addingTimeInterval(-10800))
            ],
            lastUpdated: Date()
        )
    }

    static var fullyHydrated: WidgetWaterSummary {
        WidgetWaterSummary(
            totalIntakeMl: 2100, goalMl: 2000, progress: 1.0, streak: 7,
            lastDrinkTime: Date().addingTimeInterval(-600),
            reminderIntervalHours: 1,
            recentEntries: [
                WidgetWaterEntryItem(id: UUID(), amountMl: 200, date: Date().addingTimeInterval(-600)),
                WidgetWaterEntryItem(id: UUID(), amountMl: 500, date: Date().addingTimeInterval(-3600)),
                WidgetWaterEntryItem(id: UUID(), amountMl: 750, date: Date().addingTimeInterval(-7200)),
                WidgetWaterEntryItem(id: UUID(), amountMl: 500, date: Date().addingTimeInterval(-14400)),
                WidgetWaterEntryItem(id: UUID(), amountMl: 200, date: Date().addingTimeInterval(-21600))
            ],
            lastUpdated: Date()
        )
    }

    static var dehydrated: WidgetWaterSummary {
        WidgetWaterSummary(
            totalIntakeMl: 200, goalMl: 2000, progress: 0.1, streak: 0,
            lastDrinkTime: Date().addingTimeInterval(-14400),
            reminderIntervalHours: 1,
            recentEntries: [
                WidgetWaterEntryItem(id: UUID(), amountMl: 200, date: Date().addingTimeInterval(-14400))
            ],
            lastUpdated: Date()
        )
    }

    static var empty: WidgetWaterSummary {
        WidgetWaterSummary(
            totalIntakeMl: 0, goalMl: 2000, progress: 0, streak: 0,
            lastDrinkTime: nil, reminderIntervalHours: 1,
            recentEntries: [],
            lastUpdated: Date()
        )
    }
}
