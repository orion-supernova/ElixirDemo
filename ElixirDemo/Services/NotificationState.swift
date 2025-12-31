//
//  NotificationState.swift
//  Elixir: Daily Ritual
//
//  State management for foreground notification alerts
//

import Foundation
import Observation
import UserNotifications

@MainActor
@Observable
class NotificationState {
    static let shared = NotificationState()
    
    var isAlertVisible: Bool = false
    var activeMedicationId: UUID?
    var activeNotificationContent: UNNotificationContent?
    
    private init() {}
    
    func present(for medicationId: UUID, content: UNNotificationContent) {
        self.activeMedicationId = medicationId
        self.activeNotificationContent = content
        self.isAlertVisible = true
    }
    
    func dismiss() {
        self.isAlertVisible = false
        self.activeMedicationId = nil
        self.activeNotificationContent = nil
    }
}
