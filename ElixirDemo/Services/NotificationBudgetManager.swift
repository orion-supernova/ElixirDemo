//
//  NotificationBudgetManager.swift
//  Elixir: Daily Ritual
//
//  Manages the 64 local notification limit across medications and water reminders
//

import Foundation
import Combine
import UserNotifications

@MainActor
class NotificationBudgetManager: ObservableObject {
    static let shared = NotificationBudgetManager()

    private let maxNotifications = 64
    private let reservedForSystem = 2 // Keep 2 slots reserved for reschedule reminders

    @Published var pendingCount: Int = 0
    @Published var medicationCount: Int = 0
    @Published var waterCount: Int = 0
    @Published var rescheduleReminderCount: Int = 0
    @Published var isOverBudget: Bool = false

    var availableSlots: Int {
        maxNotifications - reservedForSystem - pendingCount
    }

    var usedSlots: Int {
        pendingCount
    }

    private init() {}

    /// Refreshes the current notification counts
    func refresh() async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()

        pendingCount = requests.count

        // Categorize notifications
        medicationCount = requests.filter { request in
            let id = request.identifier
            return !id.contains("water") && !id.contains("reschedule")
        }.count

        waterCount = requests.filter {
            $0.identifier.contains("water_reminder") && !$0.identifier.contains("reschedule")
        }.count

        rescheduleReminderCount = requests.filter {
            $0.identifier.contains("reschedule")
        }.count

        isOverBudget = pendingCount > (maxNotifications - reservedForSystem)
    }

    /// Checks if we can schedule additional notifications
    func canSchedule(count: Int) -> Bool {
        return (pendingCount + count) <= (maxNotifications - reservedForSystem)
    }

    /// Allocates budget for a specific type
    func allocateBudget(for type: NotificationType, requestedCount: Int) -> Int {
        let available = availableSlots

        switch type {
        case .medication:
            // Medications get priority, but cap at reasonable limit
            return min(requestedCount, available, 40)

        case .water:
            // Water reminders limited to reasonable count
            return min(requestedCount, available, 10)

        case .rescheduleReminder:
            // Always allow reschedule reminders (use reserved slots)
            return min(requestedCount, 2)
        }
    }

    /// Returns budget info for UI display
    func getBudgetInfo() -> BudgetInfo {
        BudgetInfo(
            total: maxNotifications,
            used: pendingCount,
            available: availableSlots,
            medicationCount: medicationCount,
            waterCount: waterCount,
            rescheduleReminderCount: rescheduleReminderCount,
            isOverBudget: isOverBudget
        )
    }

    /// Clean up expired notifications (past notifications)
    func cleanupExpiredNotifications() async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()

        let now = Date()
        var expiredIdentifiers: [String] = []

        for request in requests {
            if let trigger = request.trigger as? UNCalendarNotificationTrigger,
               let nextTriggerDate = trigger.nextTriggerDate(),
               nextTriggerDate < now {
                expiredIdentifiers.append(request.identifier)
            }
        }

        if !expiredIdentifiers.isEmpty {
            center.removePendingNotificationRequests(withIdentifiers: expiredIdentifiers)
            await refresh()
        }
    }
}

enum NotificationType {
    case medication
    case water
    case rescheduleReminder
}

struct BudgetInfo {
    let total: Int
    let used: Int
    let available: Int
    let medicationCount: Int
    let waterCount: Int
    let rescheduleReminderCount: Int
    let isOverBudget: Bool

    var usagePercentage: Double {
        Double(used) / Double(total)
    }
}
