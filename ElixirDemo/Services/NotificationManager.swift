//
//  NotificationManager.swift
//  Elixir: Daily Ritual
//
//  Service to manage local notifications with theming support
//

import Foundation
import UserNotifications
import UIKit
import SwiftData

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()

    private let medicationCategoryID = "MEDICATION_REMINDER"
    private let rescheduleCategoryID = "RESCHEDULE_REMINDER"

    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        setupNotificationCategories()
    }

    // MARK: - Categories & Actions
    private func setupNotificationCategories() {
        // Medication actions
        let takenAction = UNNotificationAction(
            identifier: "TAKEN_ACTION",
            title: "Taken",
            options: []
        )
        let skipAction = UNNotificationAction(
            identifier: "SKIP_ACTION",
            title: "Skip",
            options: []
        )

        let medicationCategory = UNNotificationCategory(
            identifier: medicationCategoryID,
            actions: [takenAction, skipAction],
            intentIdentifiers: [],
            options: .customDismissAction
        )

        // Reschedule reminder actions
        let rescheduleAction = UNNotificationAction(
            identifier: "RESCHEDULE_ACTION",
            title: "Refresh Reminders",
            options: [.foreground]
        )

        let rescheduleCategory = UNNotificationCategory(
            identifier: rescheduleCategoryID,
            actions: [rescheduleAction],
            intentIdentifiers: [],
            options: []
        )

        UNUserNotificationCenter.current().setNotificationCategories([medicationCategory, rescheduleCategory])
    }
    
    // MARK: - Authorization
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    // MARK: - Scheduling
    func scheduleNotifications(for medication: Medication) async {
        // First cancel any existing notifications for this medication
        await cancelNotifications(for: medication)

        let content = generateContent(for: medication)
        let calendar = Calendar.current

        for (index, time) in medication.scheduledTimes.enumerated() {
            let identifier = "\(medication.id.uuidString)_\(index)"

            // Extract hour and minute components
            let components = calendar.dateComponents([.hour, .minute], from: time)

            var trigger: UNNotificationTrigger?

            switch medication.frequency {
            case .daily, .twiceDaily, .threeTimesDaily, .fourTimesDaily:
                // Daily trigger
                trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            case .weekly:
                // Weekly trigger (needs weekday from startDate)
                var weeklyComponents = components
                let weekday = calendar.component(.weekday, from: medication.startDate)
                weeklyComponents.weekday = weekday
                trigger = UNCalendarNotificationTrigger(dateMatching: weeklyComponents, repeats: true)

            case .everyOtherDay:
                // Schedule only 1 week (7 occurrences = 14 days)
                await scheduleEveryOtherDayNotifications(for: medication, time: time, index: index, content: content)
                continue // Skip standard trigger creation

            case .specificDays:
                // Fallback to daily for robustness
                trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)

            case .asNeeded:
                continue // No notifications for as-needed
            }

            if let trigger = trigger {
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                try? await UNUserNotificationCenter.current().add(request)
            }
        }

        // Check if we need to schedule a reschedule reminder
        await checkAndScheduleRescheduleReminder(for: medication)
        await NotificationBudgetManager.shared.refresh()
    }
    
    // Helper for Every Other Day - Schedules only 1 week (7 occurrences = 14 days)
    private func scheduleEveryOtherDayNotifications(for medication: Medication, time: Date, index: Int, content: UNMutableNotificationContent) async {
        let calendar = Calendar.current
        let anchorDate = calendar.startOfDay(for: medication.startDate)
        let today = calendar.startOfDay(for: Date())

        // Find the next occurrence based on anchor date
        let daysSinceStart = calendar.dateComponents([.day], from: anchorDate, to: today).day ?? 0
        let nextOccurrenceOffset = daysSinceStart % 2 == 0 ? 0 : 1

        // Schedule only 7 occurrences (14 days worth)
        for i in 0..<7 {
            let dayOffset = nextOccurrenceOffset + (i * 2)
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }

            // Combine date with time
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            guard let notificationDate = calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: 0, of: date) else { continue }

            // Skip if in the past
            if notificationDate < Date() { continue }

            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

            let identifier = "\(medication.id.uuidString)_\(index)_eod_\(i)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            try? await UNUserNotificationCenter.current().add(request)
        }
    }
    
    // MARK: - Reschedule Reminder (Failsafe - only if BGTask fails)
    private func checkAndScheduleRescheduleReminder(for medication: Medication) async {
        // Only for every-other-day medications (daily meds schedule 30 days ahead)
        guard medication.frequency == .everyOtherDay else { return }

        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()

        // Check if reschedule reminder already exists
        let existingReschedule = requests.filter {
            $0.identifier.contains(medication.id.uuidString) && $0.identifier.contains("_reschedule_reminder")
        }

        // Schedule user interaction reminder as FAILSAFE if none exists
        // BGTask should handle this automatically, but this ensures coverage
        // Fire 10 days from now (before the 14-day cycle ends)
        if existingReschedule.isEmpty {
            await scheduleRescheduleReminder(for: medication, daysFromNow: 10)
        }
    }

    func scheduleRescheduleReminder(for medication: Medication, daysFromNow: Int) async {
        let content = UNMutableNotificationContent()
        content.title = "⏰ Reminder Refresh Needed"
        content.body = "Tap to refresh reminders for \(medication.name). Open the app to auto-refresh!"
        content.sound = .default
        content.categoryIdentifier = rescheduleCategoryID
        content.userInfo = ["medicationId": medication.id.uuidString, "type": "reschedule"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(daysFromNow * 24 * 60 * 60), repeats: false)
        let identifier = "reschedule_reminder_\(medication.id.uuidString)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try? await UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Reschedule All Medications
    func rescheduleAllMedications() async {
        // This will be called from app foreground or user interaction
        // Get all medications from SwiftData and reschedule
        let context = DataController.shared.container.mainContext
        let descriptor = FetchDescriptor<Medication>()

        guard let medications = try? context.fetch(descriptor) else { return }

        for medication in medications {
            await scheduleNotifications(for: medication)
        }

        await NotificationBudgetManager.shared.cleanupExpiredNotifications()
        await NotificationBudgetManager.shared.refresh()
    }

    // MARK: - Cancellation
    func cancelNotifications(for medication: Medication) async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()

        let identifiers = requests
            .filter { $0.identifier.hasPrefix(medication.id.uuidString) }
            .map { $0.identifier }

        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Content Generation
    private func generateContent(for medication: Medication) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound = .default
        content.categoryIdentifier = medicationCategoryID
        content.userInfo = ["medicationId": medication.id.uuidString, "type": "medication"]

        let theme = ThemeManager.shared.currentTheme
        let category = theme.category

        // Dynamic Title & Body based on Theme
        switch category {
        case .rpg:
            content.title = "Quest Update: \(medication.name)"
            content.body = "It is time to consume your \(medication.dosage) potion. Your vitality depends on it!"

        case .cyberpunk:
            content.title = "System Alert: \(medication.name)"
            content.body = "Biometric levels low. Inject \(medication.dosage) immediately to restore synchronization."

        case .clean:
            content.title = "Time for \(medication.name)"
            content.body = "It's time to take your \(medication.dosage) dose."
        }

        return content
    }
    
    // MARK: - Delegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // Check notification type
        if let type = userInfo["type"] as? String, type == "reschedule" {
            // Show reschedule reminder as banner
            completionHandler([.banner, .sound])
        } else {
            // Parse identifier to get medication ID
            let identifier = notification.request.identifier
            let components = identifier.split(separator: "_")

            if let uuidString = components.first,
               let uuid = UUID(uuidString: String(uuidString)) {

                Task { @MainActor in
                    NotificationState.shared.present(for: uuid, content: notification.request.content)
                }

                // Silence system notification since we present our own
                completionHandler([])
            } else {
                // Fallback for non-medication notifications
                completionHandler([.banner, .sound])
            }
        }
    }

    // Handle user actions on notifications
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo

        Task {
            switch actionIdentifier {
            case "RESCHEDULE_ACTION":
                // User tapped "Refresh Reminders"
                await rescheduleAllMedications()

            case "TAKEN_ACTION":
                // User marked medication as taken
                // Could update DoseLog here if needed
                break

            case "SKIP_ACTION":
                // User skipped medication
                break

            default:
                // Default action (user tapped notification)
                if let type = userInfo["type"] as? String, type == "reschedule" {
                    await rescheduleAllMedications()
                }
            }

            completionHandler()
        }
    }
}

