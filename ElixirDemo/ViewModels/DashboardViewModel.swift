//
//  DashboardViewModel.swift
//  Elixir: Daily Ritual
//
//  Business logic for the Dashboard screen
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
@Observable
final class DashboardViewModel {
    private let modelContext: ModelContext
    private let gamificationManager: GamificationManager
    private let doseLogGenerator: DoseLogGenerator

    // State
    var selectedDate: Date = Date()
    var doseLogs: [DoseLog] = []
    var userStats: UserStats?

    // Computed Properties
    var todayProgress: Double {
        guard !doseLogs.isEmpty else { return 0 }
        let takenCount = doseLogs.filter { $0.isTaken }.count
        return Double(takenCount) / Double(doseLogs.count)
    }

    var totalDoses: Int {
        doseLogs.count
    }

    var takenDoses: Int {
        doseLogs.filter { $0.isTaken }.count
    }

    var pendingDoses: Int {
        doseLogs.filter { $0.isPending }.count
    }

    var missedDoses: Int {
        doseLogs.filter { $0.isMissed }.count
    }

    var isAllComplete: Bool {
        !doseLogs.isEmpty && doseLogs.allSatisfy { $0.isTaken }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.gamificationManager = GamificationManager(modelContext: modelContext)
        self.doseLogGenerator = DoseLogGenerator(modelContext: modelContext)

        ensureLogsExistForCurrentWeek()
        loadUserStats()
        loadDoseLogsForSelectedDate()
    }
    
    func refresh() {
        ensureLogsExistForCurrentWeek()
        loadUserStats()
        loadDoseLogsForSelectedDate()
    }

    // MARK: - Ensure Logs Exist
    private func ensureLogsExistForCurrentWeek() {
        let calendar = Calendar.current
        let today = Date()
        guard let weekStart = calendar.date(byAdding: .day, value: -3, to: today),
              let weekEnd = calendar.date(byAdding: .day, value: 7, to: today) else { return }

        doseLogGenerator.ensureLogsExist(for: weekStart...weekEnd)
    }

    // MARK: - Data Loading
    func loadUserStats() {
        userStats = gamificationManager.getUserStats()
    }

    func loadDoseLogsForSelectedDate() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<DoseLog>(
            predicate: #Predicate { log in
                log.scheduledTime >= startOfDay && log.scheduledTime < endOfDay
            },
            sortBy: [SortDescriptor(\.scheduledTime, order: .forward)]
        )

        do {
            doseLogs = try modelContext.fetch(descriptor)
        } catch {
            print("Error fetching dose logs: \(error)")
            doseLogs = []
        }
    }

    // MARK: - Date Navigation
    func selectDate(_ date: Date) {
        selectedDate = date
        ensureLogsExistForDate(date)
        loadDoseLogsForSelectedDate()
    }

    private func ensureLogsExistForDate(_ date: Date) {
        let calendar = Calendar.current
        guard let dayStart = calendar.date(byAdding: .day, value: -1, to: date),
              let dayEnd = calendar.date(byAdding: .day, value: 1, to: date) else { return }

        doseLogGenerator.ensureLogsExist(for: dayStart...dayEnd)
    }

    func goToPreviousDay() {
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            selectDate(previousDay)
        }
    }

    func goToNextDay() {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            selectDate(nextDay)
        }
    }

    func goToToday() {
        selectDate(Date())
    }

    // MARK: - Dose Actions
    func toggleDoseStatus(for doseLog: DoseLog) {
        switch doseLog.status {
        case .pending:
            markDoseAsTaken(doseLog)
        case .taken:
            // Allow untaking but don't refund XP (prevents exploits)
            markDoseAsPending(doseLog)
        case .skipped:
            markDoseAsTaken(doseLog)
        case .missed:
            markDoseAsTaken(doseLog)
        }

        loadDoseLogsForSelectedDate()
        loadUserStats()
    }

    private func markDoseAsTaken(_ doseLog: DoseLog) {
        // Only award XP if not already taken (prevent XP farming)
        if !doseLog.isTaken {
            gamificationManager.recordDoseTaken(for: doseLog)

            // Check if day is complete and update streak
            if isAllComplete {
                gamificationManager.updateDailyStreak(for: selectedDate)
            }
        }
    }

    private func markDoseAsPending(_ doseLog: DoseLog) {
        // Allow untaking but XP is not refunded
        doseLog.status = .pending
        doseLog.takenTime = nil
        try? modelContext.save()
    }

    func markDoseAsSkipped(_ doseLog: DoseLog) {
        gamificationManager.recordDoseSkipped(for: doseLog)
        loadDoseLogsForSelectedDate()
    }

    func markDoseAsMissed(_ doseLog: DoseLog) {
        gamificationManager.recordDoseMissed(for: doseLog)
        loadDoseLogsForSelectedDate()
    }

    // MARK: - Week Calendar Data
    func getWeekDays(for date: Date) -> [Date] {
        let calendar = Calendar.current
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: date) else {
            return []
        }

        var days: [Date] = []
        var currentDate = weekInterval.start

        for _ in 0..<7 {
            days.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return days
    }

    func isDateSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: selectedDate)
    }

    func isDateToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    // MARK: - Completion Check for Date
    func getCompletionStatus(for date: Date) -> CompletionStatus {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<DoseLog>(
            predicate: #Predicate { log in
                log.scheduledTime >= startOfDay && log.scheduledTime < endOfDay
            }
        )

        guard let logs = try? modelContext.fetch(descriptor), !logs.isEmpty else {
            return .none
        }

        let allTaken = logs.allSatisfy { $0.isTaken }
        let anyTaken = logs.contains { $0.isTaken }

        if allTaken {
            return .complete
        } else if anyTaken {
            return .partial
        } else {
            return .none
        }
    }
}

// MARK: - Completion Status
enum CompletionStatus {
    case complete
    case partial
    case missed
    case none
}
