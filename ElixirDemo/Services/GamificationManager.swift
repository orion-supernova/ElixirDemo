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

    // MARK: - Streak Management
    func updateDailyStreak(for date: Date) {
        let stats = getUserStats()
        let calendar = Calendar.current

        // Get all dose logs for the date
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<DoseLog>(
            predicate: #Predicate { log in
                log.scheduledTime >= startOfDay && log.scheduledTime < endOfDay
            }
        )

        guard let doseLogs = try? modelContext.fetch(descriptor) else { return }

        // Check if all doses for the day are taken
        let allTaken = !doseLogs.isEmpty && doseLogs.allSatisfy { $0.isTaken }
        let anyMissed = doseLogs.contains { $0.isMissed }

        if allTaken {
            stats.incrementStreak()

            // Streak milestone bonuses
            if stats.currentStreak == 7 {
                stats.addXP(Self.xpBonusStreak7)
            } else if stats.currentStreak == 30 {
                stats.addXP(Self.xpBonusStreak30)
            }
        } else if anyMissed {
            stats.resetStreak()
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
