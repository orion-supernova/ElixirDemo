//
//  HistoryView.swift
//  Elixir: Daily Ritual
//
//  Created by Claude on 31.12.2025.
//

import SwiftUI
import SwiftData

struct HistoryView: View {
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
                    monthSelector

                    // Calendar Grid
                    calendarGrid

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

    // MARK: - Month Selector
    @ViewBuilder
    private var monthSelector: some View {
        HStack {
            Button {
                withAnimation {
                    currentMonth = Calendar.current.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }

            Spacer()

            VStack(spacing: 2) {
                Text(monthYearString)
                    .font(themeManager.currentTheme.font(for: .title3))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
            }

            Spacer()

            Button {
                withAnimation {
                    currentMonth = Calendar.current.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                }
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.1))
                    )
            }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.primaryColor.opacity(0.2), lineWidth: 1)
        )
    }

    // MARK: - Calendar Grid
    @ViewBuilder
    private var calendarGrid: some View {
        VStack(spacing: Spacing.sm) {
            // Weekday headers
            HStack(spacing: 0) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(themeManager.currentTheme.font(for: .caption2))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Calendar days
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: Spacing.xs), count: 7), spacing: Spacing.xs) {
                ForEach(daysInMonth) { day in
                    if let date = day.date {
                        calendarDayCell(for: date)
                    } else {
                        Color.clear
                            .frame(height: 50)
                    }
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
                .stroke(themeManager.currentTheme.primaryColor.opacity(0.2), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func calendarDayCell(for date: Date) -> some View {
        let isSelected = Calendar.current.isDate(date, inSameDayAs: selectedDate)
        let isToday = Calendar.current.isDateInToday(date)
        let completionStatus = getCompletionStatus(for: date)
        let dayNumber = Calendar.current.component(.day, from: date)

        Button {
            withAnimation {
                selectedDate = date
            }
        } label: {
            VStack(spacing: 4) {
                Text("\(dayNumber)")
                    .font(themeManager.currentTheme.font(for: .caption))
                    .foregroundColor(isSelected ? .white : themeManager.currentTheme.textPrimary)

                // Status indicator
                Circle()
                    .fill(statusColor(for: completionStatus))
                    .frame(width: 6, height: 6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? themeManager.currentTheme.primaryColor : (isToday ? Color.white.opacity(0.1) : Color.clear))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isToday && !isSelected ? themeManager.currentTheme.primaryColor.opacity(0.5) : Color.clear, lineWidth: 1)
            )
        }
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
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: currentMonth)
    }

    private var selectedDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: selectedDate)
    }

    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        return formatter.shortWeekdaySymbols
    }

    private struct CalendarDay: Identifiable {
        let id = UUID()
        let date: Date?
    }

    private var daysInMonth: [CalendarDay] {
        guard let monthInterval = Calendar.current.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = Calendar.current.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }

        let monthDays = Calendar.current.dateComponents([.day], from: monthInterval.start, to: monthInterval.end).day ?? 0

        var days: [CalendarDay] = []

        // Add leading empty cells
        let firstWeekday = Calendar.current.component(.weekday, from: monthInterval.start)
        for _ in 0..<(firstWeekday - 1) {
            days.append(CalendarDay(date: nil))
        }

        // Add month days
        for day in 0..<monthDays {
            if let date = Calendar.current.date(byAdding: .day, value: day, to: monthInterval.start) {
                days.append(CalendarDay(date: date))
            }
        }

        return days
    }

    private var doseLogsForSelectedDate: [DoseLog] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        return allDoseLogs.filter { log in
            log.scheduledTime >= startOfDay && log.scheduledTime < endOfDay
        }.sorted { $0.scheduledTime < $1.scheduledTime }
    }

    private func getCompletionStatus(for date: Date) -> CompletionStatus {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let logs = allDoseLogs.filter { log in
            log.scheduledTime >= startOfDay && log.scheduledTime < endOfDay
        }

        guard !logs.isEmpty else {
            return .none
        }

        let allTaken = logs.allSatisfy { $0.isTaken }
        let anyTaken = logs.contains { $0.isTaken }
        let anyMissed = logs.contains { $0.isMissed }

        if allTaken {
            return .complete
        } else if anyMissed {
            return .missed
        } else if anyTaken {
            return .partial
        } else {
            return .none
        }
    }

    private func statusColor(for status: CompletionStatus) -> Color {
        switch status {
        case .complete:
            return themeManager.currentTheme.successColor
        case .partial:
            return themeManager.currentTheme.accentColor
        case .missed:
            return themeManager.currentTheme.errorColor
        case .none:
            return Color.white.opacity(0.2)
        }
    }
}

// MARK: - History Dose Card
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

// MARK: - Preview
#Preview {
    NavigationStack {
        HistoryView()
            .modelContainer(DataController.preview)
            .environment(ThemeManager.shared)
    }
}
