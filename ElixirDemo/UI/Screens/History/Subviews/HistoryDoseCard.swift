//
//  HistoryDoseCard.swift
//  Elixir: Daily Ritual
//
//  Created by Claude on 31.12.2025.
//

import SwiftUI

struct HistoryDoseCard: View {
    let medication: Medication
    let doseLog: DoseLog

    @Environment(ThemeManager.self) private var themeManager

    var iconColor: Color {
        Color(hex: medication.colorHex)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: doseLog.scheduledTime)
    }

    var statusText: String {
        switch doseLog.status {
        case .taken: return "Taken"
        case .pending: return "Pending"
        case .skipped: return "Skipped"
        case .missed: return "Missed"
        }
    }

    var statusColor: Color {
        switch doseLog.status {
        case .taken: return themeManager.currentTheme.successColor
        case .pending: return themeManager.currentTheme.textSecondary
        case .skipped: return themeManager.currentTheme.accentColor
        case .missed: return themeManager.currentTheme.errorColor
        }
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Left: Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: medication.iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
            }

            // Middle: Info
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(themeManager.currentTheme.font(for: .subheadline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 10))
                        .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.8))

                    Text(formattedTime)
                        .font(themeManager.currentTheme.font(for: .caption))
                        .foregroundColor(themeManager.currentTheme.textSecondary)

                    Text("•")
                        .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))

                    Text(medication.dosage)
                        .font(themeManager.currentTheme.font(for: .caption))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                }
            }

            Spacer()

            // Right: Status
            Text(statusText)
                .font(themeManager.currentTheme.font(for: .caption))
                .foregroundColor(statusColor)
                .padding(.horizontal, Spacing.sm)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(statusColor.opacity(0.15))
                )
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(iconColor.opacity(0.3), lineWidth: 1)
        )
    }
}
