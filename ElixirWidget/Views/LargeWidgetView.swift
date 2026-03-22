//
//  LargeWidgetView.swift
//  ElixirWidget
//
//  4×4 home screen widget — full today's overview with character,
//  progress ring, and complete dose list.
//

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
    let entry: ElixirWidgetEntry

    private var state: WidgetState { entry.widgetState }
    private var summary: WidgetDoseSummary { entry.summary }

    var body: some View {
        ZStack {
            backgroundView
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.bottom, 12)

                if !summary.isEmpty {
                    divider
                        .padding(.bottom, 10)
                    doseList
                }

                Spacer(minLength: 0)
                footerView
            }
            .padding(16)
        }
        .widgetURL(URL(string: WidgetConstants.deepLinkDashboard))
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 14) {
            ElixirCharacterView(state: state, size: 80)

            VStack(alignment: .leading, spacing: 8) {
                // State headline
                Text(state.stateLabel)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(headlineColor)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if !summary.isEmpty {
                    // Inline progress ring + count
                    HStack(spacing: 10) {
                        miniProgressRing
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(summary.takenToday) of \(summary.totalToday) taken")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.8))
                            if summary.overdueCount > 0 {
                                Text("\(summary.overdueCount) overdue")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(Color(hex: "F87171"))
                            } else if summary.pendingToday > 0 {
                                Text("\(summary.pendingToday) upcoming")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(Color(hex: "FDE68A").opacity(0.8))
                            }
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var miniProgressRing: some View {
        let progress = summary.totalToday > 0
            ? Double(summary.takenToday) / Double(summary.totalToday)
            : 0
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 5)
                .frame(width: 40, height: 40)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    progressRingColor,
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.9))
        }
    }

    // MARK: - Dose List

    @ViewBuilder
    private var doseList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("TODAY'S DOSES")
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.3))
                .tracking(1.2)
                .padding(.bottom, 7)

            ForEach(summary.todayDoseItems) { item in
                largeDoseRow(item)
                if item.id != summary.todayDoseItems.last?.id {
                    Color.white.opacity(0.06)
                        .frame(height: 1)
                        .padding(.vertical, 4)
                }
            }
        }
    }

    @ViewBuilder
    private func largeDoseRow(_ item: WidgetDoseItem) -> some View {
        HStack(spacing: 10) {
            // Medication icon in colored circle
            ZStack {
                Circle()
                    .fill(Color(hex: item.colorHex).opacity(0.2))
                    .frame(width: 30, height: 30)
                Image(systemName: item.iconName)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: item.colorHex))
            }

            // Name + scheduled time
            VStack(alignment: .leading, spacing: 1) {
                Text(item.medicationName)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(item.status == "taken" ? 0.5 : 0.92))
                    .lineLimit(1)
                Text(formattedTime(item.scheduledTime))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.35))
            }

            Spacer(minLength: 0)

            // Status badge
            statusBadge(item.status)
        }
        .padding(.vertical, 3)
    }

    @ViewBuilder
    private func statusBadge(_ status: String) -> some View {
        HStack(spacing: 3) {
            Image(systemName: statusIcon(status))
                .font(.system(size: 10, weight: .semibold))
            Text(statusLabel(status))
                .font(.system(size: 10, weight: .semibold, design: .rounded))
        }
        .foregroundStyle(statusColor(status))
        .padding(.horizontal, 7)
        .padding(.vertical, 3)
        .background(
            Capsule()
                .fill(statusColor(status).opacity(0.15))
        )
    }

    // MARK: - Footer

    @ViewBuilder
    private var footerView: some View {
        HStack {
            Image(systemName: "clock")
                .font(.system(size: 9))
            Text("Updated \(relativeTimeString(entry.summary.lastUpdated))")
                .font(.system(size: 10, design: .rounded))
        }
        .foregroundStyle(Color.white.opacity(0.25))
        .padding(.top, 8)
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        ContainerRelativeShape()
            .fill(
                LinearGradient(
                    colors: [Color(hex: "0D1117"), Color(hex: "1E293B")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
    }

    @ViewBuilder
    private var divider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(height: 1)
    }

    // MARK: - Helpers

    private var headlineColor: Color {
        switch state {
        case .allDone:   return Color(hex: "4ADE80")
        case .upcoming:  return Color(hex: "FDE68A")
        case .overdue:   return Color(hex: "F87171")
        case .empty:     return Color(hex: "94A3B8")
        }
    }

    private var progressRingColor: Color {
        switch state {
        case .allDone:   return Color(hex: "4ADE80")
        case .upcoming:  return Color(hex: "FACC15")
        case .overdue:   return Color(hex: "F87171")
        case .empty:     return Color(hex: "64748B")
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "taken":   return Color(hex: "4ADE80")
        case "missed":  return Color(hex: "F87171")
        case "skipped": return Color(hex: "94A3B8")
        default:        return Color(hex: "FACC15")
        }
    }

    private func statusIcon(_ status: String) -> String {
        switch status {
        case "taken":   return "checkmark.circle.fill"
        case "missed":  return "xmark.circle.fill"
        case "skipped": return "minus.circle.fill"
        default:        return "clock.fill"
        }
    }

    private func statusLabel(_ status: String) -> String {
        switch status {
        case "taken":   return "Done"
        case "missed":  return "Missed"
        case "skipped": return "Skipped"
        default:        return "Pending"
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    private func relativeTimeString(_ date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 { return "just now" }
        let mins = Int(interval / 60)
        return mins < 60 ? "\(mins)m ago" : "\(mins / 60)h ago"
    }
}

// MARK: - Previews

#Preview("Large – All Done", as: .systemLarge) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry(date: .now, summary: .allDone, widgetState: .allDone)
}

#Preview("Large – Upcoming", as: .systemLarge) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry(date: .now, summary: .placeholder, widgetState: .upcoming(nextDoseName: "Omega-3", secondsUntil: 2700))
}

#Preview("Large – Overdue", as: .systemLarge) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry(date: .now, summary: .overdue, widgetState: .overdue(count: 2))
}

#Preview("Large – Empty", as: .systemLarge) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry(date: .now, summary: .empty, widgetState: .empty)
}
