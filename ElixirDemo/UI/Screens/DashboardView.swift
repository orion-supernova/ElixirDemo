//
//  DashboardView.swift
//  Elixir: Daily Ritual
//
//  Main dashboard with Progress Orb and week calendar
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeManager) private var themeManager
    @State private var viewModel: DashboardViewModel?

    var body: some View {
        ZStack {
            // Background Gradient
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            if let viewModel = viewModel {
                ZStack(alignment: .bottomTrailing) {
                    ScrollView {
                        VStack(spacing: Spacing.xl) {
                            // Header Section
                            headerSection(viewModel: viewModel)

                            // Progress Orb
                            progressOrbSection(viewModel: viewModel)

                            // Stats Summary
                            statsSummary(viewModel: viewModel)

                            // Dose List
                            doseListSection(viewModel: viewModel)
                        }
                        .padding(.horizontal, Spacing.md)
                        .padding(.top, Spacing.md)
                        .padding(.bottom, 100)
                    }
                }
            } else {
                ProgressView()
                    .tint(.potionPurple)
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = DashboardViewModel(modelContext: modelContext)
            }
        }
    }

    // MARK: - Header Section
    @ViewBuilder
    private func headerSection(viewModel: DashboardViewModel) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .ritualFont(.ritualTitle2)
                    .foregroundColor(.white)

                if let stats = viewModel.userStats {
                    HStack(spacing: Spacing.sm) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.mysticGold)

                        Text("Level \(stats.currentLevel) • \(stats.currentTitle)")
                            .ritualFont(.ritualSubheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }

            Spacer()

            // Streak Badge
            if let stats = viewModel.userStats, stats.currentStreak > 0 {
                VStack(spacing: 2) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.phoenixRed, Color.mysticGold],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )

                    Text("\(stats.currentStreak)")
                        .ritualFont(.ritualHeadline)
                        .foregroundColor(.white)

                    Text("Streak")
                        .ritualFont(.ritualCaption)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(Spacing.sm)
                .glassCard(cornerRadius: 12)
            }
        }
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
                    .ritualFont(.ritualHeadline)
                    .foregroundColor(.healingGreen)
            } else if viewModel.totalDoses == 0 {
                Text("No rituals scheduled for today")
                    .ritualFont(.ritualCallout)
                    .foregroundColor(.white.opacity(0.6))
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
                iconName: "checkmark.circle.fill",
                color: .healingGreen
            )

            StatCard(
                title: "Pending",
                value: "\(viewModel.pendingDoses)",
                iconName: "clock.fill",
                color: .mysticGold
            )

            StatCard(
                title: "Missed",
                value: "\(viewModel.missedDoses)",
                iconName: "exclamationmark.triangle.fill",
                color: .phoenixRed
            )
        }
    }

    // MARK: - Dose List Section
    @ViewBuilder
    private func doseListSection(viewModel: DashboardViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Today's Rituals")
                .ritualFont(.ritualTitle3)
                .foregroundColor(.white)

            if viewModel.doseLogs.isEmpty {
                emptyStateView
            } else {
                ForEach(viewModel.doseLogs, id: \.id) { doseLog in
                    if let medication = doseLog.medication {
                        ElixirCard(
                            medication: medication,
                            doseLog: doseLog,
                            onCheckmarkTapped: {
                                viewModel.toggleDoseStatus(for: doseLog)
                            }
                        )
                    }
                }
            }
        }
    }

    // MARK: - Empty State
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(Color.elixirGradient)

            Text("No rituals scheduled")
                .ritualFont(.ritualHeadline)
                .foregroundColor(.white)

            Text("Add your first medication to begin your journey")
                .ritualFont(.ritualCallout)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Use the menu below to add your first ritual")
            }
            .ritualFont(.ritualCallout)
            .foregroundColor(.white.opacity(0.8))
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
        .glassCard()
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

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: iconName)
                .font(.system(size: 20))
                .foregroundStyle(color)

            Text(value)
                .ritualFont(.ritualTitle2)
                .foregroundColor(.white)

            Text(title)
                .ritualFont(.ritualCaption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .glassCard()
    }
}

// MARK: - Preview
#Preview("Dashboard Empty") {
    let schema = Schema([
        Medication.self,
        DoseLog.self,
        UserStats.self
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

#Preview("Dashboard with Data") {
    DashboardView()
        .modelContainer(DataController.preview)
        .environment(ThemeManager.shared)
}
