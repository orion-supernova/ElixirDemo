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
        Task { @MainActor in
            refreshFromSettings()
        }
    }
    
    /// Fetches the latest WaterSettings and reschedules reminders
    func refreshFromSettings() {
        let descriptor = FetchDescriptor<WaterSettings>()
        let context = DataController.shared.container.mainContext
        
        guard let settings = try? context.fetch(descriptor).first,
              settings.remindersEnabled else {
            return
        }
        
        scheduleWaterReminders(
            frequencyHours: settings.frequencyHours,
            startHour: settings.activeStartHour,
            endHour: settings.activeEndHour
        )
    }
    
    /// Schedules recurring water reminders based on frequency and user intervals
    func scheduleWaterReminders(frequencyHours: Int, startHour: Int = 8, endHour: Int = 22) {
        // First cancel any existing water reminders
        cancelAllWaterReminders()
        
        guard frequencyHours > 0 else { return }
        
        let theme = ThemeManager.shared.currentTheme
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Elixir 💧"
        content.body = theme.notificationMessage
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        
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
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling water reminder: \(error.localizedDescription)")
                }
            }
            
            currentHour += frequencyHours
            count += 1
        }
    }
    
    /// Cancels all scheduled water reminders
    func cancelAllWaterReminders() {
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            let waterIdentifiers = requests
                .filter { $0.identifier.contains("water_reminder_") }
                .map { $0.identifier }
            
            self?.notificationCenter.removePendingNotificationRequests(withIdentifiers: waterIdentifiers)
        }
    }
}
