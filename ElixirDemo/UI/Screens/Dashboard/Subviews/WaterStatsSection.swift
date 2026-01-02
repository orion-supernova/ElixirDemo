//
//  WaterStatsSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct WaterStatsSection: View {
    @Environment(ThemeManager.self) private var themeManager

    @Query private var waterEntries: [WaterEntry]
    @Query private var waterSettings: [WaterSettings]

    var body: some View {
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
}

#Preview {
    WaterStatsSection()
        .modelContainer(DataController.preview)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
