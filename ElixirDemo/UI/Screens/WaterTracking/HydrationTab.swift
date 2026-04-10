//
//  HydrationTab.swift
//  Elixir: Daily Ritual
//
//  Tab wrapper for water tracking (no dismiss button, unlike the modal WaterTracking)
//

import SwiftUI
import SwiftData

struct HydrationTab: View {
    @Environment(ThemeManager.self) private var themeManager

    @State private var showingHistory = false
    @State private var showingResetConfirmation = false

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            WaterTrackingContent(
                showHistory: $showingHistory,
                showReset: $showingResetConfirmation
            )
        }
        .navigationTitle("Hydration")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $showingHistory) {
            NavigationStack {
                WaterHistory()
            }
        }
    }
}

#Preview {
    NavigationStack {
        HydrationTab()
            .modelContainer(DataController.preview)
            .environment(ThemeManager.shared)
    }
}
