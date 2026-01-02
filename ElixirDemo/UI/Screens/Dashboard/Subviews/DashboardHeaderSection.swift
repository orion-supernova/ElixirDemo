//
//  DashboardHeaderSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct DashboardHeaderSection: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    @Binding var showingWaterTracking: Bool
    @Binding var showingWaterHistory: Bool
    @Binding var showingResetConfirmation: Bool

    @Query private var waterEntries: [WaterEntry]
    @Query private var waterSettings: [WaterSettings]

    var body: some View {
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
                WaterTracking()
            }
        }
        .fullScreenCover(isPresented: $showingWaterHistory) {
            NavigationStack {
                WaterHistory()
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

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private func calculateWaterStreak() -> Int {
        let calendar = Calendar.current
        let goal = waterSettings.first?.dailyGoalLiters ?? 2.0

        let groupedEntries = Dictionary(grouping: waterEntries) { entry in
            calendar.startOfDay(for: entry.date)
        }

        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())

        // Calculate daily totals for each date
        let dailyTotals = groupedEntries.mapValues { entries in
            entries.reduce(0.0) { $0 + $1.amountLiters }
        }

        // Check if streak continues from today or yesterday
        if (dailyTotals[checkDate] ?? 0) < goal {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        while (dailyTotals[checkDate] ?? 0) >= goal {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }

        return streak
    }
}

#Preview {
    @Previewable @State var showingWaterTracking = false
    @Previewable @State var showingWaterHistory = false
    @Previewable @State var showingResetConfirmation = false

    DashboardHeaderSection(
        showingWaterTracking: $showingWaterTracking,
        showingWaterHistory: $showingWaterHistory,
        showingResetConfirmation: $showingResetConfirmation
    )
    .modelContainer(DataController.preview)
    .environment(ThemeManager.shared)
    .padding()
    .background(Color.black)
}
