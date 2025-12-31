//
//  SettingsView.swift
//  Elixir: Daily Ritual
//
//  Settings and profile screen
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.themeManager) private var themeManager
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
        .sheet(isPresented: $showingAddTheme) {
            AddCustomThemeView()
        }
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
                    .foregroundColor(.white)
            }

            Text("Ritual Master")
                .ritualFont(.ritualTitle2)
                .foregroundColor(.white)

            Text("Manage your settings and preferences")
                .ritualFont(.ritualCallout)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
    }

    // MARK: - Profile Section
    @ViewBuilder
    private func profileSection(stats: UserStats) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Your Progress")
                .ritualFont(.ritualHeadline)
                .foregroundColor(.white)

            HStack(spacing: Spacing.md) {
                StatBadge(
                    value: "\(stats.currentLevel)",
                    label: "Level",
                    icon: "star.fill",
                    color: themeManager.currentTheme.warning
                )

                StatBadge(
                    value: "\(stats.currentStreak)",
                    label: "Streak",
                    icon: "flame.fill",
                    color: themeManager.currentTheme.error
                )

                StatBadge(
                    value: "\(stats.totalDosesTaken)",
                    label: "Doses",
                    icon: "checkmark.circle.fill",
                    color: themeManager.currentTheme.success
                )
            }

            VStack(alignment: .leading, spacing: Spacing.sm) {
                HStack {
                    Text("Title")
                        .ritualFont(.ritualSubheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(stats.currentTitle)
                        .ritualFont(.ritualHeadline)
                        .foregroundColor(themeManager.currentTheme.primary)
                }

                HStack {
                    Text("Total XP")
                        .ritualFont(.ritualSubheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(stats.totalXP)")
                        .ritualFont(.ritualHeadline)
                        .foregroundColor(.white)
                }

                HStack {
                    Text("Completion Rate")
                        .ritualFont(.ritualSubheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text("\(Int(stats.completionRate * 100))%")
                        .ritualFont(.ritualHeadline)
                        .foregroundColor(themeManager.currentTheme.success)
                }
            }
            .padding(Spacing.md)
            .glassCard()
        }
    }

    // MARK: - Themes Section
    private var themesSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Themes")
                    .ritualFont(.ritualHeadline)
                    .foregroundColor(.white)

                Spacer()

                Button(action: {
                    showingAddTheme = true
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Custom")
                    }
                    .ritualFont(.ritualSubheadline)
                    .foregroundColor(themeManager.currentTheme.primary)
                }
            }

            VStack(spacing: Spacing.sm) {
                ForEach(themeManager.allThemes) { theme in
                    ThemeRow(
                        theme: theme,
                        isSelected: themeManager.currentTheme.id == theme.id,
                        onSelect: {
                            withAnimation(.ritualSpring) {
                                themeManager.selectTheme(theme)
                            }
                        },
                        onDelete: theme.isCustom ? {
                            themeManager.deleteCustomTheme(theme)
                        } : nil
                    )
                }
            }
        }
    }

    // MARK: - About Section
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("About")
                .ritualFont(.ritualHeadline)
                .foregroundColor(.white)

            VStack(spacing: 0) {
                SettingsRow(icon: "info.circle.fill", title: "Version", value: "1.0.0")
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "doc.text.fill", title: "Privacy Policy", value: "")
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "envelope.fill", title: "Support", value: "")
            }
            .padding(Spacing.md)
            .glassCard()
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
    let theme: AppTheme
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: (() -> Void)?

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: Spacing.md) {
                // Theme Preview
                HStack(spacing: 2) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: theme.bgColor1))
                        .frame(width: 20, height: 40)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: theme.bgColor2))
                        .frame(width: 20, height: 40)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: theme.primaryColor))
                        .frame(width: 20, height: 40)
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )

                // Theme Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(theme.name)
                        .ritualFont(.ritualHeadline)
                        .foregroundColor(.white)

                    if theme.isCustom {
                        Text("Custom")
                            .ritualFont(.ritualCaption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Spacer()

                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: theme.primaryColor))
                        .font(.system(size: 24))
                }

                // Delete Button
                if let onDelete = onDelete {
                    Button(action: onDelete) {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red.opacity(0.8))
                    }
                    .buttonStyle(PlainButtonStyle())
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

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24)

            Text(title)
                .ritualFont(.ritualCallout)
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .ritualFont(.ritualSubheadline)
                .foregroundColor(.white.opacity(0.6))

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.4))
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

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .ritualFont(.ritualTitle2)
                .foregroundColor(.white)

            Text(label)
                .ritualFont(.ritualCaption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.md)
        .glassCard()
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
