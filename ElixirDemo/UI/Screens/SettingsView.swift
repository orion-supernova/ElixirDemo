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
    
    // For hierarchy selection
    @State private var selectedCategoryForDisplay: ThemeCategory = .rpg
    
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
                    
                    // Themes Hierarchy
                    themeHierarchySection
                    
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
            selectedCategoryForDisplay = themeManager.selectedCategory
        }
        .onChange(of: themeManager.selectedCategory) { _, newValue in
            selectedCategoryForDisplay = newValue
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
                    icon: themeManager.currentTheme.symbols.level,
                    color: themeManager.currentTheme.warningColor
                )
                
                StatBadge(
                    value: "\(stats.currentStreak)",
                    label: "Streak",
                    icon: themeManager.currentTheme.symbols.streak,
                    color: themeManager.currentTheme.errorColor
                )
                
                StatBadge(
                    value: "\(stats.totalDosesTaken)",
                    label: "Doses",
                    icon: themeManager.currentTheme.symbols.check,
                    color: themeManager.currentTheme.successColor
                )
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                    .fill(themeManager.currentTheme.surfaceColor)
                    .stroke(themeManager.currentTheme.primaryColor.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Theme Hierarchy Section
    private var themeHierarchySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            
            // Title & Custom Button
            HStack {
                Text("Theme Realm")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Spacer()
                
                Button(action: {
                    showingAddTheme = true
                }) {
                    Text("New Custom")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }
            
            // Step 1: Category Selector (Horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(ThemeCategory.allCases) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategoryForDisplay == category,
                            action: {
                                withAnimation {
                                    selectedCategoryForDisplay = category
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }
            
            // Description of Category
            Text(selectedCategoryForDisplay.description)
                .font(themeManager.currentTheme.font(for: .caption))
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .padding(.vertical, Spacing.xs)
            
            // Step 2: Variants Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                if let themes = themeManager.themesByCategory[selectedCategoryForDisplay] {
                    ForEach(themes, id: \.id) { theme in
                        ThemeVariantCard(
                            theme: theme,
                            isSelected: themeManager.currentTheme.id == theme.id,
                            onSelect: {
                                themeManager.setTheme(id: theme.id)
                            },
                            onDelete: theme.isCustom ? {
                                themeManager.deleteCustomTheme(id: theme.id)
                            } : nil
                        )
                    }
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
                    .fill(themeManager.currentTheme.surfaceColor)
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

// MARK: - Subcomponents

struct CategoryButton: View {
    @Environment(ThemeManager.self) private var themeManager
    let category: ThemeCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(themeManager.currentTheme.font(for: .subheadline))
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? themeManager.currentTheme.textPrimary : themeManager.currentTheme.textSecondary)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? themeManager.currentTheme.primaryColor : themeManager.currentTheme.surfaceColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.currentTheme.primaryColor.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                )
        }
    }
}

struct ThemeVariantCard: View {
    @Environment(ThemeManager.self) private var themeManager
    let theme: ThemeProtocol
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: (() -> Void)?
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: Spacing.sm) {
                // Mini Preview
                HStack(spacing: 0) {
                    Rectangle().fill(theme.primaryColor)
                    Rectangle().fill(theme.secondaryColor)
                    Rectangle().fill(theme.accentColor)
                }
                .frame(height: 60)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? .white : Color.clear, lineWidth: 2)
                )
                
                HStack {
                    Text(theme.displayName)
                        .font(themeManager.currentTheme.font(for: .caption))
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    
                    if let onDelete = onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(themeManager.currentTheme.errorColor)
                        }
                    }
                }
            }
            .padding(Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.currentTheme.surfaceColor)
                    .shadow(color: isSelected ? theme.primaryColor.opacity(0.4) : Color.clear, radius: 10)
            )
        }
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
    let icon: String // Can be SF Symbol or Emoji
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
