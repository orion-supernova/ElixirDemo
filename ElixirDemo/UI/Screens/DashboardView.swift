//
//  DashboardView.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct DashboardView: View {
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
                            headerSection(viewModel: viewModel)

                            if mode == .waterOnly {
                                WaterTrackingContent(showHistory: $showingWaterHistory, showReset: $showingResetConfirmation)
                            } else {
                                if mode == .both {
                                    // Water Stats
                                    waterStatsSection
                                }

                                if mode == .both || mode == .medicationOnly {
                                    // Medication Progress
                                    todayProgressSection(viewModel: viewModel)

                                    // Stats Summary
                                    statsSummary(viewModel: viewModel)

                                    // Weekly Overview
                                    weeklyOverviewSection()

                                    // Dose List
                                    doseListSection(viewModel: viewModel)
                                }
                            }
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.md)
                        .padding(.bottom, 100)
                    }
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
    
    // MARK: - Header Section
    @ViewBuilder
    private func headerSection(viewModel: DashboardViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(themeManager.currentTheme.font(for: .title2))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                Text("Track your daily rituals")
                    .font(themeManager.currentTheme.font(for: .subheadline))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
            }
            
            Spacer()
            
            if (waterSettings.first?.activeDashboardMode ?? .both) != .waterOnly {
                // Streak Badge (Water Streak)
                Button(action: {
                    showingWaterTracking = true
                }) {
                    VStack(spacing: 2) {
                        Image(systemName: "water.waves")
                            .font(.system(size: 24))
                            .foregroundColor(themeManager.currentTheme.primaryColor)

                        Text("\(calculateWaterStreak())")
                            .font(themeManager.currentTheme.font(for: .headline))
                            .foregroundColor(themeManager.currentTheme.textPrimary)

                        Text("Streak")
                            .font(themeManager.currentTheme.font(for: .caption2))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.currentTheme.surfaceColor)
                            .stroke(themeManager.currentTheme.primaryColor.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
        .fullScreenCover(isPresented: $showingWaterTracking) {
            NavigationStack {
                WaterTrackingView()
            }
        }
        .fullScreenCover(isPresented: $showingWaterHistory) {
            NavigationStack {
                WaterHistoryView()
            }
        }
        .alert("Reset Today's Water?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) { 
                let calendar = Calendar.current
                let todayEntries = waterEntries.filter { calendar.isDateInToday($0.date) }
                for entry in todayEntries {
                    modelContext.delete(entry)
                }
                try? modelContext.save()
            }
        } message: {
            Text("This will clear all water entries for today. Are you sure?")
        }
    }
    
    private var waterStatsSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Hydration State")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Spacer()
                
                let total = waterEntries.filter { Calendar.current.isDateInToday($0.date) }.reduce(0.0) { $0 + $1.amountLiters }
                let goal = waterSettings.first?.dailyGoalLiters ?? 2.0
                Text("\(Int(total * 1000))ml / \(Int(goal * 1000))ml")
                    .font(themeManager.currentTheme.font(for: .caption))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
            }
            .padding(.horizontal, Spacing.xs)

            HStack(spacing: Spacing.md) {
                let totalToday = waterEntries.filter { Calendar.current.isDateInToday($0.date) }.reduce(0.0) { $0 + $1.amountLiters }
                let goal = waterSettings.first?.dailyGoalLiters ?? 2.0
                let progress = min(totalToday / goal, 1.0)
                
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color.blue.opacity(0.7), Color.cyan.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progress)
                    }
                }
                .frame(height: 12)
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
    
    private func calculateWaterStreak() -> Int {
        let calendar = Calendar.current
        let groupedEntries = Dictionary(grouping: waterEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // If no intake today, check from yesterday for the streak
        if groupedEntries[checkDate] == nil {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        while groupedEntries[checkDate] != nil {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        return streak
    }


    // MARK: - Today's Progress Section
    @ViewBuilder
    private func todayProgressSection(viewModel: DashboardViewModel) -> some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: themeManager.currentTheme.symbols.check)
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text("Today's Progress")
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                }

                Spacer()

                Text("\(viewModel.takenDoses) / \(viewModel.totalDoses)")
                    .font(themeManager.currentTheme.font(for: .caption))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
            }

            // Today's Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.currentTheme.primaryColor,
                                    themeManager.currentTheme.successColor
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.todayProgress, height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.primaryColor.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Progress Orb Section
    @ViewBuilder
    private func progressOrbSection(viewModel: DashboardViewModel) -> some View {
        VStack(spacing: Spacing.md) {
            ProgressOrb(
                progress: viewModel.todayProgress,
                totalDoses: viewModel.totalDoses,
                takenDoses: viewModel.takenDoses
            )
            
            if viewModel.isAllComplete {
                Text("Perfect! All rituals complete 🎉")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.successColor)
            } else if viewModel.totalDoses == 0 {
                Text("No rituals scheduled for today")
                    .font(themeManager.currentTheme.font(for: .callout))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
            }
        }
        .padding(.vertical, Spacing.md)
    }
    
    // MARK: - Stats Summary
    @ViewBuilder
    private func statsSummary(viewModel: DashboardViewModel) -> some View {
        HStack(spacing: Spacing.md) {
            StatCard(
                title: "Completed",
                value: "\(viewModel.takenDoses)",
                iconName: themeManager.currentTheme.symbols.check,
                color: themeManager.currentTheme.successColor
            )
            
            StatCard(
                title: "Pending",
                value: "\(viewModel.pendingDoses)",
                iconName: themeManager.currentTheme.symbols.uncheck,
                color: themeManager.currentTheme.accentColor
            )
            
            StatCard(
                title: "Missed",
                value: "\(viewModel.missedDoses)",
                iconName: "exclamationmark.triangle.fill",
                color: themeManager.currentTheme.errorColor
            )
        }
    }
    
    // MARK: - Weekly Overview Section
    @ViewBuilder
    private func weeklyOverviewSection() -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("This Week")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                Spacer()

                NavigationLink(destination: HistoryView()) {
                    HStack(spacing: Spacing.xs) {
                        Text("Calendar")
                            .font(themeManager.currentTheme.font(for: .caption))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }

            HStack(spacing: Spacing.sm) {
                ForEach(0..<7) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -6 + dayOffset, to: Date()) ?? Date()
                    let isToday = Calendar.current.isDateInToday(date)
                    let dayName = dayName(for: date)

                    VStack(spacing: Spacing.xs) {
                        Text(dayName)
                            .font(themeManager.currentTheme.font(for: .caption2))
                            .foregroundColor(isToday ? themeManager.currentTheme.primaryColor : themeManager.currentTheme.textSecondary)

                        Circle()
                            .fill(isToday ?
                                  themeManager.currentTheme.primaryColor :
                                    Color.white.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(themeManager.currentTheme.font(for: .caption))
                                    .foregroundColor(isToday ? .white : themeManager.currentTheme.textPrimary)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // Helper to get day name
    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    // MARK: - Dose List Section
    @ViewBuilder
    private func doseListSection(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Today's Rituals")
                    .font(themeManager.currentTheme.font(for: .title3))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                Spacer()

                NavigationLink(destination: MedicationsListView()) {
                    HStack(spacing: Spacing.xs) {
                        Text("View All")
                            .font(themeManager.currentTheme.font(for: .caption))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            
            if viewModel.doseLogs.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.doseLogs, id: \.id) { doseLog in
                    if let medication = doseLog.medication {
                        SwipeActionView(cornerRadius: 20, onDelete: {
                            doseLogToDelete = doseLog
                            showDeleteConfirmation = true
                        }) {
                            ElixirCard(
                                medication: medication,
                                doseLog: doseLog,
                                onCheckmarkTapped: {
                                    viewModel.toggleDoseStatus(for: doseLog)
                                },
                                onMarkMissed: {
                                    viewModel.markDoseAsMissed(doseLog)
                                },
                                onMarkSkipped: {
                                    viewModel.markDoseAsSkipped(doseLog)
                                }
                            )
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Empty State
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: themeManager.currentTheme.symbols.currency)
                .font(.system(size: 64))
                .foregroundColor(themeManager.currentTheme.primaryColor)
            
            Text("No rituals scheduled")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            Text("Add your first medication to begin your journey")
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .multilineTextAlignment(.center)

            HStack {
                Image(systemName: themeManager.currentTheme.symbols.streak)
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                Text("Tap the floating button to add your first ritual")
            }
            .font(themeManager.currentTheme.font(for: .callout))
            .foregroundColor(themeManager.currentTheme.textSecondary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
    
    // MARK: - Helpers
    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
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
    
    return DashboardView()
        .modelContainer(container)
        .environment(ThemeManager.shared)
}
