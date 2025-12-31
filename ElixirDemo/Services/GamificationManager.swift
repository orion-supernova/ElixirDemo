//
//  GamificationManager.swift
//  Elixir: Daily Ritual
//
//  Handles XP, leveling, streaks, and achievement logic
//

import Foundation
import SwiftData
import SwiftUI

enum StatType {
    case medicationStreak
    case waterStreak
    case perfectDays
    case consistency
    case level
}

@MainActor
@Observable
final class GamificationManager {
    private let modelContext: ModelContext

    // Constants - Balanced for Sustainable Mastery
    static let xpPerDose = 30
    static let xpPerWaterIntake = 10
    static let xpBonusWaterGoal = 50
    static let xpBonusPerfectDay = 100
    static let xpBonusPerfectWeek = 1000

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Get or Create User Stats
    func getUserStats() -> UserStats {
        let descriptor = FetchDescriptor<UserStats>()
        let stats = try? modelContext.fetch(descriptor)

        if let existingStats = stats?.first {
            return existingStats
        } else {
            let newStats = UserStats()
            modelContext.insert(newStats)
            try? modelContext.save()
            return newStats
        }
    }

    // MARK: - XP with Multipliers
    func addXP(amount: Int) {
        let stats = getUserStats()
        let multiplier = calculateCurrentMultiplier()
        let finalXP = Int(Double(amount) * multiplier)
        stats.addXP(finalXP)
    }

    func calculateCurrentMultiplier() -> Double {
        let medStreak = calculateMedicationStreak()
        let waterStreak = calculateWaterGoalStreak()
        let highestStreak = max(medStreak, waterStreak)
        
        switch highestStreak {
        case 0...2: return 1.0
        case 3...6: return 1.1 // Bronze Flame
        case 7...13: return 1.3 // Silver Flame
        case 14...29: return 1.6 // Gold Flame
        case 30...: return 2.0 // Diamond Flame
        default: return 1.0
        }
    }

    // MARK: - Dose Recording
    func recordDoseTaken(for doseLog: DoseLog) {
        let stats = getUserStats()

        doseLog.markAsTaken()
        stats.totalDosesTaken += 1
        
        // Use the new multiplied XP method
        addXP(amount: Self.xpPerDose)

        // Check for Perfect Day (if this was the last dose)
        checkPerfectDayBonus()

        // Check for achievements
        checkStreakAchievements(stats: stats)

        try? modelContext.save()
    }

    func recordDoseSkipped(for doseLog: DoseLog) {
        let stats = getUserStats()

        doseLog.markAsSkipped()
        stats.recordDoseSkipped()

        try? modelContext.save()
    }

    func recordDoseMissed(for doseLog: DoseLog) {
        let stats = getUserStats()

        doseLog.markAsMissed()
        stats.recordDoseMissed()

        try? modelContext.save()
    }

    func recordWaterRitual(amount: Double, goal: Double, totalTodayBefore: Double) {
        // Base XP for logging
        addXP(amount: Self.xpPerWaterIntake)
        
        // Check if this entry pushes user over the daily goal
        let totalAfter = totalTodayBefore + amount
        if totalTodayBefore < goal && totalAfter >= goal {
            addXP(amount: Self.xpBonusWaterGoal)
            
            // Check for Perfect Day (once water goal is hit)
            checkPerfectDayBonus()
        }
        
        try? modelContext.save()
    }

    private func checkPerfectDayBonus() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let descriptor = FetchDescriptor<WaterSettings>()
        let settings = (try? modelContext.fetch(descriptor).first) ?? WaterSettings()
        let mode = settings.activeDashboardMode
        let waterGoal = settings.dailyGoalLiters
        
        let medsDone = mode == .waterOnly || {
            let logs = getDoseLogs(for: today)
            return !logs.isEmpty && logs.allSatisfy({ $0.isTaken })
        }()
        
        let waterDone = mode == .medicationOnly || {
            return getWaterIntake(for: today) >= waterGoal
        }()
        
        if medsDone && waterDone {
            // Already awarded today? We should check if we already gave it.
            // For now, simple implementation - in a real app we'd track 'lastBonusDate'
            addXP(amount: Self.xpBonusPerfectDay)
        }
    }

    // MARK: - Streak Calculation (Historical)
    func calculateMedicationStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // Check if today has any doses and if they are all taken
        // If today has doses but not all are taken, the streak hasn't ended yet (it's pending), 
        // so we start counting from yesterday.
        let todayLogs = getDoseLogs(for: checkDate)
        if !todayLogs.isEmpty && !todayLogs.allSatisfy({ $0.isTaken }) {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        while true {
            let logs = getDoseLogs(for: checkDate)
            if logs.isEmpty {
                // No doses scheduled for this day? If it's in the past, we consider it a gap.
                // UNLESS we want to skip empty days. But usually gaps break streaks.
                break
            }
            
            if logs.allSatisfy({ $0.isTaken }) {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        
        return streak
    }
    
    func calculateWaterGoalStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // Get goals and entries
        let descriptor = FetchDescriptor<WaterSettings>()
        let settings = (try? modelContext.fetch(descriptor).first) ?? WaterSettings()
        let goal = settings.dailyGoalLiters
        
        // If today's goal isn't met, check yesterday to see if we HAVE a streak
        if getWaterIntake(for: checkDate) < goal {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        while true {
            if getWaterIntake(for: checkDate) >= goal {
                streak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else {
                break
            }
        }
        
        return streak
    }

    func calculatePerfectDays() -> Int {
        let calendar = Calendar.current
        let descriptor = FetchDescriptor<WaterSettings>()
        let mode = (try? modelContext.fetch(descriptor).first)?.activeDashboardMode ?? .both
        let waterGoal = (try? modelContext.fetch(descriptor).first)?.dailyGoalLiters ?? 2.0
        
        // Find the date of the very first record (either Water or DoseLog)
        let waterDescriptor = FetchDescriptor<WaterEntry>(sortBy: [SortDescriptor(\.date, order: .forward)])
        let doseDescriptor = FetchDescriptor<DoseLog>(sortBy: [SortDescriptor(\.scheduledTime, order: .forward)])
        
        let firstWater = try? modelContext.fetch(waterDescriptor).first?.date
        let firstDose = try? modelContext.fetch(doseDescriptor).first?.scheduledTime
        
        guard let startDate = [firstWater, firstDose].compactMap({ $0 }).min() else { return 0 }
        
        var count = 0
        var checkDate = calendar.startOfDay(for: startDate)
        let today = calendar.startOfDay(for: Date())
        
        while checkDate <= today {
            let medsDone = mode == .waterOnly || {
                let logs = getDoseLogs(for: checkDate)
                return !logs.isEmpty && logs.allSatisfy({ $0.isTaken })
            }()
            
            let waterDone = mode == .medicationOnly || {
                return getWaterIntake(for: checkDate) >= waterGoal
            }()
            
            if medsDone && waterDone {
                count += 1
            }
            
            checkDate = calendar.date(byAdding: .day, value: 1, to: checkDate)!
        }
        
        return count
    }

    func calculateHolisticConsistency() -> Double {
        let stats = getUserStats()
        let calendar = Calendar.current
        
        // 1. Medication Component
        let totalMedsScheduled = stats.totalDosesTaken + stats.totalDosesSkipped + stats.totalDosesMissed
        let medConsistency = totalMedsScheduled > 0 ? Double(stats.totalDosesTaken) / Double(totalMedsScheduled) : 1.0
        
        // 2. Water Component
        let descriptor = FetchDescriptor<WaterSettings>()
        let waterGoal = (try? modelContext.fetch(descriptor).first) ?? WaterSettings()
        let activeWaterGoal = waterGoal.dailyGoalLiters
        
        let waterDescriptor = FetchDescriptor<WaterEntry>(sortBy: [SortDescriptor(\.date, order: .forward)])
        guard let firstWaterDate = try? modelContext.fetch(waterDescriptor).first?.date else {
            // If no water tracking yet, consistency is just meds
            return medConsistency
        }
        
        let startDate = calendar.startOfDay(for: firstWaterDate)
        let today = calendar.startOfDay(for: Date())
        let totalDays = calendar.dateComponents([.day], from: startDate, to: today).day ?? 0
        let activeDays = totalDays + 1 // Include today
        
        var waterSuccessDays = 0
        var checkDate = startDate
        while checkDate <= today {
            if getWaterIntake(for: checkDate) >= activeWaterGoal {
                waterSuccessDays += 1
            }
            checkDate = calendar.date(byAdding: .day, value: 1, to: checkDate)!
        }
        
        let waterConsistency = Double(waterSuccessDays) / Double(activeDays)
        
        // 3. Holistic Average
        // If we are in "Both" mode, average them. Otherwise use the relevant one.
        let mode = waterGoal.activeDashboardMode
        
        switch mode {
        case .medicationOnly: return medConsistency
        case .waterOnly: return waterConsistency
        case .both: return (medConsistency + waterConsistency) / 2.0
        }
    }

    // MARK: - Centralized Metatada (SOLID)
    func explanationDetail(for type: StatType, mode: DashboardMode, theme: any ThemeProtocol) -> StatDetail {
        let stats = getUserStats()
        
        switch type {
        case .medicationStreak:
            let val = calculateMedicationStreak()
            return StatDetail(
                title: "Medication Streak",
                value: "\(val)",
                description: "Your consistency with remedies. Increases every day you successfully take 100% of your scheduled doses.\n\n🔥 STREAK MULTIPLIER: High streaks multiply ALL XP earned, up to 2.0x!",
                icon: "pill.fill",
                color: theme.errorColor
            )
            
        case .waterStreak:
            let val = calculateWaterGoalStreak()
            return StatDetail(
                title: "Water Streak",
                value: "\(val)",
                description: "Your hydration consistency. Increases every day you meet 100% of your daily water goal.\n\n🔥 STREAK MULTIPLIER: High streaks multiply ALL XP earned, up to 2.0x!",
                icon: "drop.fill",
                color: theme.primaryColor
            )
            
        case .perfectDays:
            let val = calculatePerfectDays()
            let desc = mode == .both 
                ? "The ultimate milestone. Achieved on days when you complete every single medication dose AND hit your water goal."
                : (mode == .medicationOnly 
                    ? "Achieved on days when you take every single scheduled medication dose." 
                    : "Achieved on days when you reach your full daily hydration goal.")
            
            return StatDetail(
                title: "Perfect Days",
                value: "\(val)",
                description: desc,
                icon: "star.fill",
                color: theme.warningColor
            )
            
        case .consistency:
            let val = Int(calculateHolisticConsistency() * 100)
            let desc = mode == .both
                ? "The balanced average of your adherence to both medications and hydration. It represents your overall alignment with your health rituals."
                : (mode == .medicationOnly
                    ? "The percentage of doses taken versus those missed or skipped. A measure of your faithfulness to your remedies."
                    : "The percentage of active days you've successfully reached your water goal. It reflects your dedication to hydration.")
            
            return StatDetail(
                title: "Consistency",
                value: "\(val)%",
                description: desc,
                icon: theme.symbols.check,
                color: theme.successColor
            )
            
        case .level:
            return StatDetail(
                title: theme.masteryTitle(for: stats.currentLevel),
                value: "Level \(stats.currentLevel)",
                description: "Mastery follows a sustainable path. Unlike other games, progress doesn't become impossible over time. After Level 10, the effort to advance remains consistent, focusing on your lifelong rhythm.\n\nHigher Tiers unlock prestigious Titles. Next milestone at Level \(stats.currentLevel + 5)!",
                icon: "bolt.fill",
                color: theme.primaryColor
            )
        }
    }
    
    private func getDoseLogs(for date: Date) -> [DoseLog] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        
        let descriptor = FetchDescriptor<DoseLog>(
            predicate: #Predicate { log in
                log.scheduledTime >= start && log.scheduledTime < end
            }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
    
    private func getWaterIntake(for date: Date) -> Double {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        
        let descriptor = FetchDescriptor<WaterEntry>(
            predicate: #Predicate { entry in
                entry.date >= start && entry.date < end
            }
        )
        let entries = (try? modelContext.fetch(descriptor)) ?? []
        return entries.reduce(0.0) { $0 + $1.amountLiters }
    }

    // MARK: - Legacy / Manual Update
    func updateDailyStreak(for date: Date) {
        // We now rely on calculate helpers, but we keep the stat update for badges/XP
        let stats = getUserStats()
        let newMedStreak = calculateMedicationStreak()
        stats.currentStreak = newMedStreak
        
        if newMedStreak > stats.longestStreak {
            stats.longestStreak = newMedStreak
        }
        
        try? modelContext.save()
    }

    // MARK: - Achievements
    private func checkStreakAchievements(stats: UserStats) {
        var newAchievements: [String] = []

        // Streak achievements
        if stats.currentStreak == 7 && !stats.achievementBadges.contains("streak_7") {
            newAchievements.append("streak_7")
        }
        if stats.currentStreak == 30 && !stats.achievementBadges.contains("streak_30") {
            newAchievements.append("streak_30")
        }
        if stats.currentStreak == 100 && !stats.achievementBadges.contains("streak_100") {
            newAchievements.append("streak_100")
        }

        // Milestone achievements
        if stats.totalDosesTaken == 100 && !stats.achievementBadges.contains("doses_100") {
            newAchievements.append("doses_100")
        }
        if stats.totalDosesTaken == 500 && !stats.achievementBadges.contains("doses_500") {
            newAchievements.append("doses_500")
        }

        // Level achievements
        if stats.currentLevel >= 10 && !stats.achievementBadges.contains("level_10") {
            newAchievements.append("level_10")
        }
        if stats.currentLevel >= 25 && !stats.achievementBadges.contains("level_25") {
            newAchievements.append("level_25")
        }
        if stats.currentLevel >= 50 && !stats.achievementBadges.contains("level_50") {
            newAchievements.append("level_50")
        }

        stats.achievementBadges.append(contentsOf: newAchievements)
    }

    // MARK: - Analytics
    func getCompletionRateForPeriod(days: Int) -> Double {
        let calendar = Calendar.current
        let endDate = Date()
        let startDate = calendar.date(byAdding: .day, value: -days, to: endDate)!

        let descriptor = FetchDescriptor<DoseLog>(
            predicate: #Predicate { log in
                log.scheduledTime >= startDate && log.scheduledTime <= endDate
            }
        )

        guard let doseLogs = try? modelContext.fetch(descriptor) else { return 0 }

        let taken = doseLogs.filter { $0.isTaken }.count
        let total = doseLogs.count

        guard total > 0 else { return 0 }
        return Double(taken) / Double(total)
    }

    func getBestStreakInformation() -> (current: Int, longest: Int, percentage: Double) {
        let stats = getUserStats()
        let percentage = stats.longestStreak > 0
            ? Double(stats.currentStreak) / Double(stats.longestStreak)
            : 0

        return (stats.currentStreak, stats.longestStreak, percentage)
    }
}

// MARK: - Achievement Definitions
struct Achievement {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let xpReward: Int

    static let all: [Achievement] = [
        Achievement(
            id: "streak_7",
            title: "Week Warrior",
            description: "Maintained a 7-day streak",
            iconName: "flame.fill",
            xpReward: 50
        ),
        Achievement(
            id: "streak_30",
            title: "Monthly Master",
            description: "Maintained a 30-day streak",
            iconName: "star.fill",
            xpReward: 200
        ),
        Achievement(
            id: "streak_100",
            title: "Century Champion",
            description: "Maintained a 100-day streak",
            iconName: "crown.fill",
            xpReward: 1000
        ),
        Achievement(
            id: "doses_100",
            title: "Centurion",
            description: "Completed 100 doses",
            iconName: "checkmark.seal.fill",
            xpReward: 100
        ),
        Achievement(
            id: "doses_500",
            title: "Dedication Master",
            description: "Completed 500 doses",
            iconName: "medal.fill",
            xpReward: 500
        ),
        Achievement(
            id: "level_10",
            title: "Rising Alchemist",
            description: "Reached Level 10",
            iconName: "sparkles",
            xpReward: 0
        ),
        Achievement(
            id: "level_25",
            title: "Potion Master",
            description: "Reached Level 25",
            iconName: "wand.and.stars",
            xpReward: 0
        ),
        Achievement(
            id: "level_50",
            title: "Legendary Healer",
            description: "Reached Level 50",
            iconName: "bolt.heart.fill",
            xpReward: 0
        )
    ]

    static func getAchievement(by id: String) -> Achievement? {
        all.first { $0.id == id }
    }
}
