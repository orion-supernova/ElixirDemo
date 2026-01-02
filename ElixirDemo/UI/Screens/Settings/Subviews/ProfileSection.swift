//
//  ProfileSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct ProfileSection: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    let stats: UserStats
    @Binding var selectedStatForExplanation: StatDetail?
    @Binding var showingMasteryRoadmap: Bool

    @Query private var waterSettings: [WaterSettings]

    var body: some View {
        let mode = waterSettings.first?.activeDashboardMode ?? .both
        let gamification = GamificationManager(modelContext: modelContext)

        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Button(action: {
                    selectedStatForExplanation = gamification.explanationDetail(for: .level, mode: mode, theme: themeManager.currentTheme)
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(themeManager.currentTheme.masteryTitle(for: stats.currentLevel))
                            .font(themeManager.currentTheme.font(for: .headline))
                            .foregroundColor(themeManager.currentTheme.primaryColor)

                        Text("Level \(stats.currentLevel)")
                            .font(themeManager.currentTheme.font(for: .title2))
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                    }
                }
                .buttonStyle(.plain)

                Spacer()

                // Achievement Badges Preview
                HStack(spacing: -8) {
                    let badges = stats.achievementBadges.suffix(3)
                    if badges.isEmpty {
                        Circle()
                            .stroke(themeManager.currentTheme.primaryColor.opacity(0.1), lineWidth: 1)
                            .frame(width: 32, height: 32)
                            .overlay(Image(systemName: "seal").font(.caption2).foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.3)))
                    } else {
                        ForEach(badges, id: \.self) { badge in
                            if let achievement = Achievement.getAchievement(by: badge) {
                                Image(systemName: achievement.iconName)
                                    .font(.system(size: 14))
                                    .padding(8)
                                    .background(Circle().fill(themeManager.currentTheme.surfaceColor))
                                    .overlay(Circle().stroke(themeManager.currentTheme.primaryColor.opacity(0.3), lineWidth: 1))
                            }
                        }
                    }
                }
            }

            // Custom Level Progress Bar
            VStack(spacing: 8) {
                Button(action: {
                    selectedStatForExplanation = gamification.explanationDetail(for: .level, mode: mode, theme: themeManager.currentTheme)
                }) {
                    VStack(spacing: 8) {
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.white.opacity(0.1))

                                Capsule()
                                    .fill(themeManager.currentTheme.primaryGradient)
                                    .frame(width: geo.size.width * stats.progressToNextLevel)
                            }
                        }
                        .frame(height: 10)

                        HStack {
                            Text("\(stats.totalXP) XP")
                            Spacer()
                            Text("Goal: \(stats.xpToNextLevel) XP")
                            Image(systemName: "info.circle").font(.system(size: 8))
                        }
                        .font(themeManager.currentTheme.font(for: .caption))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    }
                }
                .buttonStyle(.plain)

                Button(action: { showingMasteryRoadmap = true }) {
                    HStack {
                        Text("View Mastery Roadmap")
                            .font(themeManager.currentTheme.font(for: .caption))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 8))
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                    .cornerRadius(20)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, Spacing.xs)

            Divider().background(Color.white.opacity(0.1))

            if mode == .both {
                // 2x2 Grid for Both Streaks + Stats
                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.md) {
                        let medStreak = gamification.calculateMedicationStreak()
                        StatBadge(
                            value: "\(medStreak)",
                            label: "Med Streak",
                            icon: "pill.fill",
                            color: themeManager.currentTheme.errorColor,
                            action: {
                                selectedStatForExplanation = gamification.explanationDetail(for: .medicationStreak, mode: mode, theme: themeManager.currentTheme)
                            }
                        )
                        let waterStreak = gamification.calculateWaterGoalStreak()
                        StatBadge(
                            value: "\(waterStreak)",
                            label: "Water Streak",
                            icon: "drop.fill",
                            color: themeManager.currentTheme.primaryColor,
                            action: {
                                selectedStatForExplanation = gamification.explanationDetail(for: .waterStreak, mode: mode, theme: themeManager.currentTheme)
                            }
                        )
                    }
                    HStack(spacing: Spacing.md) {
                        let perfectDays = gamification.calculatePerfectDays()
                        StatBadge(
                            value: "\(perfectDays)",
                            label: "Perfect Days",
                            icon: "star.fill",
                            color: themeManager.currentTheme.warningColor,
                            action: {
                                selectedStatForExplanation = gamification.explanationDetail(for: .perfectDays, mode: mode, theme: themeManager.currentTheme)
                            }
                        )
                        let consistencyValue = Int(gamification.calculateHolisticConsistency() * 100)
                        StatBadge(
                            value: "\(consistencyValue)%",
                            label: "Consistency",
                            icon: themeManager.currentTheme.symbols.check,
                            color: themeManager.currentTheme.successColor,
                            action: {
                                selectedStatForExplanation = gamification.explanationDetail(for: .consistency, mode: mode, theme: themeManager.currentTheme)
                            }
                        )
                    }
                }
            } else {
                // 1x3 Row for Single Focus
                HStack(spacing: Spacing.md) {
                    let streakValue = mode == .medicationOnly ? gamification.calculateMedicationStreak() : gamification.calculateWaterGoalStreak()
                    let streakLabel = mode == .medicationOnly ? "Med" : "Water"

                    StatBadge(
                        value: "\(streakValue)",
                        label: "\(streakLabel) Streak",
                        icon: themeManager.currentTheme.symbols.streak,
                        color: themeManager.currentTheme.errorColor,
                        action: {
                            let type: StatType = mode == .medicationOnly ? .medicationStreak : .waterStreak
                            selectedStatForExplanation = gamification.explanationDetail(for: type, mode: mode, theme: themeManager.currentTheme)
                        }
                    )

                    StatBadge(
                        value: "\(gamification.calculatePerfectDays())",
                        label: "Perfect Days",
                        icon: "star.fill",
                        color: themeManager.currentTheme.warningColor,
                        action: {
                            selectedStatForExplanation = gamification.explanationDetail(for: .perfectDays, mode: mode, theme: themeManager.currentTheme)
                        }
                    )

                    let consistency = Int(gamification.calculateHolisticConsistency() * 100)
                    StatBadge(
                        value: "\(consistency)%",
                        label: "Consistency",
                        icon: themeManager.currentTheme.symbols.check,
                        color: themeManager.currentTheme.successColor,
                        action: {
                            selectedStatForExplanation = gamification.explanationDetail(for: .consistency, mode: mode, theme: themeManager.currentTheme)
                        }
                    )
                }
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                .fill(themeManager.currentTheme.surfaceColor)
                .stroke(themeManager.currentTheme.primaryColor.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    @Previewable @State var selectedStatForExplanation: StatDetail? = nil
    @Previewable @State var showingMasteryRoadmap = false

    let stats = UserStats()

    ProfileSection(
        stats: stats,
        selectedStatForExplanation: $selectedStatForExplanation,
        showingMasteryRoadmap: $showingMasteryRoadmap
    )
    .modelContainer(DataController.preview)
    .environment(ThemeManager.shared)
    .padding()
    .background(Color.black)
}
