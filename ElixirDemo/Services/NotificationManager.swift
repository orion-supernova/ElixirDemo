//
//  NotificationManager.swift
//  Elixir: Daily Ritual
//
//  Service to manage local notifications with theming support
//

import Foundation
import UserNotifications
import UIKit

class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    override private init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
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
    func scheduleNotifications(for medication: Medication) {
        // First cancel any existing notifications for this medication
        cancelNotifications(for: medication)
        
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
                // Complex case: Schedule for next 30 days explicitly
                scheduleEveryOtherDayNotifications(for: medication, time: time, index: index, content: content)
                continue // Skip standard trigger creation
                
            case .specificDays:
                // We'd need to know WHICH days. Assuming weekly for simplicity or daily if not specified.
                // If specificDays was fully implemented with a 'selectedDays' set, we'd loop here.
                // Fallback to daily for robustness if specific logic is missing.
                trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                
            case .asNeeded:
                continue // No notifications for as-needed
            }
            
            if let trigger = trigger {
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("Error scheduling notification: \(error)")
                    }
                }
            }
        }
    }
    
    // Helper for Every Other Day
    private func scheduleEveryOtherDayNotifications(for medication: Medication, time: Date, index: Int, content: UNMutableNotificationContent) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date()) // Use current date as reference? 
        // Better: Use medication.startDate anchor
        let anchorDate = calendar.startOfDay(for: medication.startDate)
        
        // Schedule for next 30 occurrences (approx 60 days)
        for i in 0..<30 {
            let dayOffset = i * 2
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: anchorDate) else { continue }
            
            // Don't schedule in the past
            if date < calendar.startOfDay(for: Date()) { continue }
            
            // Combine date with time
            let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
            guard let notificationDate = calendar.date(bySettingHour: timeComponents.hour ?? 0, minute: timeComponents.minute ?? 0, second: 0, of: date) else { continue }
            
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            
            let identifier = "\(medication.id.uuidString)_\(index)_eod_\(i)"
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    // MARK: - Cancellation
    func cancelNotifications(for medication: Medication) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests
                .filter { $0.identifier.hasPrefix(medication.id.uuidString) }
                .map { $0.identifier }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    }
    
    // MARK: - Content Generation
    private func generateContent(for medication: Medication) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.sound = .default
        
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
        // Parse identifier to get medication ID
        // Identifier format: "{uuidString}_{index}"
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
            // Fallback for non-medication notifications (if any)
            completionHandler([.banner, .sound])
        }
    }
}
