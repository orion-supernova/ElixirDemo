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
    static let deepLinkDashboard = "elixir://dashboard"
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

// MARK: - Timeline Entry

struct ElixirWidgetEntry: TimelineEntry {
    let date: Date
    let summary: WidgetDoseSummary
    let widgetState: WidgetState
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
