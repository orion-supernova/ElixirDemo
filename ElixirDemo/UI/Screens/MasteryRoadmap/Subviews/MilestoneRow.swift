//
//  MilestoneRow.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct MilestoneRow: View {
    @Environment(ThemeManager.self) private var themeManager

    let milestone: UserStats.TitleMilestone
    let stats: UserStats

    var body: some View {
        let isReached = stats.currentLevel >= milestone.levelRange.lowerBound
        let isCurrent = milestone.levelRange.contains(stats.currentLevel)

        HStack(spacing: Spacing.md) {
            // Indicator
            VStack {
                Circle()
                    .fill(isReached ? themeManager.currentTheme.primaryColor : Color.white.opacity(0.2))
                    .frame(width: 12, height: 12)
                    .overlay(
                        Circle()
                            .stroke(themeManager.currentTheme.primaryColor.opacity(0.3), lineWidth: isCurrent ? 4 : 0)
                    )
            }
            .frame(width: 24)

            // Content
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(milestone.title)
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(isReached ? themeManager.currentTheme.textPrimary : themeManager.currentTheme.textSecondary.opacity(0.5))

                    if isCurrent {
                        Text("CURRENT")
                            .font(.system(size: 8, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(themeManager.currentTheme.primaryColor)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                }

                Text(milestone.levelRange.lowerBound == milestone.levelRange.upperBound
                     ? "Level \(milestone.levelRange.lowerBound)"
                     : "Levels \(milestone.levelRange.lowerBound)–\(milestone.levelRange.upperBound)")
                    .font(themeManager.currentTheme.font(for: .caption))
                    .foregroundColor(isReached ? themeManager.currentTheme.primaryColor : themeManager.currentTheme.textSecondary.opacity(0.3))
            }

            Spacer()

            Image(systemName: milestone.icon)
                .font(.system(size: 16))
                .foregroundColor(isReached ? themeManager.currentTheme.primaryColor.opacity(0.8) : themeManager.currentTheme.textSecondary.opacity(0.2))
        }
        .padding(.horizontal, Spacing.md)
        .padding(.vertical, Spacing.md)
        .background(
            isCurrent ? themeManager.currentTheme.primaryColor.opacity(0.1) : Color.clear
        )
    }
}
