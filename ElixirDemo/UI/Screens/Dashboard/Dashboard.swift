//
//  Dashboard.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct Dashboard: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @State private var viewModel: DashboardViewModel?
    @State private var doseLogToDelete: DoseLog?
    @State private var showDeleteConfirmation = false
    @State private var showingWaterTracking = false
    @State private var showingWaterHistory = false
    @State private var showingResetConfirmation = false

    @Query private var waterEntries: [WaterEntry]
    @Query private var waterSettings: [WaterSettings]

    var body: some View {
        ZStack {
            // Background Gradient
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            if let viewModel = viewModel {
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        VStack(spacing: Spacing.xl) {
                            let mode = waterSettings.first?.activeDashboardMode ?? .both

                            // Header Section
                            DashboardHeaderSection(
                                showingWaterTracking: $showingWaterTracking,
                                showingWaterHistory: $showingWaterHistory,
                                showingResetConfirmation: $showingResetConfirmation
                            )

                            if mode == .waterOnly {
                                WaterTrackingContent(showHistory: $showingWaterHistory, showReset: $showingResetConfirmation)
                            } else {
                                if mode == .both {
                                    // Water Stats
                                    WaterStatsSection()
                                }

                                if mode == .both || mode == .medicationOnly {
                                    // Medication Progress
                                    TodayProgressSection(viewModel: viewModel)

                                    // Dose List
                                    DoseListSection(
                                        viewModel: viewModel,
                                        doseLogToDelete: $doseLogToDelete,
                                        showDeleteConfirmation: $showDeleteConfirmation
                                    )

                                    // Stats Summary
                                    DashboardStatsSummary(viewModel: viewModel)

                                    // Weekly Overview
                                    WeeklyOverviewSection()

                                    // Notification Status (Budget Manager)
                                    NotificationStatusSection()
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.md)
                        .padding(.bottom, 100)
                    }
                }
                .sheet(isPresented: Binding(
                    get: { viewModel.showWidgetPrompt },
                    set: { if !$0 { viewModel.dismissWidgetPrompt() } }
                )) {
                    AddWidgetSheet(onDismiss: { viewModel.dismissWidgetPrompt() })
                        .environment(themeManager)
                }
            } else {
                ProgressView()
                    .tint(themeManager.currentTheme.primaryColor)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = DashboardViewModel(modelContext: modelContext)
            } else {
                viewModel?.refresh()
            }
        }
        .alert("Delete Ritual?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { doseLogToDelete = nil }
            Button("Delete", role: .destructive) {
                if let log = doseLogToDelete {
                    viewModel?.deleteMedication(for: log)
                }
                doseLogToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this ritual? This will remove all future reminders.")
        }
    }
}

// MARK: - Preview
#Preview("Dashboard") {
    let schema = Schema([
        Medication.self,
        DoseLog.self,
        UserStats.self,
        WaterSettings.self,
        WaterEntry.self
    ])

    let modelConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true
    )

    let container = try! ModelContainer(
        for: schema,
        configurations: [modelConfiguration]
    )

    return Dashboard()
        .modelContainer(container)
        .environment(ThemeManager.shared)
}
