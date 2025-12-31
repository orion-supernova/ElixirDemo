//
//  MedicationsListView.swift
//  Elixir: Daily Ritual
//
//  Created by Claude on 31.12.2025.
//

import SwiftUI
import SwiftData

struct MedicationsListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Medication.createdAt, order: .reverse) private var medications: [Medication]

    var body: some View {
        ZStack {
            // Background
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    if medications.isEmpty {
                        emptyStateView
                    } else {
                        ForEach(medications) { medication in
                            MedicationSettingsCard(medication: medication)
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.lg)
            }
        }
        .navigationTitle("All Rituals")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Empty State
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: themeManager.currentTheme.symbols.currency)
                .font(.system(size: 64))
                .foregroundColor(themeManager.currentTheme.primaryColor)

            Text("No rituals yet")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            Text("Add your first medication to begin tracking")
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }
}

// MARK: - Medication Settings Card
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
        NotificationManager.shared.cancelNotifications(for: medication)
        modelContext.delete(medication)
        try? modelContext.save()
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MedicationsListView()
            .modelContainer(DataController.preview)
            .environment(ThemeManager.shared)
    }
}
