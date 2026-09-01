//
//  WidgetDataTypes.swift
//  Elixir: Daily Ritual
//
//  Shared Codable types used by WidgetDataManager (main app) to produce
//  and serialize the widget snapshot. The widget extension defines the same
//  types independently in WidgetModels.swift — JSON is the interchange format,
//  so the structs must have matching field names but need not share a binary type.
//

import Foundation

// MARK: - Constants

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

struct WidgetDoseSummary: Codable {
    let totalToday: Int
    let takenToday: Int
    let missedToday: Int
    let pendingToday: Int
    let overdueCount: Int
    let nextDose: WidgetNextDose?
    let todayDoseItems: [WidgetDoseItem]
    let lastUpdated: Date
    let themeAccentHex: String
    let themePrimaryHex: String
    let themeSecondaryHex: String
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
}

struct WidgetWaterEntryItem: Codable, Identifiable {
    let id: UUID
    let amountMl: Int
    let date: Date
}
