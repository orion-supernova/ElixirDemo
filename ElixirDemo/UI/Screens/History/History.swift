//
//  History.swift
//  Elixir: Daily Ritual
//
//  Created by Claude on 31.12.2025.
//

import SwiftUI
import SwiftData

struct History: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    @State private var doseLogGenerator: DoseLogGenerator?
    @Query private var allDoseLogs: [DoseLog]

    var body: some View {
        ZStack {
            // Background
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    // Month Selector
                    MonthSelector(currentMonth: $currentMonth)

                    // Calendar Grid
                    CalendarGrid(currentMonth: currentMonth, selectedDate: $selectedDate)

                    // Selected Date Doses
                    if !doseLogsForSelectedDate.isEmpty {
                        selectedDateSection
                    } else {
                        emptyDayView
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.lg)
            }
        }
        .navigationTitle("Calendar")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if doseLogGenerator == nil {
                doseLogGenerator = DoseLogGenerator(modelContext: modelContext)
            }
            generateLogsForCurrentMonth()
        }
        .onChange(of: currentMonth) { _, _ in
            generateLogsForCurrentMonth()
        }
    }

    // Generate dose logs for the currently viewed month
    private func generateLogsForCurrentMonth() {
        guard let generator = doseLogGenerator else { return }

        let calendar = Calendar.current
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth) else { return }

        // Generate logs for the entire month
        generator.ensureLogsExist(for: monthInterval.start...monthInterval.end)
    }

    // MARK: - Selected Date Section
    @ViewBuilder
    private var selectedDateSection: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text(selectedDateString)
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                Spacer()

                // Stats for the day
                HStack(spacing: Spacing.sm) {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.currentTheme.successColor)
                        Text("\(doseLogsForSelectedDate.filter { $0.isTaken }.count)")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.currentTheme.errorColor)
                        Text("\(doseLogsForSelectedDate.filter { $0.isMissed }.count)")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }
                }
            }

            // Dose logs for selected date
            ForEach(doseLogsForSelectedDate, id: \.id) { doseLog in
                if let medication = doseLog.medication {
                    HistoryDoseCard(medication: medication, doseLog: doseLog)
                }
            }
        }
    }

    @ViewBuilder
    private var emptyDayView: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 48))
                .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))

            Text("No rituals scheduled")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            Text("for \(selectedDateString)")
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    // MARK: - Helpers
    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }

    private var doseLogsForSelectedDate: [DoseLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return allDoseLogs.filter { log in
            log.scheduledTime >= startOfDay && log.scheduledTime < endOfDay
        }.sorted { $0.scheduledTime < $1.scheduledTime }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        History()
            .modelContainer(DataController.preview)
            .environment(ThemeManager.shared)
    }
}
