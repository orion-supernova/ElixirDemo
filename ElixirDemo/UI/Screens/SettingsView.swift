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
    
    @Query private var waterSettings: [WaterSettings]
    @Query private var waterEntries: [WaterEntry]
    
    // Explanation State
    @State private var selectedStatForExplanation: StatDetail?
    
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
                    
                    // Hydration
                    hydrationSection
                    
                    // Dashboard Display
                    dashboardDisplaySection
                    
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
        let mode = waterSettings.first?.activeDashboardMode ?? .both
        let gamification = GamificationManager(modelContext: modelContext)
        
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(stats.currentTitle)
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    
                    Text("Level \(stats.currentLevel)")
                        .font(themeManager.currentTheme.font(for: .title2))
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                }
                
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
                    selectedStatForExplanation = StatDetail(
                        title: stats.currentTitle,
                        value: "Level \(stats.currentLevel)",
                        description: "Earn XP by completing your daily rituals. Leveling up unlocks prestigious alchemical titles and marks your mastery over your health.\n\nNext title at Level \(stats.currentLevel + 5)!",
                        icon: "bolt.fill",
                        color: themeManager.currentTheme.primaryColor
                    )
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
                                selectedStatForExplanation = StatDetail(
                                    title: "Medication Streak",
                                    value: "\(medStreak)",
                                    description: "Your consistency with remedies. Increases every day you take 100% of your scheduled doses.",
                                    icon: "pill.fill",
                                    color: themeManager.currentTheme.errorColor
                                )
                            }
                        )
                        let waterStreak = gamification.calculateWaterGoalStreak()
                        StatBadge(
                            value: "\(waterStreak)",
                            label: "Water Streak",
                            icon: "drop.fill",
                            color: themeManager.currentTheme.primaryColor,
                            action: {
                                selectedStatForExplanation = StatDetail(
                                    title: "Water Streak",
                                    value: "\(waterStreak)",
                                    description: "Your hydration consistency. Increases every day you reach your full daily water goal.",
                                    icon: "drop.fill",
                                    color: themeManager.currentTheme.primaryColor
                                )
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
                                selectedStatForExplanation = StatDetail(
                                    title: "Perfect Days",
                                    value: "\(perfectDays)",
                                    description: "The ultimate milestone. Achieved on days when you complete every single medication dose AND hit your water goal.",
                                    icon: "star.fill",
                                    color: themeManager.currentTheme.warningColor
                                )
                            }
                        )
                        let consistencyValue = Int(gamification.calculateHolisticConsistency() * 100)
                        StatBadge(
                            value: "\(consistencyValue)%",
                            label: "Consistency",
                            icon: themeManager.currentTheme.symbols.check,
                            color: themeManager.currentTheme.successColor,
                            action: {
                                selectedStatForExplanation = StatDetail(
                                    title: "Holistic Consistency",
                                    value: "\(consistencyValue)%",
                                    description: "The balanced average of your adherence to both medications and hydration. It represents your overall alignment with your health rituals.",
                                    icon: themeManager.currentTheme.symbols.check,
                                    color: themeManager.currentTheme.successColor
                                )
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
                            let desc = mode == .medicationOnly 
                                ? "Your medication consistency. Increases every day you successfully take 100% of your scheduled doses."
                                : "Your hydration consistency. Increases every day you meet 100% of your water goal."
                            selectedStatForExplanation = StatDetail(
                                title: "\(streakLabel) Streak",
                                value: "\(streakValue)",
                                description: desc,
                                icon: themeManager.currentTheme.symbols.streak,
                                color: themeManager.currentTheme.errorColor
                            )
                        }
                    )
                    
                    StatBadge(
                        value: "\(gamification.calculatePerfectDays())",
                        label: "Perfect Days",
                        icon: "star.fill",
                        color: themeManager.currentTheme.warningColor,
                        action: {
                            let desc = mode == .medicationOnly
                                ? "Achieved on days when you take every single scheduled medication dose."
                                : "Achieved on days when you reach your full hydration goal."
                            selectedStatForExplanation = StatDetail(
                                title: "Perfect Days",
                                value: "\(gamification.calculatePerfectDays())",
                                description: desc,
                                icon: "star.fill",
                                color: themeManager.currentTheme.warningColor
                            )
                        }
                    )
                    
                    let consistency = Int(gamification.calculateHolisticConsistency() * 100)
                    StatBadge(
                        value: "\(consistency)%",
                        label: "Consistency",
                        icon: themeManager.currentTheme.symbols.check,
                        color: themeManager.currentTheme.successColor,
                        action: {
                            let desc = mode == .medicationOnly
                                ? "The percentage of doses taken versus those missed or skipped. A measure of your faithfulness to your remedies."
                                : "The percentage of active days you've successfully reached your water goal. It reflects your dedication to hydration."
                            selectedStatForExplanation = StatDetail(
                                title: "Consistency",
                                value: "\(consistency)%",
                                description: desc,
                                icon: themeManager.currentTheme.symbols.check,
                                color: themeManager.currentTheme.successColor
                            )
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
        .sheet(item: $selectedStatForExplanation) { detail in
            StatExplanationSheet(detail: detail)
        }
    }
    
    // MARK: - Hydration Section
    private var hydrationSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Hydration")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            VStack(spacing: Spacing.md) {
                let settings = waterSettings.first ?? WaterSettings()
                
                Toggle(isOn: Binding(
                    get: { settings.remindersEnabled },
                    set: { newValue in
                        settings.remindersEnabled = newValue
                        if newValue {
                            WaterNotificationManager.shared.scheduleWaterReminders(
                                frequencyHours: settings.frequencyHours,
                                startHour: settings.activeStartHour,
                                endHour: settings.activeEndHour
                            )
                        } else {
                            WaterNotificationManager.shared.cancelAllWaterReminders()
                        }
                        try? modelContext.save()
                    }
                )) {
                    HStack {
                        Image(systemName: "water.waves")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        Text("Water Reminders")
                            .font(themeManager.currentTheme.font(for: .body))
                    }
                }
                .tint(themeManager.currentTheme.primaryColor)
                
                if settings.remindersEnabled {
                    Divider().background(Color.white.opacity(0.1))
                    
                    VStack(alignment: .leading, spacing: Spacing.sm) {
                        Text("Frequency")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                        
                        Picker("Frequency", selection: Binding(
                            get: { settings.frequencyHours },
                            set: { newValue in
                                settings.frequencyHours = newValue
                                WaterNotificationManager.shared.scheduleWaterReminders(
                                    frequencyHours: newValue,
                                    startHour: settings.activeStartHour,
                                    endHour: settings.activeEndHour
                                )
                                try? modelContext.save()
                            }
                        )) {
                            Text("1h").tag(1)
                            Text("2h").tag(2)
                            Text("4h").tag(4)
                            Text("6h").tag(6)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    VStack(alignment: .leading, spacing: Spacing.md) {
                        Text("Active Window")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                        
                        HStack(spacing: 0) {
                            // Start Picker
                            VStack(alignment: .leading, spacing: 4) {
                                Text("START")
                                    .font(themeManager.currentTheme.font(for: .caption2))
                                    .fontWeight(.bold)
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                
                                Picker("Start", selection: Binding(
                                    get: { settings.activeStartHour },
                                    set: { newValue in
                                        settings.startHour = newValue
                                        WaterNotificationManager.shared.scheduleWaterReminders(
                                            frequencyHours: settings.frequencyHours,
                                            startHour: newValue,
                                            endHour: settings.activeEndHour
                                        )
                                        try? modelContext.save()
                                    }
                                )) {
                                    ForEach(0...23, id: \.self) { hour in
                                        Text("\(hour):00").tag(hour)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12, corners: [.topLeft, .bottomLeft])
                            
                            // Divider icon
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
                                .padding(.horizontal, -8)
                                .zIndex(1)
                            
                            // End Picker
                            VStack(alignment: .leading, spacing: 4) {
                                Text("END")
                                    .font(themeManager.currentTheme.font(for: .caption2))
                                    .fontWeight(.bold)
                                    .foregroundColor(themeManager.currentTheme.secondaryColor)
                                
                                Picker("End", selection: Binding(
                                    get: { settings.activeEndHour },
                                    set: { newValue in
                                        settings.endHour = newValue
                                        WaterNotificationManager.shared.scheduleWaterReminders(
                                            frequencyHours: settings.frequencyHours,
                                            startHour: settings.activeStartHour,
                                            endHour: newValue
                                        )
                                        try? modelContext.save()
                                    }
                                )) {
                                    ForEach(0...23, id: \.self) { hour in
                                        Text("\(hour):00").tag(hour)
                                    }
                                }
                                .pickerStyle(.menu)
                                .labelsHidden()
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12, corners: [.topRight, .bottomRight])
                        }
                        .tint(themeManager.currentTheme.textPrimary)
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
        .onAppear {
            if waterSettings.isEmpty {
                let initial = WaterSettings()
                modelContext.insert(initial)
                try? modelContext.save()
            }
        }
    }
    
    // MARK: - Dashboard Display Section
    private var dashboardDisplaySection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Dashboard Rituals")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            VStack(spacing: 0) {
                let settings = waterSettings.first ?? WaterSettings()
                
                ForEach(DashboardMode.allCases) { mode in
                    Button {
                        withAnimation {
                            settings.dashboardMode = mode
                            try? modelContext.save()
                        }
                    } label: {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(settings.activeDashboardMode == mode ? themeManager.currentTheme.primaryColor.opacity(0.2) : Color.white.opacity(0.05))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: mode.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(settings.activeDashboardMode == mode ? themeManager.currentTheme.primaryColor : themeManager.currentTheme.textSecondary)
                            }
                            
                            Text(mode.rawValue)
                                .font(themeManager.currentTheme.font(for: .body))
                                .foregroundColor(settings.activeDashboardMode == mode ? themeManager.currentTheme.textPrimary : themeManager.currentTheme.textSecondary)
                            
                            Spacer()
                            
                            if settings.activeDashboardMode == mode {
                                Image(systemName: themeManager.currentTheme.symbols.check)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                            }
                        }
                        .padding(Spacing.md)
                        .background(settings.activeDashboardMode == mode ? Color.white.opacity(0.03) : Color.clear)
                    }
                    
                    if mode != DashboardMode.allCases.last {
                        Divider().background(Color.white.opacity(0.1))
                            .padding(.leading, 64)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius))
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
                SettingsRow(icon: "info.circle.fill", title: "Version", value: appVersion)
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "hammer.fill", title: "Build", value: appBuild)
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
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }
    
    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
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

    private func calculateWaterStreak() -> Int {
        // Redundant - removed as we use GamificationManager
        return 0
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
    let icon: String
    let color: Color
    var action: (() -> Void)? = nil
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        Button(action: { action?() }) {
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
                
                if action != nil {
                    Image(systemName: "info.circle")
                        .font(.system(size: 10))
                        .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat Detail Model
struct StatDetail: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let description: String
    let icon: String
    let color: Color
}

// MARK: - Stat Explanation Sheet
struct StatExplanationSheet: View {
    let detail: StatDetail
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient.ignoresSafeArea()
            
            VStack(spacing: Spacing.lg) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 4)
                    .padding(.top, Spacing.sm)
                
                // Icon & Header
                VStack(spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(detail.color.opacity(0.1))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: detail.icon)
                            .font(.system(size: 40))
                            .foregroundColor(detail.color)
                    }
                    
                    Text(detail.title)
                        .font(themeManager.currentTheme.font(for: .title2))
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                    
                    Text(detail.value)
                        .font(themeManager.currentTheme.font(for: .largeTitle))
                        .fontWeight(.bold)
                        .foregroundColor(detail.color)
                }
                
                Text(detail.description)
                    .font(themeManager.currentTheme.font(for: .body))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.xl)
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Text("Understood")
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryGradient)
                        .cornerRadius(12)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
            }
        }
        .presentationDetents([.height(450)])
        .presentationDragIndicator(.hidden)
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
