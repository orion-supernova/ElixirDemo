//
//  ElixirDemoApp.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

@main
struct ElixirDemoApp: App {
    @State private var themeManager = ThemeManager.shared
    @Environment(\.scenePhase) private var scenePhase
    @State private var lastRefreshDate: Date?

    init() {
        // Register background tasks on app launch
        BackgroundTaskManager.shared.registerBackgroundTasks()
    }

    var body: some Scene {
        WindowGroup {
            MainTab()
                .preferredColorScheme(.dark)
                .environment(themeManager)
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
                .onOpenURL { url in
                    // Widget deep link: "elixir://dashboard" opens the app to the Dashboard tab.
                    // MainTab already lands on Dashboard by default, so no additional routing needed.
                    print("📲 Opened via URL: \(url)")
                }
        }
        .modelContainer(DataController.shared.container)
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active && oldPhase == .background {
                // Only run when coming FROM background TO foreground (not within app navigation)
                Task {
                    await handleAppBecameActive()
                }
            } else if newPhase == .background {
                // App going to background - schedule background tasks (only works in background)
                BackgroundTaskManager.shared.scheduleBackgroundTasks()
            }
        }
    }

    private func handleAppBecameActive() async {
        // Throttle: Only refresh if it's been more than 1 hour since last refresh
        if let lastRefresh = lastRefreshDate,
           Date().timeIntervalSince(lastRefresh) < 3600 {
            print("⏭️ Skipping refresh - last refresh was \(Int(Date().timeIntervalSince(lastRefresh)))s ago")
            return
        }

        print("🔄 App became active from background - refreshing notifications")
        lastRefreshDate = Date()

        // Cleanup expired notifications first
        await NotificationBudgetManager.shared.cleanupExpiredNotifications()

        // Check if we need to reschedule
        await NotificationBudgetManager.shared.refresh()

        // Reschedule all medications (this will check if needed)
        await NotificationManager.shared.rescheduleAllMedications()

        // Refresh water reminders if enabled
        await WaterNotificationManager.shared.refreshFromSettings()

        // Sync widget data so it reflects any dose changes that happened in background
        WidgetDataManager.shared.syncToWidget(
            modelContext: DataController.shared.container.mainContext
        )
    }
}
