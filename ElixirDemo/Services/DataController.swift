//
//  DataController.swift
//  Elixir: Daily Ritual
//
//  Centralized SwiftData container management
//

import Foundation
import SwiftData

@MainActor
final class DataController {
    static let shared = DataController()

    let container: ModelContainer

    private init() {
        let schema = Schema([
            Medication.self,
            DoseLog.self,
            UserStats.self,
            WaterSettings.self,
            WaterEntry.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        do {
            container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    // MARK: - Preview Container
    static var preview: ModelContainer {
        let schema = Schema([
            Medication.self,
            DoseLog.self,
            UserStats.self,
            WaterSettings.self,
            WaterEntry.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            // Seed preview data
            let context = container.mainContext

            // Create sample medications
            let vitaminD = Medication(
                name: "Vitamin D",
                dosage: "1000 IU",
                iconName: "sun.max.fill",
                colorHex: "FBBF24",
                frequency: .daily,
                scheduledTimes: [Calendar.current.date(from: DateComponents(hour: 8, minute: 0))!]
            )

            let omega3 = Medication(
                name: "Omega-3",
                dosage: "500mg",
                iconName: "drop.fill",
                colorHex: "60A5FA",
                frequency: .twiceDaily,
                scheduledTimes: [
                    Calendar.current.date(from: DateComponents(hour: 9, minute: 0))!,
                    Calendar.current.date(from: DateComponents(hour: 21, minute: 0))!
                ]
            )

            let aspirin = Medication(
                name: "Aspirin",
                dosage: "81mg",
                iconName: "heart.fill",
                colorHex: "F87171",
                frequency: .daily,
                scheduledTimes: [Calendar.current.date(from: DateComponents(hour: 20, minute: 0))!]
            )

            context.insert(vitaminD)
            context.insert(omega3)
            context.insert(aspirin)

            // Create sample dose logs for today
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())

            let log1 = DoseLog(
                scheduledTime: calendar.date(byAdding: .hour, value: 8, to: today)!,
                medication: vitaminD,
                status: .taken
            )
            log1.takenTime = calendar.date(byAdding: .hour, value: 8, to: today)!

            let log2 = DoseLog(
                scheduledTime: calendar.date(byAdding: .hour, value: 9, to: today)!,
                medication: omega3,
                status: .pending
            )

            let log3 = DoseLog(
                scheduledTime: calendar.date(byAdding: .hour, value: 20, to: today)!,
                medication: aspirin,
                status: .pending
            )

            let log4 = DoseLog(
                scheduledTime: calendar.date(byAdding: .hour, value: 21, to: today)!,
                medication: omega3,
                status: .pending
            )

            context.insert(log1)
            context.insert(log2)
            context.insert(log3)
            context.insert(log4)

            // Create user stats
            let stats = UserStats()
            stats.totalXP = 450
            stats.currentLevel = 5
            stats.currentStreak = 7
            stats.longestStreak = 14
            stats.totalDosesTaken = 45
            context.insert(stats)

            try? context.save()

            return container
        } catch {
            fatalError("Failed to create preview container: \(error)")
        }
    }
}
