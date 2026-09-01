//
//  ReminderStatusSection.swift
//  Elixir: Daily Ritual
//
//  Simplified reminder health indicator for Settings.
//  Replaces the verbose NotificationStatusSection inline view.
//  Full diagnostics are accessible via a detail sheet.
//

import SwiftUI

struct ReminderStatusSection: View {
    @Environment(ThemeManager.self) private var themeManager
    @StateObject private var budgetManager = NotificationBudgetManager.shared

    private var isHealthy: Bool { !budgetManager.isOverBudget }
    private var usedSlots: Int { budgetManager.usedSlots }

    var body: some View {
        NavigationLink {
            ReminderDetailDestination()
        } label: {
            HStack(spacing: Spacing.md) {
                // Status Icon
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.15))
                        .frame(width: 44, height: 44)

                    Image(systemName: statusIcon)
                        .font(.system(size: 20))
                        .foregroundColor(statusColor)
                }

                // Label + subtitle
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reminders")
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(themeManager.currentTheme.textPrimary)

                    Text(statusText)
                        .font(themeManager.currentTheme.font(for: .caption))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                }

                Spacer()

                // Badge + chevron
                HStack(spacing: 6) {
                    Text(isHealthy ? "Healthy" : "Attention")
                        .font(themeManager.currentTheme.font(for: .caption2))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(statusColor.opacity(0.12))
                        .clipShape(Capsule())

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.currentTheme.surfaceColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isHealthy ? Color.white.opacity(0.1) : statusColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            Task { await budgetManager.refresh() }
        }
    }

    private var statusColor: Color {
        isHealthy ? themeManager.currentTheme.successColor : themeManager.currentTheme.errorColor
    }

    private var statusIcon: String {
        isHealthy ? "bell.badge.fill" : "exclamationmark.triangle.fill"
    }

    private var statusText: String {
        if isHealthy {
            return "\(usedSlots) of 64 slots in use"
        } else {
            return "Over limit — some may not fire"
        }
    }
}

// MARK: - Navigation Destination (pushed within Settings NavigationStack)
struct ReminderDetailDestination: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                NotificationStatusSection()
                    .padding(Spacing.md)
            }
        }
        .navigationTitle("Reminder Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ReminderStatusSection()
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
