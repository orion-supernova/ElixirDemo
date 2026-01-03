//
//  HydrationSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct HydrationSection: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    @Query private var waterSettings: [WaterSettings]

    var body: some View {
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
                        Task {
                            if newValue {
                                await WaterNotificationManager.shared.scheduleWaterReminders(
                                    frequencyHours: settings.frequencyHours,
                                    startHour: settings.activeStartHour,
                                    endHour: settings.activeEndHour
                                )
                            } else {
                                await WaterNotificationManager.shared.cancelAllWaterReminders()
                            }
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
                                Task {
                                    await WaterNotificationManager.shared.scheduleWaterReminders(
                                        frequencyHours: newValue,
                                        startHour: settings.activeStartHour,
                                        endHour: settings.activeEndHour
                                    )
                                }
                                try? modelContext.save()
                            }
                        )) {
                            Text("1h").tag(1)
                            Text("2h").tag(2)
                            Text("4h").tag(4)
                            Text("6h").tag(6)
                        }
                        .pickerStyle(.segmented)

                        // Show scheduled hours
                        Text("Reminders at: \(scheduledHoursText(frequency: settings.frequencyHours, start: settings.activeStartHour, end: settings.activeEndHour))")
                            .font(themeManager.currentTheme.font(for: .caption2))
                            .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.7))
                            .padding(.top, 4)
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
                                        Task {
                                            await WaterNotificationManager.shared.scheduleWaterReminders(
                                                frequencyHours: settings.frequencyHours,
                                                startHour: newValue,
                                                endHour: settings.activeEndHour
                                            )
                                        }
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
                                        Task {
                                            await WaterNotificationManager.shared.scheduleWaterReminders(
                                                frequencyHours: settings.frequencyHours,
                                                startHour: settings.activeStartHour,
                                                endHour: newValue
                                            )
                                        }
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

    // Helper function to generate scheduled hours text
    private func scheduledHoursText(frequency: Int, start: Int, end: Int) -> String {
        var hours: [Int] = []
        var currentHour = start

        while currentHour <= end {
            hours.append(currentHour)
            currentHour += frequency
        }

        if hours.count <= 5 {
            // Show all hours if 5 or fewer
            return hours.map { String(format: "%d:00", $0) }.joined(separator: ", ")
        } else {
            // Show first 3 and last 2 with ellipsis
            let first3 = hours.prefix(3).map { String(format: "%d:00", $0) }
            let last2 = hours.suffix(2).map { String(format: "%d:00", $0) }
            return first3.joined(separator: ", ") + " ... " + last2.joined(separator: ", ")
        }
    }
}

#Preview {
    HydrationSection()
        .modelContainer(DataController.preview)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
