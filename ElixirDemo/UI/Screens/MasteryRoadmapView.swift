import SwiftUI
import SwiftData

struct MasteryRoadmapView: View {
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
                                ForEach(UserStats.allMilestones) { milestone in
                                    milestoneRow(milestone)
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
                                    achievementBadge(achievement)
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
    
    @ViewBuilder
    private func milestoneRow(_ milestone: UserStats.TitleMilestone) -> some View {
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
    
    @ViewBuilder
    private func achievementBadge(_ achievement: Achievement) -> some View {
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
