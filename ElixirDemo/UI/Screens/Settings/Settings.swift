//
//  Settings.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct Settings: View {
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
    @State private var showingMasteryRoadmap = false
    
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
        .sheet(isPresented: $showingAddTheme) { AddCustomTheme() }
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
    
    // MARK: - Sections
    @ViewBuilder
    private func profileSection(stats: UserStats) -> some View {
        ProfileSection(
            stats: stats,
            selectedStatForExplanation: $selectedStatForExplanation,
            showingMasteryRoadmap: $showingMasteryRoadmap
        )
        .sheet(item: $selectedStatForExplanation) { detail in
            StatExplanationSheet(detail: detail)
        }
        .sheet(isPresented: $showingMasteryRoadmap) {
            MasteryRoadmap(stats: stats)
        }
    }
    
    private var hydrationSection: some View {
        HydrationSection()
    }
    
    private var dashboardDisplaySection: some View {
        DashboardDisplaySection()
    }
    
    private var themeHierarchySection: some View {
        ThemeHierarchySection(
            selectedCategoryForDisplay: $selectedCategoryForDisplay,
            showingAddTheme: $showingAddTheme
        )
    }
    
    private var aboutSection: some View {
        AboutSection()
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

#Preview {
    NavigationStack {
        Settings()
            .modelContainer(DataController.preview)
            .environment(ThemeManager.shared)
    }
}

