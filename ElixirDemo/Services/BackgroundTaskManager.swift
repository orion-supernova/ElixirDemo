//
//  BackgroundTaskManager.swift
//  Elixir: Daily Ritual
//
//  Handles BGTaskScheduler for automatic notification rescheduling
//

import Foundation
import BackgroundTasks
import UIKit

class BackgroundTaskManager {
    static let shared = BackgroundTaskManager()

    // Task identifiers - MUST match Info.plist entries
    private let appRefreshTaskID = "com.elixir.refreshNotifications"
    private let processingTaskID = "com.elixir.deepCleanNotifications"

    private init() {}

    // MARK: - Registration
    func registerBackgroundTasks() {
        // Register app refresh task (runs ~daily, 30 seconds)
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: appRefreshTaskID,
            using: nil
        ) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }

        // Register processing task (runs when idle/charging, several minutes)
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: processingTaskID,
            using: nil
        ) { task in
            self.handleProcessingTask(task: task as! BGProcessingTask)
        }
    }

    // MARK: - Scheduling
    func scheduleBackgroundTasks() {
        scheduleAppRefresh()
        scheduleProcessingTask()
    }

    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: appRefreshTaskID)
        // Run at least once per day
        let scheduledDate = Date(timeIntervalSinceNow: 24 * 60 * 60) // 24 hours
        request.earliestBeginDate = scheduledDate

        do {
            try BGTaskScheduler.shared.submit(request)
            UserDefaults.standard.set(scheduledDate, forKey: "bgAppRefreshScheduledDate")
            print("✅ BGAppRefreshTask scheduled for \(scheduledDate)")
        } catch {
            print("❌ Could not schedule app refresh: \(error)")
        }
    }

    private func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: processingTaskID)
        // Run weekly for deep cleanup
        let scheduledDate = Date(timeIntervalSinceNow: 7 * 24 * 60 * 60) // 7 days
        request.earliestBeginDate = scheduledDate
        request.requiresNetworkConnectivity = false
        request.requiresExternalPower = false // Don't require charging

        do {
            try BGTaskScheduler.shared.submit(request)
            UserDefaults.standard.set(scheduledDate, forKey: "bgProcessingScheduledDate")
            print("✅ BGProcessingTask scheduled for \(scheduledDate)")
        } catch {
            print("❌ Could not schedule processing task: \(error)")
        }
    }

    // MARK: - Handlers
    private func handleAppRefresh(task: BGAppRefreshTask) {
        print("🔄 BGAppRefreshTask started")

        // Schedule next refresh
        scheduleAppRefresh()

        let taskCompleted = Task {
            do {
                // 1. Cleanup expired notifications
                await NotificationBudgetManager.shared.cleanupExpiredNotifications()

                // 2. Check if rescheduling is needed
                await NotificationBudgetManager.shared.refresh()
                let budgetInfo = await NotificationBudgetManager.shared.getBudgetInfo()

                // 3. Intelligently decide if rescheduling is needed
                if await shouldReschedule(budgetInfo: budgetInfo) {
                    print("🔄 Rescheduling needed - executing...")
                    await NotificationManager.shared.rescheduleAllMedications()
                    await WaterNotificationManager.shared.refreshFromSettings()

                    // Cancel any pending user interaction reminders since we just rescheduled
                    await cancelRescheduleReminders()
                } else {
                    print("✅ No rescheduling needed - all notifications healthy")
                }

                task.setTaskCompleted(success: true)
            } catch {
                print("❌ BGAppRefreshTask error: \(error)")
                task.setTaskCompleted(success: false)
            }
        }

        // Handle expiration
        task.expirationHandler = {
            print("⏰ BGAppRefreshTask expired")
            taskCompleted.cancel()
            task.setTaskCompleted(success: false)
        }
    }

    private func handleProcessingTask(task: BGProcessingTask) {
        print("🔄 BGProcessingTask started (deep clean)")

        // Schedule next processing task
        scheduleProcessingTask()

        let taskCompleted = Task {
            do {
                // Deep cleanup and full reschedule
                await NotificationBudgetManager.shared.cleanupExpiredNotifications()
                await NotificationManager.shared.rescheduleAllMedications()
                await WaterNotificationManager.shared.refreshFromSettings()
                await cancelRescheduleReminders()

                print("✅ BGProcessingTask completed - full reschedule done")
                task.setTaskCompleted(success: true)
            } catch {
                print("❌ BGProcessingTask error: \(error)")
                task.setTaskCompleted(success: false)
            }
        }

        task.expirationHandler = {
            print("⏰ BGProcessingTask expired")
            taskCompleted.cancel()
            task.setTaskCompleted(success: false)
        }
    }

    // MARK: - Intelligence
    private func shouldReschedule(budgetInfo: BudgetInfo) async -> Bool {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()

        // Check if any EOD medications have low notification count
        let eodNotifications = requests.filter { $0.identifier.contains("_eod_") }
        let medicationIDs = Set(eodNotifications.compactMap { request -> String? in
            let components = request.identifier.split(separator: "_")
            return components.first.map(String.init)
        })

        for medicationID in medicationIDs {
            let count = eodNotifications.filter { $0.identifier.hasPrefix(medicationID) }.count
            if count < 3 {
                print("🔄 Medication \(medicationID) has only \(count) EOD notifications - rescheduling needed")
                return true
            }
        }

        // Check if water reschedule reminder exists
        let waterReschedule = requests.contains { $0.identifier.contains("water_reschedule") }
        if !waterReschedule {
            print("🔄 Water reschedule reminder missing - refreshing needed")
            return true
        }

        return false
    }

    private func cancelRescheduleReminders() async {
        let center = UNUserNotificationCenter.current()
        let requests = await center.pendingNotificationRequests()

        let rescheduleIdentifiers = requests
            .filter { $0.identifier.contains("reschedule_reminder") }
            .map { $0.identifier }

        center.removePendingNotificationRequests(withIdentifiers: rescheduleIdentifiers)
        print("🗑️ Cancelled \(rescheduleIdentifiers.count) reschedule reminders")
    }

    // MARK: - Testing (Simulator Only)
    #if DEBUG
    func simulateBackgroundRefresh() {
        print("🧪 Simulating BGAppRefreshTask...")
        Task {
            await NotificationBudgetManager.shared.cleanupExpiredNotifications()
            await NotificationManager.shared.rescheduleAllMedications()
            await WaterNotificationManager.shared.refreshFromSettings()
            print("✅ Simulation complete")
        }
    }
    #endif
}
