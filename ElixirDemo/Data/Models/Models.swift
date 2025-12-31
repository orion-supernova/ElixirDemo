//
//  Models.swift
//  Elixir: Daily Ritual
//
//  SwiftData models for the medication tracking system
//

import Foundation
import SwiftData
import SwiftUI

// MARK: - Stat Detail Model
@Observable
final class StatDetail: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let description: String
    let icon: String
    let color: Color

    init(title: String, value: String, description: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.description = description
        self.icon = icon
        self.color = color
    }
}

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
    var scheduledTimesBlob: Data = Data()
    var startDate: Date
    var endDate: Date? // Optional for ongoing medications

    @Transient var scheduledTimes: [Date] {
        get { (try? JSONDecoder().decode([Date].self, from: scheduledTimesBlob)) ?? [] }
        set { scheduledTimesBlob = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

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
        self.scheduledTimesBlob = (try? JSONEncoder().encode(scheduledTimes)) ?? Data()
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
    var currentStreak: Int
    var longestStreak: Int
    var totalDosesTaken: Int
    var totalDosesSkipped: Int
    var totalDosesMissed: Int
    var achievementBadgesBlob: Data = Data()
    var lastUpdated: Date

    @Transient var achievementBadges: [String] {
        get { (try? JSONDecoder().decode([String].self, from: achievementBadgesBlob)) ?? [] }
        set { achievementBadgesBlob = (try? JSONEncoder().encode(newValue)) ?? Data() }
    }

    // Computed Properties
    var currentLevel: Int {
        var calculatedLevel = 1
        // Loop through levels to find the highest we've surpassed
        for level in 1...100 { // Assuming a reasonable max level
            if totalXP >= xpRequiredForLevel(level) {
                calculatedLevel = level
            } else {
                break
            }
        }
        return calculatedLevel
    }

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

    struct TitleMilestone: Identifiable {
        let id = UUID()
        let title: String
        let levelRange: ClosedRange<Int>
        var icon: String {
            switch levelRange.lowerBound {
            case 1...12: return "leaf.fill"
            case 13...25: return "flask.fill"
            case 26...50: return "crown.fill"
            case 51...: return "sparkles"
            default: return "star.fill"
            }
        }
    }
    
    static let allMilestones: [TitleMilestone] = [
        TitleMilestone(title: "Initiate", levelRange: 1...3),
        TitleMilestone(title: "Seeker", levelRange: 4...7),
        TitleMilestone(title: "Apothecary", levelRange: 8...12),
        TitleMilestone(title: "Jade Alchemist", levelRange: 13...18),
        TitleMilestone(title: "Gold Alchemist", levelRange: 19...25),
        TitleMilestone(title: "Royal Physician", levelRange: 26...35),
        TitleMilestone(title: "Grand Master", levelRange: 36...50),
        TitleMilestone(title: "Diamond Healer", levelRange: 51...75),
        TitleMilestone(title: "Eternal Sage", levelRange: 76...99),
        TitleMilestone(title: "Legendary Ritualist", levelRange: 100...100)
    ]

    var currentTitle: String {
        switch currentLevel {
        case 1...3: return "Initiate"
        case 4...7: return "Seeker"
        case 8...12: return "Apothecary"
        case 13...18: return "Jade Alchemist"
        case 19...25: return "Gold Alchemist"
        case 26...35: return "Royal Physician"
        case 36...50: return "Grand Master"
        case 51...75: return "Diamond Healer"
        case 76...99: return "Eternal Sage"
        default: return "Legendary Ritualist"
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
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalDosesTaken = 0
        self.totalDosesSkipped = 0
        self.totalDosesMissed = 0
        self.achievementBadgesBlob = (try? JSONEncoder().encode([String]())) ?? Data()
        self.lastUpdated = Date()
    }

    // XP System Logic
    func addXP(_ amount: Int) {
        totalXP += amount
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

    // XP formula: Linear growth with cap for sustainable mastery
    private func xpRequiredForLevel(_ level: Int) -> Int {
        if level <= 1 { return 0 }
        
        // Fast onboarding (Levels 1-10)
        if level <= 10 {
            return (level - 1) * 150
        }
        
        // Sustainable pace (Levels 11+)
        // Level 10 XP is 9 * 150 = 1350.
        // Each level after 10 requires a consistent 1500 XP increase.
        return 1350 + (level - 10) * 1500
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
    var dashboardMode: DashboardMode? // Optional for safe migration
    var startHour: Int? // Optional for safe migration
    var endHour: Int?   // Optional for safe migration
    var lastUpdated: Date

    var activeStartHour: Int { startHour ?? 8 }
    var activeEndHour: Int { endHour ?? 22 }

    var activeDashboardMode: DashboardMode {
        dashboardMode ?? .both
    }

    init(
        remindersEnabled: Bool = false,
        frequencyHours: Int = 2,
        dailyGoalLiters: Double = 2.0,
        dashboardMode: DashboardMode = .both,
        startHour: Int = 8,
        endHour: Int = 22
    ) {
        self.id = UUID()
        self.remindersEnabled = remindersEnabled
        self.frequencyHours = frequencyHours
        self.dailyGoalLiters = dailyGoalLiters
        self.dashboardMode = dashboardMode
        self.startHour = startHour
        self.endHour = endHour
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
