//
//  WaterNotificationManager.swift
//  Elixir: Daily Ritual
//
//  Handles scheduling and managing recurring water intake reminders.
//

import SwiftUI
import UserNotifications
import SwiftData

extension Notification.Name {
    static let themeChanged = Notification.Name("com.elixir.themeChanged")
}

final class WaterNotificationManager {
    static let shared = WaterNotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let categoryIdentifier = "WATER_REMINDER"
    
    private init() {
        setupObservers()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: .themeChanged,
            object: nil
        )
    }
    
    @objc private func handleThemeChange() {
        // Refresh reminders to use new theme message
        Task {
            await refreshFromSettings()
        }
    }

    /// Fetches the latest WaterSettings and reschedules reminders
    func refreshFromSettings() async {
        let descriptor = FetchDescriptor<WaterSettings>()
        let context = DataController.shared.container.mainContext

        guard let settings = try? context.fetch(descriptor).first else {
            print("⚠️ WaterSettings not found - skipping water reminder refresh")
            return
        }

        guard settings.remindersEnabled else {
            print("💧 Water reminders disabled - skipping refresh")
            return
        }

        print("💧 Refreshing water reminders: \(settings.frequencyHours)h, \(settings.activeStartHour):00-\(settings.activeEndHour):00")
        await scheduleWaterReminders(
            frequencyHours: settings.frequencyHours,
            startHour: settings.activeStartHour,
            endHour: settings.activeEndHour
        )
    }
    
    /// Schedules recurring water reminders based on frequency and user intervals
    func scheduleWaterReminders(frequencyHours: Int, startHour: Int = 8, endHour: Int = 22) async {
        // First cancel any existing water reminders
        await cancelAllWaterReminders()

        guard frequencyHours >= 1 else {
            print("⚠️ Water frequency too low (\(frequencyHours)h) - minimum is 1h")
            return
        }

        let theme = ThemeManager.shared.currentTheme

        let content = UNMutableNotificationContent()
        content.title = "Time for Elixir 💧"
        content.body = theme.notificationMessage
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        content.userInfo = ["type": "water"]

        var currentHour = startHour
        var count = 0

        while currentHour <= endHour {
            var dateComponents = DateComponents()
            dateComponents.hour = currentHour
            dateComponents.minute = 0

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(
                identifier: "water_reminder_\(count)",
                content: content,
                trigger: trigger
            )

            try? await notificationCenter.add(request)

            currentHour += frequencyHours
            count += 1
        }

        print("💧 Scheduled \(count) water reminders (\(startHour):00-\(endHour):00, every \(frequencyHours)h)")

        // Schedule reschedule reminder every 2 days
        await scheduleWaterRescheduleReminder()
        await NotificationBudgetManager.shared.refresh()
    }

    /// Schedules a reminder to refresh water notifications
    /// This is a FAILSAFE - BGTask should handle this automatically
    private func scheduleWaterRescheduleReminder() async {
        let content = UNMutableNotificationContent()
        content.title = "💧 Water Reminder Check"
        content.body = "Open the app to auto-refresh your water reminders with the latest theme!"
        content.sound = .default
        content.categoryIdentifier = "WATER_RESCHEDULE"
        content.userInfo = ["type": "water_reschedule"]

        // Fire in 4 days (gives BGTask time to run first)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 4 * 24 * 60 * 60, repeats: false)
        let identifier = "water_reschedule_reminder"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        try? await notificationCenter.add(request)
    }
    
    /// Cancels all scheduled water reminders
    func cancelAllWaterReminders() async {
        let requests = await notificationCenter.pendingNotificationRequests()
        let waterIdentifiers = requests
            .filter { $0.identifier.contains("water_reminder_") || $0.identifier.contains("water_reschedule") }
            .map { $0.identifier }

        if !waterIdentifiers.isEmpty {
            print("🗑️ Cancelling \(waterIdentifiers.count) water reminders")
        }
        notificationCenter.removePendingNotificationRequests(withIdentifiers: waterIdentifiers)
    }
}
