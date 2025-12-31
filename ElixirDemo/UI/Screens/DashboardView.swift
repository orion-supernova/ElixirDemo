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
    @State private var viewModel: DashboardViewModel?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background Gradient
                Color.backgroundGradient
                    .ignoresSafeArea()

                if let viewModel = viewModel {
                    ZStack(alignment: .bottomTrailing) {
                        ScrollView {
                            VStack(spacing: Spacing.xl) {
                                // Header Section
                                headerSection(viewModel: viewModel)

                                // Week Calendar Strip
                                weekCalendarStrip(viewModel: viewModel)

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

                        // Floating Action Button
                        if viewModel.totalDoses > 0 {
                            NavigationLink(destination: AddMedicationView()) {
                                HStack(spacing: Spacing.sm) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 24))
                                    Text("Add Ritual")
                                        .ritualFont(.ritualHeadline)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, Spacing.lg)
                                .padding(.vertical, Spacing.md)
                                .background(Color.elixirGradient)
                                .cornerRadius(25)
                                .shadow(color: Color.potionPurple.opacity(0.6), radius: 20, x: 0, y: 10)
                            }
                            .padding(Spacing.lg)
                        }
                    }
                } else {
                    ProgressView()
                        .tint(.potionPurple)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Elixir: Daily Ritual")
                        .ritualFont(.ritualTitle3)
                        .foregroundStyle(Color.elixirGradient)
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        // Navigate to profile/stats
                    }) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.elixirGradient)
                    }
                }
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

    // MARK: - Week Calendar Strip
    @ViewBuilder
    private func weekCalendarStrip(viewModel: DashboardViewModel) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.sm) {
                    ForEach(viewModel.getWeekDays(for: viewModel.selectedDate), id: \.self) { date in
                        WeekDayCell(
                            date: date,
                            isSelected: viewModel.isDateSelected(date),
                            isToday: viewModel.isDateToday(date),
                            completionStatus: viewModel.getCompletionStatus(for: date),
                            onTap: {
                                withAnimation(.ritualSpring) {
                                    viewModel.selectDate(date)
                                }
                            }
                        )
                        .id(date)
                    }
                }
                .padding(.horizontal, Spacing.sm)
            }
            .onAppear {
                proxy.scrollTo(viewModel.selectedDate, anchor: .center)
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

            NavigationLink(destination: AddMedicationView()) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Ritual")
                }
                .ritualFont(.ritualHeadline)
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.lg)
                .padding(.vertical, Spacing.md)
                .background(Color.elixirGradient)
                .cornerRadius(12)
            }
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

// MARK: - Week Day Cell
struct WeekDayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let completionStatus: CompletionStatus
    let onTap: () -> Void

    private var dayLetter: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: Spacing.xs) {
                Text(dayLetter)
                    .ritualFont(.ritualCaption)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.6))

                ZStack {
                    if isSelected {
                        Circle()
                            .fill(Color.elixirGradient)
                            .frame(width: 44, height: 44)
                    } else {
                        Circle()
                            .fill(Color.clear)
                            .frame(width: 44, height: 44)
                    }

                    if completionStatus != .none {
                        Circle()
                            .strokeBorder(completionStatus.color, lineWidth: 2)
                            .frame(width: 44, height: 44)
                    }

                    Text(dayNumber)
                        .ritualFont(.ritualHeadline)
                        .foregroundColor(isSelected ? .white : .primary)
                }

                if isToday && !isSelected {
                    Circle()
                        .fill(Color.potionPurple)
                        .frame(width: 4, height: 4)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(width: 60)
            .padding(.vertical, Spacing.sm)
        }
        .buttonStyle(PlainButtonStyle())
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

    return NavigationStack {
        DashboardView()
            .modelContainer(container)
    }
}

#Preview("Dashboard with Data") {
    NavigationStack {
        DashboardView()
            .modelContainer(DataController.preview)
    }
}
