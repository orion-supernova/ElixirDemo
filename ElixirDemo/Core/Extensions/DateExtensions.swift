//
//  DateExtensions.swift
//  Elixir: Daily Ritual
//
//  Useful date manipulation helpers
//

import Foundation

extension Date {
    /// Returns true if the date is today
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    /// Returns true if the date is in the past (not today)
    var isPast: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let thisDate = Calendar.current.startOfDay(for: self)
        return thisDate < today
    }

    /// Returns true if the date is in the future (not today)
    var isFuture: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        let thisDate = Calendar.current.startOfDay(for: self)
        return thisDate > today
    }

    /// Get the start of the day
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    /// Get the end of the day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }

    /// Format as "MMM d, yyyy" (e.g., "Dec 31, 2025")
    var mediumDateString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: self)
    }

    /// Format as "h:mm a" (e.g., "8:00 PM")
    var shortTimeString: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }

    /// Format as "EEEE, MMM d" (e.g., "Tuesday, Dec 31")
    var longDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: self)
    }

    /// Get the day name (e.g., "Monday")
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }

    /// Get the month name (e.g., "December")
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }

    /// Add days to the current date
    func addingDays(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: days, to: self) ?? self
    }

    /// Add hours to the current date
    func addingHours(_ hours: Int) -> Date {
        Calendar.current.date(byAdding: .hour, value: hours, to: self) ?? self
    }

    /// Check if date is the same day as another date
    func isSameDay(as otherDate: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: otherDate)
    }

    /// Get the number of days between two dates
    func daysBetween(_ otherDate: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: self, to: otherDate)
        return abs(components.day ?? 0)
    }
}
