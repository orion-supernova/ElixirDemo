//
//  CalendarGrid.swift
//  Elixir: Daily Ritual
//
//  Created by Claude on 31.12.2025.
//

import SwiftUI
import SwiftData

struct CalendarGrid: View {
    @Environment(ThemeManager.self) private var themeManager

    let currentMonth: Date
    @Binding var selectedDate: Date
    @Query private var allDoseLogs: [DoseLog]

    var body: some View {
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

    private var weekdaySymbols: [String] {
        let formatter = DateFormatter()
        return formatter.shortWeekdaySymbols
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

struct CalendarDay: Identifiable {
    let id = UUID()
    let date: Date?
}
