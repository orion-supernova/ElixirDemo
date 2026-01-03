//
//  WaterHistory.swift
//  Elixir: Daily Ritual
//
//  A historical view of water intake daily totals with graphs and timestamps.
//

import SwiftUI
import SwiftData
import Charts

struct WaterHistory: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \WaterEntry.date, order: .reverse) private var entries: [WaterEntry]
    @Query private var waterSettings: [WaterSettings]

    @State private var expandedDates: Set<Date> = []

    private var dailyTotals: [(date: Date, total: Double, entries: [WaterEntry])] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }

        return grouped.map { (date: $0.key, total: $0.value.reduce(0) { $0 + $1.amountLiters }, entries: $0.value.sorted { $0.date > $1.date }) }
            .sorted { $0.date > $1.date }
    }

    private var chartData: [(date: Date, total: Double)] {
        let calendar = Calendar.current
        let last7Days = (0...6).compactMap { calendar.date(byAdding: .day, value: -$0, to: calendar.startOfDay(for: Date())) }

        return last7Days.map { date in
            let total = entries.filter { calendar.isDate($0.date, inSameDayAs: date) }.reduce(0) { $0 + $1.amountLiters }
            return (date: date, total: total)
        }.sorted { $0.date < $1.date }
    }

    private var dailyGoal: Double {
        waterSettings.first?.dailyGoalLiters ?? 2.0
    }

    var body: some View {
        ZStack {
            // Background
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if entries.isEmpty {
                    emptyHistoryView
                } else {
                    ScrollView {
                        VStack(spacing: Spacing.xl) {
                            // Weekly Chart
                            WeeklyIntakeChart(chartData: chartData, dailyGoal: dailyGoal)
                                .padding(.top, Spacing.md)

                            // Detailed Logs
                            VStack(alignment: .leading, spacing: Spacing.md) {
                                Text("Daily Logs")
                                    .font(themeManager.currentTheme.font(for: .headline))
                                    .foregroundColor(themeManager.currentTheme.textPrimary)
                                    .padding(.horizontal, Spacing.md)

                                LazyVStack(spacing: Spacing.md) {
                                    ForEach(dailyTotals, id: \.date) { daily in
                                        historyRow(for: daily)
                                    }
                                }
                                .padding(.horizontal, Spacing.md)
                            }
                        }
                        .padding(.bottom, Spacing.xl)
                    }
                }
            }
        }
        .navigationTitle("Water Ritual History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
        }
    }

    private func historyRow(for daily: (date: Date, total: Double, entries: [WaterEntry])) -> some View {
        let isExpanded = expandedDates.contains(daily.date)
        let progress = min(daily.total / dailyGoal, 1.0)
        let isGoalMet = daily.total >= dailyGoal

        return VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring()) {
                    if isExpanded {
                        expandedDates.remove(daily.date)
                    } else {
                        expandedDates.insert(daily.date)
                    }
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(daily.date, style: .date)
                            .font(themeManager.currentTheme.font(for: .headline))
                            .foregroundColor(themeManager.currentTheme.textPrimary)

                        Text("\(Int(daily.total * 1000))ml / \(Int(dailyGoal * 1000))ml")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }

                    Spacer()

                    if isGoalMet {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 16))
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }

            // Progress Bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.currentTheme.primaryColor,
                                    isGoalMet ? themeManager.currentTheme.successColor : themeManager.currentTheme.primaryColor.opacity(0.6)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress)
                }
            }
            .frame(height: 8)

            if isExpanded {
                VStack(spacing: 8) {
                    Divider().background(Color.white.opacity(0.1))

                    ForEach(groupEntriesByMinute(daily.entries), id: \.minute) { grouped in
                        HStack {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 12))
                                .foregroundColor(themeManager.currentTheme.primaryColor)

                            Text("\(Int(grouped.totalAmount * 1000))ml")
                                .font(themeManager.currentTheme.font(for: .callout))
                                .foregroundColor(themeManager.currentTheme.textPrimary)

                            if grouped.count > 1 {
                                Text("x\(grouped.count)")
                                    .font(themeManager.currentTheme.font(for: .caption))
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(themeManager.currentTheme.primaryColor.opacity(0.2))
                                    .cornerRadius(8)
                            }

                            Spacer()

                            Text(grouped.minute, style: .time)
                                .font(themeManager.currentTheme.font(for: .caption))
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }

    private var emptyHistoryView: some View {
        VStack(spacing: 20) {
            Image(systemName: "drop.fill")
                .font(.system(size: 60))
                .foregroundColor(themeManager.currentTheme.primaryColor.opacity(0.3))

            Text("No hydration history yet")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textSecondary)

            Text("Begin your hydration ritual to see your progress here.")
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxHeight: .infinity)
    }

    private func groupEntriesByMinute(_ entries: [WaterEntry]) -> [(minute: Date, count: Int, totalAmount: Double)] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { entry in
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: entry.date)
            return calendar.date(from: components)!
        }

        return grouped.map { (minute: $0.key, count: $0.value.count, totalAmount: $0.value.reduce(0) { $0 + $1.amountLiters }) }
            .sorted { $0.minute > $1.minute }
    }
}

#Preview {
    NavigationStack {
        WaterHistory()
            .environment(ThemeManager.shared)
            .modelContainer(DataController.preview)
    }
}
