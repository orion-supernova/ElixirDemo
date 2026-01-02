//
//  WeeklyOverviewSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct WeeklyOverviewSection: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("This Week")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                Spacer()

                NavigationLink(destination: History()) {
                    HStack(spacing: Spacing.xs) {
                        Text("Calendar")
                            .font(themeManager.currentTheme.font(for: .caption))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }

            HStack(spacing: Spacing.sm) {
                ForEach(0..<7) { dayOffset in
                    let date = Calendar.current.date(byAdding: .day, value: -6 + dayOffset, to: Date()) ?? Date()
                    let isToday = Calendar.current.isDateInToday(date)
                    let dayName = dayName(for: date)

                    VStack(spacing: Spacing.xs) {
                        Text(dayName)
                            .font(themeManager.currentTheme.font(for: .caption2))
                            .foregroundColor(isToday ? themeManager.currentTheme.primaryColor : themeManager.currentTheme.textSecondary)

                        Circle()
                            .fill(isToday ?
                                  themeManager.currentTheme.primaryColor :
                                    Color.white.opacity(0.2))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(themeManager.currentTheme.font(for: .caption))
                                    .foregroundColor(isToday ? .white : themeManager.currentTheme.textPrimary)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

#Preview {
    WeeklyOverviewSection()
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
