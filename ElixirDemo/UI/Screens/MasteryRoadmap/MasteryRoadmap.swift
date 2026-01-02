//
//  MasteryRoadmap.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct MasteryRoadmap: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    let stats: UserStats

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.currentTheme.backgroundGradient.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.xl) {
                        // Header Section
                        VStack(spacing: Spacing.md) {
                            ZStack {
                                Circle()
                                    .fill(themeManager.currentTheme.primaryColor.opacity(0.1))
                                    .frame(width: 100, height: 100)

                                Image(systemName: "tent.fill")
                                    .font(.system(size: 44))
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                            }

                            Text("Alchemical Path")
                                .font(themeManager.currentTheme.font(for: .largeTitle))
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.textPrimary)

                            Text("Your journey from Initiate to Legend")
                                .font(themeManager.currentTheme.font(for: .subheadline))
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                        }
                        .padding(.top, Spacing.lg)

                        // Levels Timeline
                        VStack(alignment: .leading, spacing: 0) {
                            Text("RANK MILESTONES")
                                .font(themeManager.currentTheme.font(for: .caption))
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                                .padding(.horizontal, Spacing.md)
                                .padding(.bottom, Spacing.md)

                            VStack(spacing: 0) {
                                ForEach(themeManager.currentTheme.milestoneDefinitions()) { milestone in
                                    MilestoneRow(milestone: milestone, stats: stats)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.05))
                            )
                        }
                        .padding(.horizontal, Spacing.md)

                        // Achievements Section
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            Text("THE HALL OF GLORY")
                                .font(themeManager.currentTheme.font(for: .caption))
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                                .padding(.horizontal, Spacing.md)

                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: Spacing.md) {
                                ForEach(Achievement.all, id: \.id) { achievement in
                                    AchievementBadge(achievement: achievement, stats: stats)
                                }
                            }
                            .padding(.horizontal, Spacing.md)
                        }
                        .padding(.bottom, Spacing.xl)
                    }
                    .padding(.vertical, Spacing.md)
                }
            }
            .navigationTitle("Mastery Roadmap")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
        }
    }
}
