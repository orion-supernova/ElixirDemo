//
//  MainTabView.swift
//  Elixir: Daily Ritual
//
//  Main container with circular menu navigation
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var selectedTab: AppTab = .dashboard
    @State private var notificationState = NotificationState.shared

    var body: some View {
        NavigationStack {
            ZStack {
                // Current Screen
                currentScreen
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
                     NotificationAlertView(medicationId: uuid, content: content)
                         .transition(.opacity)
                         .zIndex(100)
                 }
            }
        }
    }

    // MARK: - Current Screen
    @ViewBuilder
    private var currentScreen: some View {
        switch selectedTab {
        case .dashboard:
            DashboardView()

        case .add:
            AddMedicationView()

        case .settings:
            SettingsView()
        }
    }
}

// MARK: - Preview
#Preview {
    MainTabView()
        .modelContainer(DataController.preview)
        .environment(ThemeManager.shared)
}
