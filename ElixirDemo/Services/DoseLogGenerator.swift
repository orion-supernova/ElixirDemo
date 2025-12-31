//
//  DoseLogGenerator.swift
//  Elixir: Daily Ritual
//
//  Service to generate dose logs on-demand for medications
//

import Foundation
import SwiftData

@MainActor
class DoseLogGenerator {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // Generate missing dose logs for all active medications in a date range
    func ensureLogsExist(for dateRange: ClosedRange<Date>) {
        // Get all medications
        let descriptor = FetchDescriptor<Medication>()
        guard let medications = try? modelContext.fetch(descriptor) else { return }

        for medication in medications {
            generateLogsIfNeeded(for: medication, in: dateRange)
        }

        try? modelContext.save()
    }

    // Generate logs for a specific medication in a date range if they don't exist
    private func generateLogsIfNeeded(for medication: Medication, in dateRange: ClosedRange<Date>) {
        let calendar = Calendar.current

        // Get start and end dates
        let startDate = calendar.startOfDay(for: dateRange.lowerBound)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: dateRange.upperBound)) else { return }

        // Calculate number of days
        let dayCount = calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 0

        for dayOffset in 0..<dayCount {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }

            // Skip if medication hasn't started yet
            if date < calendar.startOfDay(for: medication.startDate) {
                continue
            }

            // Check if medication has ended
            if let medicationEndDate = medication.endDate, date > medicationEndDate {
                continue
            }

            // Skip if not a scheduled day based on frequency
            if !shouldCreateDoseLog(for: medication, on: date) {
                continue
            }

            // Check if logs already exist for this date
            if doseLogsExist(for: medication, on: date) {
                continue
            }

            // Create dose logs for this date
            for scheduledTime in medication.scheduledTimes {
                let components = calendar.dateComponents([.hour, .minute], from: scheduledTime)
                guard let doseTime = calendar.date(bySettingHour: components.hour ?? 0,
                                                   minute: components.minute ?? 0,
                                                   second: 0,
                                                   of: date) else { continue }

                let doseLog = DoseLog(
                    scheduledTime: doseTime,
                    medication: medication,
                    status: .pending
                )
                modelContext.insert(doseLog)
            }
        }
    }

    // Check if dose logs exist for a medication on a specific date
    private func doseLogsExist(for medication: Medication, on date: Date) -> Bool {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let medicationID = medication.id

        let descriptor = FetchDescriptor<DoseLog>(
            predicate: #Predicate { log in
                log.medication?.id == medicationID &&
                log.scheduledTime >= startOfDay &&
                log.scheduledTime < endOfDay
            }
        )

        guard let logs = try? modelContext.fetch(descriptor) else { return false }
        return !logs.isEmpty
    }

    // Helper to determine if a dose log should be created for a specific date based on frequency
    private func shouldCreateDoseLog(for medication: Medication, on date: Date) -> Bool {
        let calendar = Calendar.current

        switch medication.frequency {
        case .daily, .twiceDaily, .threeTimesDaily, .fourTimesDaily:
            return true

        case .everyOtherDay:
            let daysSinceStart = calendar.dateComponents([.day], from: calendar.startOfDay(for: medication.startDate), to: calendar.startOfDay(for: date)).day ?? 0
            return daysSinceStart % 2 == 0

        case .weekly:
            return calendar.component(.weekday, from: date) == calendar.component(.weekday, from: medication.startDate)

        case .specificDays:
            // For now, return true - this would need selectedWeekdays stored on Medication model
            return true

        case .asNeeded:
            return false
        }
    }
}
