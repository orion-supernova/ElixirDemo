//
//  WaterNotificationManager.swift
//  Elixir: Daily Ritual
//
//  Handles scheduling and managing recurring water intake reminders.
//

import Foundation
import UserNotifications

final class WaterNotificationManager {
    static let shared = WaterNotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    private let categoryIdentifier = "WATER_REMINDER"
    
    private init() {}
    
    /// Schedules recurring water reminders based on frequency
    func scheduleWaterReminders(frequencyHours: Int) {
        // First cancel any existing water reminders
        cancelAllWaterReminders()
        
        guard frequencyHours > 0 else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Elixir 💧"
        content.body = "Stay hydrated, Ritual Master! A quick glass of water keeps your energy flowing."
        content.sound = .default
        content.categoryIdentifier = categoryIdentifier
        
        // Schedule reminders roughly between 8 AM and 10 PM
        let startHour = 8
        let endHour = 22
        
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
