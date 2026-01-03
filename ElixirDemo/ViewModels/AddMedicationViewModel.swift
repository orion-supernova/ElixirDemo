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
    var dosageAmount: String = ""
    var dosageUnit: String = "mg"
    var selectedIcon: String = "pills.fill"
    var selectedColor: String = "A78BFA"
    var selectedFrequency: Frequency = .daily
    var scheduledTimes: [Date] = []
    var startDate: Date = Date()
    var hasEndDate: Bool = false
    var endDate: Date = Date()

    // Frequency-specific fields
    var startDayOffset: Int = 0 // 0 = today, 1 = tomorrow (for Every Other Day)
    var selectedWeekday: Int = Calendar.current.component(.weekday, from: Date()) // 1=Sunday, 7=Saturday (for Weekly)
    var selectedWeekdays: Set<Int> = [] // For Specific Days (1=Sunday, 7=Saturday)

    // Dosage units
    static let dosageUnits = ["mg", "g", "mcg", "ml", "L", "tbsp", "tsp", "drops", "pill(s)", "IU", "capsule(s)", "spray(s)", "puff(s)"]

    // Validation
    var showError: Bool = false
    var errorMessage: String = ""

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        setupDefaultScheduledTimes()
    }

    // MARK: - Default Setup
    private func setupDefaultScheduledTimes() {
        scheduledTimes = [Date()]
    }

    // MARK: - Validation
    func validate() -> Bool {
        if medicationName.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a medication name"
            showError = true
            return false
        }

        if dosageAmount.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter a dosage amount"
            showError = true
            return false
        }

        // As Needed frequency doesn't require scheduled times
        if selectedFrequency != .asNeeded && scheduledTimes.isEmpty {
            errorMessage = "Please add at least one scheduled time"
            showError = true
            return false
        }

        // Specific Days frequency requires at least one day selected
        if selectedFrequency == .specificDays && selectedWeekdays.isEmpty {
            errorMessage = "Please select at least one day of the week"
            showError = true
            return false
        }

        return true
    }

    // MARK: - Save Medication
    func saveMedication() async -> Bool {
        guard validate() else { return false }

        // Combine dosage amount and unit
        let combinedDosage = "\(dosageAmount) \(dosageUnit)"

        let medication = Medication(
            name: medicationName,
            dosage: combinedDosage,
            iconName: selectedIcon,
            colorHex: selectedColor,
            frequency: selectedFrequency,
            scheduledTimes: scheduledTimes,
            startDate: startDate,
            endDate: hasEndDate ? endDate : nil
        )

        modelContext.insert(medication)

        // Logs will be generated on-demand by Dashboard/Calendar

        // Schedule Notifications
        await NotificationManager.shared.scheduleNotifications(for: medication)

        do {
            try modelContext.save()
            return true
        } catch {
            errorMessage = "Failed to save medication: \(error.localizedDescription)"
            showError = true
            return false
        }
    }



    // MARK: - Time Management
    func addScheduledTime() {
        scheduledTimes.append(Date())
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
        case .everyOtherDay:
            if scheduledTimes.count != 1 {
                scheduledTimes = [scheduledTimes.first ?? defaultMorningTime()]
            }
            // Reset to today by default
            startDayOffset = 0
        case .weekly:
            if scheduledTimes.count != 1 {
                scheduledTimes = [scheduledTimes.first ?? defaultMorningTime()]
            }
            // Set to current weekday by default
            selectedWeekday = Calendar.current.component(.weekday, from: Date())
        case .specificDays:
            if scheduledTimes.count != 1 {
                scheduledTimes = [scheduledTimes.first ?? defaultMorningTime()]
            }
            // Initialize with current weekday if empty
            if selectedWeekdays.isEmpty {
                selectedWeekdays = [Calendar.current.component(.weekday, from: Date())]
            }
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
