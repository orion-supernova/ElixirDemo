//
//  TodayOverviewSection.swift
//  Elixir: Daily Ritual
//
//  Combined progress ring + stat summary for a single "Today" card
//

import SwiftUI
import SwiftData

struct TodayOverviewSection: View {
    @Environment(ThemeManager.self) private var themeManager
    let viewModel: DashboardViewModel

    var body: some View {
        HStack(spacing: Spacing.lg) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: viewModel.todayProgress)
                    .stroke(
                        LinearGradient(
                            colors: [
                                themeManager.currentTheme.primaryColor,
                                themeManager.currentTheme.successColor
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.6), value: viewModel.todayProgress)

                VStack(spacing: 0) {
                    Text("\(Int(viewModel.todayProgress * 100))")
                        .font(themeManager.currentTheme.font(for: .title2))
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                    Text("%")
                        .font(themeManager.currentTheme.font(for: .caption2))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                }
            }

            // Stats
            VStack(alignment: .leading, spacing: Spacing.sm) {
                Text("Today's Progress")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                HStack(spacing: Spacing.md) {
                    StatPill(
                        value: viewModel.takenDoses,
                        label: "Done",
                        color: themeManager.currentTheme.successColor
                    )
                    StatPill(
                        value: viewModel.pendingDoses,
                        label: "Pending",
                        color: themeManager.currentTheme.accentColor
                    )
                    StatPill(
                        value: viewModel.missedDoses,
                        label: "Missed",
                        color: themeManager.currentTheme.errorColor
                    )
                }
            }

            Spacer()
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
}

// MARK: - Stat Pill
private struct StatPill: View {
    @Environment(ThemeManager.self) private var themeManager
    let value: Int
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text("\(value)")
                .font(themeManager.currentTheme.font(for: .title3))
                .foregroundColor(color)
            Text(label)
                .font(themeManager.currentTheme.font(for: .caption2))
                .foregroundColor(themeManager.currentTheme.textSecondary)
        }
    }
}

#Preview {
    @Previewable @State var viewModel = DashboardViewModel(modelContext: DataController.preview.mainContext)

    TodayOverviewSection(viewModel: viewModel)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
