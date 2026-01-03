//
//  NotificationStatusSection.swift
//  Elixir: Daily Ritual
//
//  Created by Claude on 02.01.2026.
//

import SwiftUI

struct NotificationStatusSection: View {
    @Environment(ThemeManager.self) private var themeManager
    @StateObject private var budgetManager = NotificationBudgetManager.shared
    @State private var showingMedicationDetails = false
    @State private var showingWaterDetails = false
    @State private var showingRescheduleDetails = false
    @State private var showingBGTaskDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Notification Status")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                Spacer()

                if budgetManager.isOverBudget {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                        Text("Over Limit")
                            .font(themeManager.currentTheme.font(for: .caption2))
                    }
                    .foregroundColor(themeManager.currentTheme.errorColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(themeManager.currentTheme.errorColor.opacity(0.1))
                    .cornerRadius(8)
                }
            }

            // Budget usage bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(budgetManager.usedSlots) / 64 slots used")
                        .font(themeManager.currentTheme.font(for: .caption))
                        .foregroundColor(themeManager.currentTheme.textSecondary)

                    Spacer()

                    Text("\(Int(budgetManager.getBudgetInfo().usagePercentage * 100))%")
                        .font(themeManager.currentTheme.font(for: .caption))
                        .foregroundColor(budgetManager.isOverBudget ? themeManager.currentTheme.errorColor : themeManager.currentTheme.primaryColor)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.1))

                        if budgetManager.isOverBudget {
                            Capsule()
                                .fill(themeManager.currentTheme.errorColor)
                                .frame(width: min(geo.size.width * budgetManager.getBudgetInfo().usagePercentage, geo.size.width))
                        } else {
                            Capsule()
                                .fill(themeManager.currentTheme.primaryGradient)
                                .frame(width: min(geo.size.width * budgetManager.getBudgetInfo().usagePercentage, geo.size.width))
                        }
                    }
                }
                .frame(height: 8)
            }

            Divider().background(Color.white.opacity(0.1))

            // Breakdown
            HStack(spacing: Spacing.md) {
                NotificationTypeCard(
                    icon: "pill.fill",
                    label: "Medication Notification Slots",
                    count: budgetManager.medicationCount,
                    color: themeManager.currentTheme.errorColor
                )
                .onTapGesture {
                    showingMedicationDetails = true
                }

                NotificationTypeCard(
                    icon: "drop.fill",
                    label: "Water Notification Slots",
                    count: budgetManager.waterCount,
                    color: themeManager.currentTheme.primaryColor
                )
                .onTapGesture {
                    showingWaterDetails = true
                }

                if budgetManager.rescheduleReminderCount > 0 {
                    NotificationTypeCard(
                        icon: "arrow.clockwise",
                        label: "Re-scheduler Notification Slots",
                        count: budgetManager.rescheduleReminderCount,
                        color: themeManager.currentTheme.warningColor
                    )
                    .onTapGesture {
                        showingRescheduleDetails = true
                    }
                }
            }

            if budgetManager.isOverBudget {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                    Text("You've exceeded the 64 notification limit. Some reminders may not fire.")
                        .font(themeManager.currentTheme.font(for: .caption))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .foregroundColor(themeManager.currentTheme.errorColor)
                .padding(Spacing.sm)
                .background(themeManager.currentTheme.errorColor.opacity(0.1))
                .cornerRadius(8)
            }

            Divider().background(Color.white.opacity(0.1))

            // BGTask Status
            BGTaskStatusView()
                .onTapGesture {
                    showingBGTaskDetails = true
                }
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(budgetManager.isOverBudget ? themeManager.currentTheme.errorColor.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
        )
        .onAppear {
            Task {
                await budgetManager.refresh()
            }
        }
        .fullScreenCover(isPresented: $showingMedicationDetails) {
            MedicationDetailsSheet()
        }
        .fullScreenCover(isPresented: $showingWaterDetails) {
            WaterDetailsSheet()
        }
        .fullScreenCover(isPresented: $showingRescheduleDetails) {
            RescheduleDetailsSheet()
        }
        .fullScreenCover(isPresented: $showingBGTaskDetails) {
            BGTaskDetailsSheet()
        }
    }
}

struct BGTaskStatusView: View {
    @Environment(ThemeManager.self) private var themeManager
    @State private var nextRefreshDate: Date?
    @State private var nextProcessingDate: Date?
    @State private var currentTime = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.xs) {
            Text("Background Refresh Status")
                .font(themeManager.currentTheme.font(for: .caption))
                .foregroundColor(themeManager.currentTheme.textSecondary)

            HStack(spacing: Spacing.md) {
                // App Refresh Task
                HStack(spacing: 4) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.currentTheme.primaryColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Refresh")
                            .font(themeManager.currentTheme.font(for: .caption2))
                            .foregroundColor(themeManager.currentTheme.textPrimary)

                        if let nextRefresh = nextRefreshDate {
                            Text(timeUntil(nextRefresh))
                                .font(themeManager.currentTheme.font(for: .caption2))
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                        } else {
                            Text("Scheduled")
                                .font(themeManager.currentTheme.font(for: .caption2))
                                .foregroundColor(themeManager.currentTheme.successColor)
                        }
                    }
                }

                Spacer()

                // Processing Task
                HStack(spacing: 4) {
                    Image(systemName: "gearshape.circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.currentTheme.warningColor)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Deep Clean")
                            .font(themeManager.currentTheme.font(for: .caption2))
                            .foregroundColor(themeManager.currentTheme.textPrimary)

                        if let nextProcessing = nextProcessingDate {
                            Text(timeUntil(nextProcessing))
                                .font(themeManager.currentTheme.font(for: .caption2))
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                        } else {
                            Text("Scheduled")
                                .font(themeManager.currentTheme.font(for: .caption2))
                                .foregroundColor(themeManager.currentTheme.successColor)
                        }
                    }
                }
            }

            Text("BGTasks run automatically in background to keep notifications fresh")
                .font(themeManager.currentTheme.font(for: .caption2))
                .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.6))
                .padding(.top, 2)
        }
        .padding(Spacing.sm)
        .background(Color.white.opacity(0.03))
        .cornerRadius(8)
        .onAppear {
            loadBGTaskStatus()
            startTimer()
        }
        .onDisappear {
            // Timer will be cleaned up automatically
        }
    }

    private func loadBGTaskStatus() {
        nextRefreshDate = UserDefaults.standard.object(forKey: "bgAppRefreshScheduledDate") as? Date
        nextProcessingDate = UserDefaults.standard.object(forKey: "bgProcessingScheduledDate") as? Date

        // If no dates exist, initialize default estimates
        if nextRefreshDate == nil {
            nextRefreshDate = Date(timeIntervalSinceNow: 24 * 60 * 60)
        }
        if nextProcessingDate == nil {
            nextProcessingDate = Date(timeIntervalSinceNow: 7 * 24 * 60 * 60)
        }
    }

    private func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
            currentTime = Date()
        }
    }

    private func timeUntil(_ date: Date) -> String {
        let interval = date.timeIntervalSince(currentTime)

        guard interval > 0 else {
            return "Pending..."
        }

        let hours = Int(interval / 3600)

        if hours < 1 {
            let minutes = Int(interval / 60)
            return "in ~\(minutes)m"
        } else if hours < 24 {
            return "in ~\(hours)h"
        } else {
            let days = hours / 24
            let remainingHours = hours % 24
            if remainingHours > 0 {
                return "in ~\(days)d \(remainingHours)h"
            } else {
                return "in ~\(days)d"
            }
        }
    }
}

// MARK: - Detail Sheets

struct MedicationDetailsSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var groupedNotifications: [(medicationId: String, notifications: [UNNotificationRequest])] = []
    @State private var totalCount: Int = 0

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "pill.fill")
                                .font(.system(size: 24))
                                .foregroundColor(themeManager.currentTheme.errorColor)

                            Text("Medication Slots")
                                .font(themeManager.currentTheme.font(for: .title2))
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                        }

                        Text("\(totalCount) reminders for \(groupedNotifications.count) rituals")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
                    }
                }
                .padding()
                .background(.ultraThinMaterial)

                // Description banner
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(themeManager.currentTheme.errorColor)
                        Text("Active Medication Reminders")
                            .font(themeManager.currentTheme.font(for: .subheadline))
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                            .fontWeight(.semibold)
                    }

                    Text("These are notifications currently scheduled for your active rituals. Each ritual may have multiple reminders based on frequency (daily, every other day, weekly, specific days, etc.).")
                        .font(themeManager.currentTheme.font(for: .caption))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.currentTheme.errorColor.opacity(0.8))

                        Text("These will automatically refresh via Daily Refresh (every ~24h) and Deep Clean (every ~7d) background tasks to keep your reminders active.")
                            .font(themeManager.currentTheme.font(for: .caption2))
                            .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.currentTheme.errorColor.opacity(0.1))

                ScrollView {
                    LazyVStack(spacing: Spacing.lg) {
                        if groupedNotifications.isEmpty {
                            VStack(spacing: Spacing.md) {
                                Image(systemName: "bell.slash.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.3))
                                    .padding(.top, 60)

                                Text("No Medication Reminders")
                                    .font(themeManager.currentTheme.font(for: .headline))
                                    .foregroundColor(themeManager.currentTheme.textPrimary)

                                Text("Add rituals from the Medications tab to schedule reminders")
                                    .font(themeManager.currentTheme.font(for: .caption))
                                    .foregroundColor(themeManager.currentTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        } else {
                            ForEach(Array(groupedNotifications.enumerated()), id: \.offset) { groupIndex, group in
                                VStack(alignment: .leading, spacing: Spacing.sm) {
                                    // Medication header
                                    HStack {
                                        ZStack {
                                            Circle()
                                                .fill(themeManager.currentTheme.errorColor.opacity(0.2))
                                                .frame(width: 40, height: 40)

                                            Image(systemName: "pills.fill")
                                                .font(.system(size: 18))
                                                .foregroundColor(themeManager.currentTheme.errorColor)
                                        }

                                        VStack(alignment: .leading, spacing: 2) {
                                            if let firstNotification = group.notifications.first {
                                                Text(firstNotification.content.title)
                                                    .font(themeManager.currentTheme.font(for: .headline))
                                                    .foregroundColor(themeManager.currentTheme.textPrimary)
                                            }

                                            Text("\(group.notifications.count) reminder\(group.notifications.count == 1 ? "" : "s")")
                                                .font(themeManager.currentTheme.font(for: .caption))
                                                .foregroundColor(themeManager.currentTheme.textSecondary)
                                        }

                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.top)

                                    // Notification list for this medication
                                    VStack(spacing: Spacing.xs) {
                                        ForEach(Array(group.notifications.enumerated()), id: \.offset) { index, notification in
                                            HStack(spacing: Spacing.sm) {
                                                Text("#\(index + 1)")
                                                    .font(themeManager.currentTheme.font(for: .caption))
                                                    .foregroundColor(themeManager.currentTheme.errorColor)
                                                    .frame(width: 30)

                                                VStack(alignment: .leading, spacing: 4) {
                                                    if let trigger = notification.trigger as? UNCalendarNotificationTrigger {
                                                        if trigger.repeats {
                                                            HStack(spacing: 4) {
                                                                Image(systemName: "arrow.clockwise")
                                                                    .font(.system(size: 10))
                                                                Text("Repeats daily")
                                                                    .font(themeManager.currentTheme.font(for: .caption2))
                                                            }
                                                            .foregroundColor(themeManager.currentTheme.successColor)

                                                            if let hour = trigger.dateComponents.hour,
                                                               let minute = trigger.dateComponents.minute {
                                                                Text("Every day at \(String(format: "%02d:%02d", hour, minute))")
                                                                    .font(themeManager.currentTheme.font(for: .caption))
                                                                    .foregroundColor(themeManager.currentTheme.textSecondary)
                                                            }
                                                        } else if let nextDate = trigger.nextTriggerDate() {
                                                            HStack(spacing: 4) {
                                                                Image(systemName: "calendar.badge.clock")
                                                                    .font(.system(size: 10))
                                                                Text(nextDate.formatted(date: .abbreviated, time: .shortened))
                                                                    .font(themeManager.currentTheme.font(for: .caption))
                                                            }
                                                            .foregroundColor(themeManager.currentTheme.textSecondary)
                                                        }
                                                    }
                                                }

                                                Spacer()
                                            }
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, Spacing.sm)
                                            .background(Color.white.opacity(0.03))
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                }
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(themeManager.currentTheme.errorColor.opacity(0.3), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            loadNotifications()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Refresh when app becomes active (after theme change, etc.)
                loadNotifications()
            }
        }
    }

    private func loadNotifications() {
        Task {
            let center = UNUserNotificationCenter.current()
            let requests = await center.pendingNotificationRequests()

            // Filter medication notifications
            let medNotifications = requests.filter { request in
                let id = request.identifier
                return !id.contains("water") && !id.contains("reschedule")
            }

            // Group by medication ID (first component of identifier)
            var grouped: [String: [UNNotificationRequest]] = [:]
            for notification in medNotifications {
                let components = notification.identifier.split(separator: "_")
                if let medicationId = components.first {
                    let id = String(medicationId)
                    grouped[id, default: []].append(notification)
                }
            }

            // Sort each group by next trigger date
            groupedNotifications = grouped.map { (key, value) in
                let sorted = value.sorted { n1, n2 in
                    if let t1 = n1.trigger as? UNCalendarNotificationTrigger,
                       let t2 = n2.trigger as? UNCalendarNotificationTrigger,
                       let d1 = t1.nextTriggerDate(),
                       let d2 = t2.nextTriggerDate() {
                        return d1 < d2
                    }
                    return false
                }
                return (medicationId: key, notifications: sorted)
            }.sorted { $0.notifications.first?.content.title ?? "" < $1.notifications.first?.content.title ?? "" }

            totalCount = medNotifications.count
        }
    }
}

struct WaterDetailsSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var notifications: [UNNotificationRequest] = []

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 24))
                                .foregroundColor(themeManager.currentTheme.primaryColor)

                            Text("Water Slots")
                                .font(themeManager.currentTheme.font(for: .title2))
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                        }

                        Text("\(notifications.count) reminders scheduled")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
                    }
                }
                .padding()
                .background(.ultraThinMaterial)

                // Description banner
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                        Text("Daily Hydration Reminders")
                            .font(themeManager.currentTheme.font(for: .subheadline))
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                            .fontWeight(.semibold)
                    }

                    Text("Water reminders scheduled based on your hydration settings. These repeat daily at configured times and use your current theme's message.")
                        .font(themeManager.currentTheme.font(for: .caption))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.currentTheme.primaryColor.opacity(0.8))

                        Text("These automatically refresh with Daily Refresh (every ~24h) to update with your latest theme and settings.")
                            .font(themeManager.currentTheme.font(for: .caption2))
                            .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.currentTheme.primaryColor.opacity(0.1))

                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        if notifications.isEmpty {
                            VStack(spacing: Spacing.md) {
                                Image(systemName: "drop.triangle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.3))
                                    .padding(.top, 60)

                                Text("No Water Reminders")
                                    .font(themeManager.currentTheme.font(for: .headline))
                                    .foregroundColor(themeManager.currentTheme.textPrimary)

                                Text("Enable hydration reminders from Settings to stay hydrated")
                                    .font(themeManager.currentTheme.font(for: .caption))
                                    .foregroundColor(themeManager.currentTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        } else {
                            ForEach(Array(notifications.enumerated()), id: \.offset) { index, notification in
                                HStack(spacing: Spacing.md) {
                                    ZStack {
                                        Circle()
                                            .fill(themeManager.currentTheme.primaryColor.opacity(0.2))
                                            .frame(width: 50, height: 50)

                                        Image(systemName: "water.waves")
                                            .font(.system(size: 20))
                                            .foregroundColor(themeManager.currentTheme.primaryColor)
                                    }

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(notification.content.title)
                                            .font(themeManager.currentTheme.font(for: .body))
                                            .foregroundColor(themeManager.currentTheme.textPrimary)
                                            .fontWeight(.semibold)

                                        if let trigger = notification.trigger as? UNCalendarNotificationTrigger,
                                           let hour = trigger.dateComponents.hour {
                                            HStack(spacing: 4) {
                                                Image(systemName: "clock.fill")
                                                    .font(.system(size: 12))
                                                Text("Daily at \(String(format: "%02d:00", hour))")
                                                    .font(themeManager.currentTheme.font(for: .caption))
                                            }
                                            .foregroundColor(themeManager.currentTheme.textSecondary)
                                        }

                                        Text(notification.content.body)
                                            .font(themeManager.currentTheme.font(for: .caption2))
                                            .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.7))
                                            .lineLimit(2)
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(themeManager.currentTheme.primaryColor.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            loadNotifications()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Refresh when app becomes active (after theme change, etc.)
                loadNotifications()
            }
        }
    }

    private func loadNotifications() {
        Task {
            let center = UNUserNotificationCenter.current()
            let requests = await center.pendingNotificationRequests()

            notifications = requests.filter {
                $0.identifier.contains("water_reminder") && !$0.identifier.contains("reschedule")
            }
        }
    }
}

struct RescheduleDetailsSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var notifications: [UNNotificationRequest] = []

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 24))
                                .foregroundColor(themeManager.currentTheme.warningColor)

                            Text("Reschedule Slots")
                                .font(themeManager.currentTheme.font(for: .title2))
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                        }

                        Text("\(notifications.count) failsafe reminders")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
                    }
                }
                .padding()
                .background(.ultraThinMaterial)

                // Description banner
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "shield.checkered")
                            .foregroundColor(themeManager.currentTheme.warningColor)
                        Text("Failsafe Backup System")
                            .font(themeManager.currentTheme.font(for: .subheadline))
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                            .fontWeight(.semibold)
                    }

                    Text("These reminders only fire if Daily Refresh and Deep Clean BGTasks fail to run automatically. They prompt you to manually refresh notifications as a backup.")
                        .font(themeManager.currentTheme.font(for: .caption))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)

                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.currentTheme.successColor.opacity(0.8))

                        Text("If BGTasks work properly (Daily ~24h, Weekly ~7d), these reschedule reminders get automatically cancelled and won't bother you.")
                            .font(themeManager.currentTheme.font(for: .caption2))
                            .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.top, 4)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(themeManager.currentTheme.warningColor.opacity(0.1))

                ScrollView {
                    LazyVStack(spacing: Spacing.md) {
                        if notifications.isEmpty {
                            VStack(spacing: Spacing.md) {
                                Image(systemName: "checkmark.shield.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(themeManager.currentTheme.successColor.opacity(0.5))
                                    .padding(.top, 60)

                                Text("No Failsafe Needed")
                                    .font(themeManager.currentTheme.font(for: .headline))
                                    .foregroundColor(themeManager.currentTheme.textPrimary)

                                Text("BGTasks are handling rescheduling automatically")
                                    .font(themeManager.currentTheme.font(for: .caption))
                                    .foregroundColor(themeManager.currentTheme.textSecondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)
                            }
                        } else {
                            ForEach(Array(notifications.enumerated()), id: \.offset) { index, notification in
                                HStack(spacing: Spacing.md) {
                                    ZStack {
                                        Circle()
                                            .fill(themeManager.currentTheme.warningColor.opacity(0.2))
                                            .frame(width: 50, height: 50)

                                        Image(systemName: "bell.badge.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(themeManager.currentTheme.warningColor)
                                    }

                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(notification.content.title)
                                            .font(themeManager.currentTheme.font(for: .body))
                                            .foregroundColor(themeManager.currentTheme.textPrimary)
                                            .fontWeight(.semibold)

                                        if let trigger = notification.trigger as? UNTimeIntervalNotificationTrigger,
                                           let nextDate = trigger.nextTriggerDate() {
                                            HStack(spacing: 4) {
                                                Image(systemName: "calendar.badge.clock")
                                                    .font(.system(size: 12))
                                                Text(nextDate.formatted(date: .abbreviated, time: .shortened))
                                                    .font(themeManager.currentTheme.font(for: .caption))
                                            }
                                            .foregroundColor(themeManager.currentTheme.textSecondary)
                                        }

                                        Text(notification.content.body)
                                            .font(themeManager.currentTheme.font(for: .caption2))
                                            .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.7))
                                            .lineLimit(2)
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(themeManager.currentTheme.warningColor.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            loadNotifications()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active {
                // Refresh when app becomes active (after theme change, etc.)
                loadNotifications()
            }
        }
    }

    private func loadNotifications() {
        Task {
            let center = UNUserNotificationCenter.current()
            let requests = await center.pendingNotificationRequests()

            notifications = requests.filter {
                $0.identifier.contains("reschedule")
            }
        }
    }
}

struct BGTaskDetailsSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Custom Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Image(systemName: "gearshape.2.fill")
                                .font(.system(size: 24))
                                .foregroundColor(themeManager.currentTheme.primaryColor)

                            Text("Background Tasks")
                                .font(themeManager.currentTheme.font(for: .title2))
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                        }

                        Text("Automatic notification management")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }

                    Spacer()

                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
                    }
                }
                .padding()
                .background(.ultraThinMaterial)

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Daily Refresh Card
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack(spacing: Spacing.sm) {
                                ZStack {
                                    Circle()
                                        .fill(themeManager.currentTheme.primaryColor.opacity(0.2))
                                        .frame(width: 50, height: 50)

                                    Image(systemName: "arrow.clockwise.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(themeManager.currentTheme.primaryColor)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Refresh")
                                        .font(themeManager.currentTheme.font(for: .title3))
                                        .foregroundColor(themeManager.currentTheme.textPrimary)
                                        .fontWeight(.semibold)

                                    Text("Runs ~every 24 hours")
                                        .font(themeManager.currentTheme.font(for: .caption))
                                        .foregroundColor(themeManager.currentTheme.textSecondary)
                                }
                            }

                            Divider().background(Color.white.opacity(0.1))

                            VStack(alignment: .leading, spacing: 8) {
                                FeatureRow(icon: "clock.fill", text: "30 seconds to complete", color: themeManager.currentTheme.primaryColor)
                                FeatureRow(icon: "pills.fill", text: "Reschedules medications nearing end of cycle", color: themeManager.currentTheme.primaryColor)
                                FeatureRow(icon: "water.waves", text: "Refreshes water reminders with latest theme", color: themeManager.currentTheme.primaryColor)
                                FeatureRow(icon: "trash.fill", text: "Cleans up expired notifications", color: themeManager.currentTheme.primaryColor)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(themeManager.currentTheme.primaryColor.opacity(0.3), lineWidth: 1)
                                )
                        )

                        // Deep Clean Card
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack(spacing: Spacing.sm) {
                                ZStack {
                                    Circle()
                                        .fill(themeManager.currentTheme.warningColor.opacity(0.2))
                                        .frame(width: 50, height: 50)

                                    Image(systemName: "gearshape.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(themeManager.currentTheme.warningColor)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Deep Clean")
                                        .font(themeManager.currentTheme.font(for: .title3))
                                        .foregroundColor(themeManager.currentTheme.textPrimary)
                                        .fontWeight(.semibold)

                                    Text("Runs ~every 7 days")
                                        .font(themeManager.currentTheme.font(for: .caption))
                                        .foregroundColor(themeManager.currentTheme.textSecondary)
                                }
                            }

                            Divider().background(Color.white.opacity(0.1))

                            VStack(alignment: .leading, spacing: 8) {
                                FeatureRow(icon: "clock.fill", text: "Several minutes to complete", color: themeManager.currentTheme.warningColor)
                                FeatureRow(icon: "sparkles", text: "Comprehensive notification cleanup", color: themeManager.currentTheme.warningColor)
                                FeatureRow(icon: "arrow.triangle.2.circlepath", text: "Reschedules all medications and water", color: themeManager.currentTheme.warningColor)
                                FeatureRow(icon: "chart.bar.fill", text: "Optimizes notification budget usage", color: themeManager.currentTheme.warningColor)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(themeManager.currentTheme.warningColor.opacity(0.3), lineWidth: 1)
                                )
                        )

                        // How It Works Section
                        VStack(alignment: .leading, spacing: Spacing.md) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                Text("How It Works")
                                    .font(themeManager.currentTheme.font(for: .headline))
                                    .foregroundColor(themeManager.currentTheme.textPrimary)
                            }

                            Text("BGTasks are iOS background tasks that run automatically when your device is idle, charging, or has good battery. They keep your notifications fresh without requiring you to open the app.")
                                .font(themeManager.currentTheme.font(for: .body))
                                .foregroundColor(themeManager.currentTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 8) {
                                Image(systemName: "shield.checkered")
                                    .foregroundColor(themeManager.currentTheme.warningColor)

                                Text("If BGTasks fail to run, the app has failsafe reschedule reminders as backup to ensure you never miss a ritual.")
                                    .font(themeManager.currentTheme.font(for: .body))
                                    .foregroundColor(themeManager.currentTheme.textSecondary)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .padding()
                            .background(themeManager.currentTheme.warningColor.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                        )
                    }
                    .padding()
                }
            }
        }
    }
}

struct FeatureRow: View {
    @Environment(ThemeManager.self) private var themeManager
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color.opacity(0.8))
                .frame(width: 20)

            Text(text)
                .font(themeManager.currentTheme.font(for: .caption))
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

struct NotificationTypeCard: View {
    @Environment(ThemeManager.self) private var themeManager

    let icon: String
    let label: String
    let count: Int
    let color: Color

    var body: some View {
        VStack(spacing: Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)

            Text("\(count)")
                .font(themeManager.currentTheme.font(for: .title3))
                .foregroundColor(themeManager.currentTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text(label)
                .font(themeManager.currentTheme.font(for: .caption2))
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
}

#Preview {
    NotificationStatusSection()
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
