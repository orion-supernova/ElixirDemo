//
//  MedicationSettingsCard.swift
//  Elixir: Daily Ritual
//
//  Created by Claude on 31.12.2025.
//

import SwiftUI
import SwiftData

struct MedicationSettingsCard: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    let medication: Medication
    @State private var showDeleteAlert = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            // Header with icon and name
            HStack(spacing: Spacing.md) {
                Image(systemName: medication.iconName)
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: medication.colorHex))
                    .frame(width: 56, height: 56)
                    .background(
                        Circle()
                            .fill(Color(hex: medication.colorHex).opacity(0.2))
                    )

                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text(medication.name)
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(themeManager.currentTheme.textPrimary)

                    Text(medication.dosage)
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                }

                Spacer()

                Menu {
                    Button(role: .destructive, action: {
                        showDeleteAlert = true
                    }) {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 18))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                        .padding(Spacing.sm)
                }
            }

            Divider()
                .background(Color.white.opacity(0.1))

            // Settings
            VStack(alignment: .leading, spacing: Spacing.sm) {
                settingRow(label: "Frequency", value: medication.frequency.rawValue)

                if !medication.scheduledTimes.isEmpty {
                    settingRow(
                        label: "Times",
                        value: medication.scheduledTimes.map { timeString(from: $0) }.joined(separator: ", ")
                    )
                }

                settingRow(
                    label: "Started",
                    value: dateString(from: medication.startDate)
                )

                if let endDate = medication.endDate {
                    settingRow(
                        label: "Ends",
                        value: dateString(from: endDate)
                    )
                }
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hex: medication.colorHex).opacity(0.3), lineWidth: 1)
        )
        .alert("Delete Ritual", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteMedication()
            }
        } message: {
            Text("Are you sure you want to delete \"\(medication.name)\"? This action cannot be undone.")
        }
    }

    @ViewBuilder
    private func settingRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(themeManager.currentTheme.font(for: .caption))
                .foregroundColor(themeManager.currentTheme.textSecondary)

            Spacer()

            Text(value)
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textPrimary)
        }
    }

    private func timeString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    private func deleteMedication() {
        Task {
            // Cancel notifications first and wait
            await NotificationManager.shared.cancelNotifications(for: medication)

            // Update budget manager
            await NotificationBudgetManager.shared.refresh()

            // Then delete from database
            await MainActor.run {
                modelContext.delete(medication)
                try? modelContext.save()
            }
        }
    }
}
