//
//  GamificationManager.swift
//  Elixir: Daily Ritual
//
//  Handles XP, leveling, streaks, and achievement logic
//

import Foundation
import SwiftData

@MainActor
@Observable
final class GamificationManager {
    private let modelContext: ModelContext

    // Constants
    static let xpPerDose = 10
    static let xpPerWaterIntake = 5
    static let xpBonusWaterGoal = 30
    static let xpBonusStreak7 = 50
    static let xpBonusStreak30 = 200

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

    // MARK: - Dose Recording
    func recordDoseTaken(for doseLog: DoseLog) {
        let stats = getUserStats()

        doseLog.markAsTaken()
        stats.recordDoseTaken()

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

    // MARK: - Water Recording
    func recordWaterRitual(amount: Double, goal: Double, totalTodayBefore: Double) {
        let stats = getUserStats()
        
        // Base XP for logging
        stats.addXP(Self.xpPerWaterIntake)
        
        // Check if this entry pushes user over the daily goal
        let totalAfter = totalTodayBefore + amount
        if totalTodayBefore < goal && totalAfter >= goal {
            stats.addXP(Self.xpBonusWaterGoal)
            
            // Potential for a "Goal Met" achievement here in future
        }
        
        try? modelContext.save()
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
        let waterGoal = (try? modelContext.fetch(descriptor).first)?.dailyGoalLiters ?? 2.0
        
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
            if getWaterIntake(for: checkDate) >= waterGoal {
                waterSuccessDays += 1
            }
            checkDate = calendar.date(byAdding: .day, value: 1, to: checkDate)!
        }
        
        let waterConsistency = Double(waterSuccessDays) / Double(activeDays)
        
        // 3. Holistic Average
        // If we are in "Both" mode, average them. Otherwise use the relevant one.
        let mode = (try? modelContext.fetch(descriptor).first)?.activeDashboardMode ?? .both
        
        switch mode {
        case .medicationOnly: return medConsistency
        case .waterOnly: return waterConsistency
        case .both: return (medConsistency + waterConsistency) / 2.0
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
