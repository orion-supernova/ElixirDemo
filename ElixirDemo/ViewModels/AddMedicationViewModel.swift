//
//  AddMedicationViewModel.swift
//  Elixir: Daily Ritual
//
//  Business logic for adding new medications
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class AddMedicationViewModel {
    private let modelContext: ModelContext

    // Form Fields
    var medicationName: String = ""
    var dosage: String = ""
    var selectedIcon: String = "pills.fill"
    var selectedColor: String = "A78BFA"
    var selectedFrequency: Frequency = .daily
    var scheduledTimes: [Date] = []
    var startDate: Date = Date()
    var hasEndDate: Bool = false
    var endDate: Date = Date()

    // Validation
    var showError: Bool = false
    var errorMessage: String = ""

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        setupDefaultScheduledTimes()
    }

    // MARK: - Default Setup
    private func setupDefaultScheduledTimes() {
        let calendar = Calendar.current
        let morning = calendar.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
        scheduledTimes = [morning]
    }

    // MARK: - Validation
    func validate() -> Bool {
        if medicationName.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a medication name"
            showError = true
            return false
        }

        if dosage.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a dosage"
            showError = true
            return false
        }

        if scheduledTimes.isEmpty {
            errorMessage = "Please add at least one scheduled time"
            showError = true
            return false
        }

        return true
    }

    // MARK: - Save Medication
    func saveMedication() -> Bool {
        guard validate() else { return false }

        let medication = Medication(
            name: medicationName,
            dosage: dosage,
            iconName: selectedIcon,
            colorHex: selectedColor,
            frequency: selectedFrequency,
            scheduledTimes: scheduledTimes,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil
        )

        modelContext.insert(medication)

        // Create dose logs for today and future dates
        createInitialDoseLogs(for: medication)

        do {
            try modelContext.save()
            return true
        } catch {
            errorMessage = "Failed to save medication: \(error.localizedDescription)"
            showError = true
            return false
        }
    }

    // MARK: - Create Initial Dose Logs
    private func createInitialDoseLogs(for medication: Medication) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // Create dose logs for next 7 days
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }

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

    // MARK: - Time Management
    func addScheduledTime() {
        let calendar = Calendar.current
        let newTime = calendar.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
        scheduledTimes.append(newTime)
    }

    func removeScheduledTime(at index: Int) {
        guard index < scheduledTimes.count else { return }
        scheduledTimes.remove(at: index)
    }

    func updateScheduledTime(at index: Int, to newTime: Date) {
        guard index < scheduledTimes.count else { return }
        scheduledTimes[index] = newTime
    }

    // MARK: - Frequency Management
    func updateFrequency(_ frequency: Frequency) {
        selectedFrequency = frequency

        // Auto-adjust scheduled times based on frequency
        switch frequency {
        case .daily:
            if scheduledTimes.count != 1 {
                scheduledTimes = [scheduledTimes.first ?? defaultMorningTime()]
            }
        case .twiceDaily:
            if scheduledTimes.count != 2 {
                scheduledTimes = [defaultMorningTime(), defaultEveningTime()]
            }
        case .threeTimesDaily:
            if scheduledTimes.count != 3 {
                scheduledTimes = [defaultMorningTime(), defaultAfternoonTime(), defaultEveningTime()]
            }
        case .fourTimesDaily:
            if scheduledTimes.count != 4 {
                scheduledTimes = [
                    defaultTime(hour: 8),
                    defaultTime(hour: 12),
                    defaultTime(hour: 17),
                    defaultTime(hour: 21)
                ]
            }
        case .asNeeded:
            scheduledTimes = []
        default:
            break
        }
    }

    // MARK: - Helper Time Generators
    private func defaultMorningTime() -> Date {
        defaultTime(hour: 8)
    }

    private func defaultAfternoonTime() -> Date {
        defaultTime(hour: 14)
    }

    private func defaultEveningTime() -> Date {
        defaultTime(hour: 20)
    }

    private func defaultTime(hour: Int) -> Date {
        Calendar.current.date(from: DateComponents(hour: hour, minute: 0)) ?? Date()
    }
}

// MARK: - Icon Options
extension AddMedicationViewModel {
    static let iconOptions = [
        "pills.fill",
        "cross.vial.fill",
        "syringe.fill",
        "heart.fill",
        "lungs.fill",
        "brain.head.profile",
        "drop.fill",
        "sun.max.fill",
        "moon.fill",
        "leaf.fill",
        "flame.fill",
        "bolt.fill"
    ]
}

// MARK: - Color Options
extension AddMedicationViewModel {
    static let colorOptions = [
        ("A78BFA", "Purple"),
        ("60A5FA", "Blue"),
        ("34D399", "Green"),
        ("FBBF24", "Gold"),
        ("F87171", "Red"),
        ("C4B5FD", "Lavender"),
        ("6EE7B7", "Mint"),
        ("FB923C", "Orange")
    ]
}
