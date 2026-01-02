//
//  MainTab.swift
//  Elixir: Daily Ritual
//
//  Main container with circular menu navigation
//

import SwiftUI
import SwiftData

struct MainTab: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var selectedTab: AppTab = .dashboard
    @State private var notificationState = NotificationState.shared

    var body: some View {
        NavigationStack {
            ZStack {
                // Current Screen
                CurrentScreen(selectedTab: selectedTab)
                    .transition(.opacity)

                // Circular Menu (Left Side)
                VStack {
                    Spacer()

                    HStack {
                        CircularMenu(selectedTab: $selectedTab)
                            .padding(.leading, Spacing.md)
                            .padding(.bottom, Spacing.xl)
                        Spacer()
                    }
                }
            }

            .animation(.ritualSpring, value: selectedTab)
            .overlay {
                 if notificationState.isAlertVisible,
                    let uuid = notificationState.activeMedicationId,
                    let content = notificationState.activeNotificationContent {
                     NotificationAlert(medicationId: uuid, content: content)
                         .transition(.opacity)
                         .zIndex(100)
                 }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    MainTab()
        .modelContainer(DataController.preview)
        .environment(ThemeManager.shared)
}
