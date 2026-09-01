//
//  MainTab.swift
//  Elixir: Daily Ritual
//
//  Main container with tab bar navigation
//

import SwiftUI
import SwiftData
import WidgetKit

struct MainTab: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var selectedTab: AppTab
    @State private var notificationState = NotificationState.shared
    @State private var showWidgetPrompt = false
    @State private var hasCheckedWidget = false

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Dashboard", systemImage: "house.fill", value: .dashboard) {
                NavigationStack {
                    Dashboard(selectedTab: $selectedTab)
                }
            }

            Tab("Hydration", systemImage: "drop.fill", value: .hydration) {
                NavigationStack {
                    HydrationTab()
                }
            }

            Tab("Settings", systemImage: "gearshape.fill", value: .settings) {
                NavigationStack {
                    Settings()
                }
            }
        }
        .tabBarMinimizeBehavior(.onScrollDown)
        .tint(themeManager.currentTheme.primaryColor)
        .overlay {
            if notificationState.isAlertVisible,
               let uuid = notificationState.activeMedicationId,
               let content = notificationState.activeNotificationContent {
                NotificationAlert(medicationId: uuid, content: content)
                    .transition(.opacity)
                    .zIndex(100)
            }
        }
        .sheet(isPresented: $showWidgetPrompt) {
            AddWidgetSheet(onDismiss: { showWidgetPrompt = false })
                .environment(themeManager)
        }
        .onAppear {
            guard !hasCheckedWidget else { return }
            hasCheckedWidget = true
            checkWidgetInstalled()
        }
    }

    private func checkWidgetInstalled() {
        Task {
            let configs = try? await WidgetCenter.shared.currentConfigurations()
            if let configs, configs.isEmpty {
                showWidgetPrompt = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var tab: AppTab = .dashboard
    MainTab(selectedTab: $tab)
        .modelContainer(DataController.preview)
        .environment(ThemeManager.shared)
}
