//
//  AchievementBadge.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct AchievementBadge: View {
    @Environment(ThemeManager.self) private var themeManager

    let achievement: Achievement
    let stats: UserStats

    var body: some View {
        let isUnlocked = stats.achievementBadges.contains(achievement.id)

        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? themeManager.currentTheme.primaryColor.opacity(0.1) : Color.white.opacity(0.05))
                    .frame(width: 60, height: 60)

                Image(systemName: achievement.iconName)
                    .font(.system(size: 24))
                    .foregroundColor(isUnlocked ? themeManager.currentTheme.primaryColor : themeManager.currentTheme.textSecondary.opacity(0.2))
            }

            Text(achievement.title)
                .font(themeManager.currentTheme.font(for: .caption))
                .fontWeight(.medium)
                .foregroundColor(isUnlocked ? themeManager.currentTheme.textPrimary : themeManager.currentTheme.textSecondary.opacity(0.3))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xs)
    }
}
