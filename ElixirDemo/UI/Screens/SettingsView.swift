//
//  SettingsView.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext
    
    @State private var showingAddTheme = false
    @State private var userStats: UserStats?
    
    var body: some View {
        ZStack {
            // Background
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Spacing.xl) {
                    // Header
                    headerSection
                    
                    // Profile Stats
                    if let stats = userStats {
                        profileSection(stats: stats)
                    }
                    
                    // Themes
                    themesSection
                    
                    // About
                    aboutSection
                }
                .padding(Spacing.md)
                .padding(.bottom, 100)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingAddTheme) { AddCustomThemeView() }
        .onAppear {
            loadUserStats()
        }
    }
    
    // MARK: - Header
    private var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            ZStack {
                Circle()
                    .fill(themeManager.currentTheme.primaryGradient)
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
            }
            
            Text("Ritual Master")
                .font(themeManager.currentTheme.font(for: .title2))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            Text("Manage your settings and preferences")
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
    }
    
    // MARK: - Profile Section
    @ViewBuilder
    private func profileSection(stats: UserStats) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Your Progress")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            HStack(spacing: Spacing.md) {
                StatBadge(
                    value: "\(stats.currentLevel)",
                    label: "Level",
                    icon: "star.fill",
                    color: themeManager.currentTheme.warningColor
                )
                
                StatBadge(
                    value: "\(stats.currentStreak)",
                    label: "Streak",
                    icon: "flame.fill",
                    color: themeManager.currentTheme.errorColor
                )
                
                StatBadge(
                    value: "\(stats.totalDosesTaken)",
                    label: "Doses",
                    icon: "checkmark.circle.fill",
                    color: themeManager.currentTheme.successColor
                )
            }
            
            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("Title")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    Spacer()
                    Text(stats.currentTitle)
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
                
                HStack {
                    Text("Total XP")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    Spacer()
                    Text("\(stats.totalXP)")
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                }
                
                HStack {
                    Text("Completion Rate")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    Spacer()
                    Text("\(Int(stats.completionRate * 100))%")
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(themeManager.currentTheme.successColor)
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                    .fill(.ultraThinMaterial)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Themes Section
    private var themesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Themes")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Spacer()
                
                Button(action: {
                    showingAddTheme = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Custom")
                    }
                    .font(themeManager.currentTheme.font(for: .subheadline))
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            
            VStack(spacing: Spacing.sm) {
                ForEach(themeManager.availableThemes, id: \.id) { theme in
                    ThemeRow(
                        theme: theme,
                        isSelected: themeManager.currentTheme.id == theme.id,
                        onSelect: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                themeManager.setTheme(id: theme.id)
                            }
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("About")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            VStack(spacing: 0) {
                SettingsRow(icon: "info.circle.fill", title: "Version", value: "1.0.0")
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "doc.text.fill", title: "Privacy Policy", value: "")
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "envelope.fill", title: "Support", value: "")
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                    .fill(.ultraThinMaterial)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Helpers
    private func loadUserStats() {
        let descriptor = FetchDescriptor<UserStats>()
        if let stats = try? modelContext.fetch(descriptor).first {
            userStats = stats
        } else {
            let newStats = UserStats()
            modelContext.insert(newStats)
            try? modelContext.save()
            userStats = newStats
        }
    }
}

// MARK: - Theme Row
struct ThemeRow: View {
    let theme: ThemeProtocol
    let isSelected: Bool
    let onSelect: () -> Void
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Spacing.md) {
                // Theme Preview
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.backgroundColor)
                        .frame(width: 20, height: 40)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.surfaceColor)
                        .frame(width: 20, height: 40)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(theme.primaryColor)
                        .frame(width: 20, height: 40)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                
                // Theme Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.displayName)
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                    
                    if theme.isCustom {
                        Text("Custom")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }
                }
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.primaryColor)
                        .font(.system(size: 24))
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white.opacity(0.1) : Color.white.opacity(0.05))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Row
struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .frame(width: 24)
            
            Text(title)
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(themeManager.currentTheme.font(for: .subheadline))
                .foregroundColor(themeManager.currentTheme.textSecondary)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
        }
        .padding(.vertical, Spacing.sm)
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(themeManager.currentTheme.font(for: .title2))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            Text(label)
                .font(themeManager.currentTheme.font(for: .caption))
                .foregroundColor(themeManager.currentTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                .fill(.ultraThinMaterial)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        SettingsView()
            .modelContainer(DataController.preview)
            .environment(ThemeManager.shared)
    }
}
