//
//  Models.swift
//  Elixir: Daily Ritual
//
//  SwiftData models for the medication tracking system
//

import Foundation
import SwiftData

// MARK: - Medication Model
@Model
final class Medication {
    var id: UUID
    var name: String
    var dosage: String // e.g., "500mg", "10ml"
    var iconName: String // SF Symbol name
    var colorHex: String // Hex color for personalization
    var createdAt: Date

    // Scheduling
    var frequency: Frequency
    var scheduledTimes: [Date] = []
    var startDate: Date
    var endDate: Date? // Optional for ongoing medications

    // Relationships
    @Relationship(deleteRule: .cascade, inverse: \DoseLog.medication)
    var doseLogs: [DoseLog]

    // Computed Properties
    var isActive: Bool {
        let now = Date()
        if let end = endDate {
            return now >= startDate && now <= end
        }
        return now >= startDate
    }

    init(
        name: String,
        dosage: String,
        iconName: String = "pills.fill",
        colorHex: String = "8E44AD",
        frequency: Frequency = .daily,
        scheduledTimes: [Date] = [],
        startDate: Date = Date(),
        endDate: Date? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.dosage = dosage
        self.iconName = iconName
        self.colorHex = colorHex
        self.frequency = frequency
        self.scheduledTimes = scheduledTimes
        self.startDate = startDate
        self.endDate = endDate
        self.createdAt = Date()
        self.doseLogs = []
    }
}

// MARK: - Frequency Enum
enum Frequency: String, Codable, CaseIterable {
    case daily = "Daily"
    case twiceDaily = "Twice Daily"
    case threeTimesDaily = "3× Daily"
    case fourTimesDaily = "4× Daily"
    case asNeeded = "As Needed"
    case everyOtherDay = "Every Other Day"
    case weekly = "Weekly"
    case specificDays = "Specific Days"

    var timesPerDay: Int {
        switch self {
        case .daily: return 1
        case .twiceDaily: return 2
        case .threeTimesDaily: return 3
        case .fourTimesDaily: return 4
        case .asNeeded: return 0
        case .everyOtherDay: return 1
        case .weekly: return 1
        case .specificDays: return 1
        }
    }
}

// MARK: - DoseLog Model
@Model
final class DoseLog {
    var id: UUID
    var scheduledTime: Date
    var takenTime: Date?
    var status: DoseStatus
    var notes: String?
    var createdAt: Date

    // Relationships
    var medication: Medication?

    // Computed Properties
    var isTaken: Bool {
        status == .taken
    }

    var isSkipped: Bool {
        status == .skipped
    }

    var isMissed: Bool {
        status == .missed
    }

    var isPending: Bool {
        status == .pending
    }

    init(
        scheduledTime: Date,
        medication: Medication? = nil,
        status: DoseStatus = .pending,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.scheduledTime = scheduledTime
        self.medication = medication
        self.status = status
        self.notes = notes
        self.createdAt = Date()
    }

    func markAsTaken(at time: Date = Date()) {
        self.status = .taken
        self.takenTime = time
    }

    func markAsSkipped() {
        self.status = .skipped
        self.takenTime = Date()
    }

    func markAsMissed() {
        self.status = .missed
    }
}

// MARK: - DoseStatus Enum
enum DoseStatus: String, Codable {
    case pending = "Pending"
    case taken = "Taken"
    case skipped = "Skipped"
    case missed = "Missed"

    var color: String {
        switch self {
        case .pending: return "F1C40F" // Gold
        case .taken: return "2ECC71" // Green
        case .skipped: return "95A5A6" // Gray
        case .missed: return "E74C3C" // Red
        }
    }

    var iconName: String {
        switch self {
        case .pending: return "clock.fill"
        case .taken: return "checkmark.circle.fill"
        case .skipped: return "xmark.circle.fill"
        case .missed: return "exclamationmark.triangle.fill"
        }
    }
}

// MARK: - UserStats Model
@Model
final class UserStats {
    var id: UUID
    var totalXP: Int
    var currentLevel: Int
    var currentStreak: Int
    var longestStreak: Int
    var totalDosesTaken: Int
    var totalDosesSkipped: Int
    var totalDosesMissed: Int
    var achievementBadges: [String] = []
    var lastUpdated: Date

    // Computed Properties
    var xpToNextLevel: Int {
        xpRequiredForLevel(currentLevel + 1)
    }

    var progressToNextLevel: Double {
        let currentLevelXP = xpRequiredForLevel(currentLevel)
        let nextLevelXP = xpRequiredForLevel(currentLevel + 1)
        let levelRange = nextLevelXP - currentLevelXP
        let currentProgress = totalXP - currentLevelXP

        guard levelRange > 0 else { return 0 }
        return min(Double(currentProgress) / Double(levelRange), 1.0)
    }

    var currentTitle: String {
        switch currentLevel {
        case 1...5: return "Apprentice"
        case 6...15: return "Alchemist"
        case 16...30: return "Master"
        case 31...50: return "Immortal"
        default: return "Legend"
        }
    }

    var completionRate: Double {
        let total = totalDosesTaken + totalDosesSkipped + totalDosesMissed
        guard total > 0 else { return 0 }
        return Double(totalDosesTaken) / Double(total)
    }

    init() {
        self.id = UUID()
        self.totalXP = 0
        self.currentLevel = 1
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalDosesTaken = 0
        self.totalDosesSkipped = 0
        self.totalDosesMissed = 0
        self.achievementBadges = []
        self.lastUpdated = Date()
    }

    // XP System Logic
    func addXP(_ amount: Int) {
        totalXP += amount
        updateLevel()
        lastUpdated = Date()
    }

    func incrementStreak() {
        currentStreak += 1
        if currentStreak > longestStreak {
            longestStreak = currentStreak
        }
        lastUpdated = Date()
    }

    func resetStreak() {
        currentStreak = 0
        lastUpdated = Date()
    }

    func recordDoseTaken() {
        totalDosesTaken += 1
        addXP(10) // +10 XP per dose
    }

    func recordDoseSkipped() {
        totalDosesSkipped += 1
        lastUpdated = Date()
    }

    func recordDoseMissed() {
        totalDosesMissed += 1
        lastUpdated = Date()
    }

    private func updateLevel() {
        var newLevel = 1
        for level in 1...100 {
            if totalXP >= xpRequiredForLevel(level) {
                newLevel = level
            } else {
                break
            }
        }
        currentLevel = newLevel
    }

    // XP formula: exponential growth
    private func xpRequiredForLevel(_ level: Int) -> Int {
        if level <= 1 { return 0 }
        return Int(pow(Double(level - 1), 2.0) * 50)
    }
}

// MARK: - Preview Helpers
extension Medication {
    static var preview: Medication {
        let med = Medication(
            name: "Vitamin D",
            dosage: "1000 IU",
            iconName: "sun.max.fill",
            colorHex: "FBBF24",
            frequency: .daily,
            scheduledTimes: [Calendar.current.date(from: DateComponents(hour: 8, minute: 0))!],
            startDate: Date()
        )
        return med
    }

    static var previews: [Medication] {
        [
            Medication(
                name: "Vitamin D",
                dosage: "1000 IU",
                iconName: "sun.max.fill",
                colorHex: "FBBF24"
            ),
            Medication(
                name: "Omega-3",
                dosage: "500mg",
                iconName: "drop.fill",
                colorHex: "60A5FA"
            ),
            Medication(
                name: "Aspirin",
                dosage: "81mg",
                iconName: "heart.fill",
                colorHex: "F87171"
            )
        ]
    }
}

extension DoseLog {
    static var preview: DoseLog {
        let med = Medication.preview
        return DoseLog(
            scheduledTime: Date(),
            medication: med,
            status: .pending
        )
    }
}

extension UserStats {
    static var preview: UserStats {
        let stats = UserStats()
        stats.totalXP = 450
        stats.currentLevel = 5
        stats.currentStreak = 7
        stats.longestStreak = 14
        stats.totalDosesTaken = 45
        stats.totalDosesSkipped = 3
        stats.totalDosesMissed = 2
        return stats
    }
}

// MARK: - Dashboard Mode Enum
enum DashboardMode: String, Codable, CaseIterable, Identifiable {
    case both = "Both"
    case medicationOnly = "Medication Only"
    case waterOnly = "Water Only"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .both: return "square.grid.2x2.fill"
        case .medicationOnly: return "pills.fill"
        case .waterOnly: return "drop.fill"
        }
    }
}

// MARK: - WaterSettings Model
@Model
final class WaterSettings {
    var id: UUID
    var remindersEnabled: Bool
    var frequencyHours: Int // e.g., 1, 2, 4, 6
    var dailyGoalLiters: Double
    var showStatsOnDashboard: Bool
    var dashboardMode: DashboardMode? // Optional for safe migration
    var lastUpdated: Date

    var activeDashboardMode: DashboardMode {
        dashboardMode ?? .both
    }

    init(
        remindersEnabled: Bool = false,
        frequencyHours: Int = 2,
        dailyGoalLiters: Double = 2.0,
        showStatsOnDashboard: Bool = true,
        dashboardMode: DashboardMode = .both
    ) {
        self.id = UUID()
        self.remindersEnabled = remindersEnabled
        self.frequencyHours = frequencyHours
        self.dailyGoalLiters = dailyGoalLiters
        self.showStatsOnDashboard = showStatsOnDashboard
        self.dashboardMode = dashboardMode
        self.lastUpdated = Date()
    }
}

// MARK: - WaterEntry Model
@Model
final class WaterEntry {
    var id: UUID
    var amountLiters: Double
    var date: Date

    init(amountLiters: Double, date: Date = Date()) {
        self.id = UUID()
        self.amountLiters = amountLiters
        self.date = date
    }
}

// MARK: - Water Preview Helpers
extension WaterSettings {
    static var preview: WaterSettings {
        WaterSettings(remindersEnabled: true, frequencyHours: 2, dailyGoalLiters: 2.0)
    }
}

extension WaterEntry {
    static var previews: [WaterEntry] {
        let calendar = Calendar.current
        let today = Date()
        return [
            WaterEntry(amountLiters: 0.25, date: calendar.date(byAdding: .hour, value: -4, to: today)!),
            WaterEntry(amountLiters: 0.5, date: calendar.date(byAdding: .hour, value: -2, to: today)!),
            WaterEntry(amountLiters: 0.25, date: today)
        ]
    }
}
