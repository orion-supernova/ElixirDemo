//
//  MediumWidgetView.swift
//  ElixirWidget
//
//  4×2 home screen widget — character on the left, dose list on the right.
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
    let entry: ElixirWidgetEntry

    private var state: WidgetState { entry.widgetState }
    private var summary: WidgetDoseSummary { entry.doseSummary }

    var body: some View {
        ZStack {
            backgroundView
            HStack(alignment: .center, spacing: 14) {
                characterColumn
                Divider()
                    .frame(height: 80)
                    .overlay(Color.white.opacity(0.1))
                infoColumn
                Spacer(minLength: 0)
            }
            .padding(14)
        }
        .widgetURL(URL(string: WidgetConstants.deepLinkDashboard))
    }

    // MARK: - Columns

    @ViewBuilder
    private var characterColumn: some View {
        VStack(spacing: 6) {
            ElixirCharacterView(state: state, size: 60)
            stateSubtitle
        }
        .frame(width: 76)
    }

    @ViewBuilder
    private var infoColumn: some View {
        VStack(alignment: .leading, spacing: 5) {
            // State headline
            Text(state.stateLabel)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(headlineColor)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            // Progress bar
            if !summary.isEmpty {
                progressBar
            }

            // Dose items
            doseItemList
        }
    }

    @ViewBuilder
    private var progressBar: some View {
        let progress = summary.totalToday > 0
            ? Double(summary.takenToday) / Double(summary.totalToday)
            : 0
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)
                Capsule()
                    .fill(progressBarColor)
                    .frame(width: geo.size.width * progress, height: 4)
            }
        }
        .frame(height: 4)
    }

    @ViewBuilder
    private var doseItemList: some View {
        let items = summary.todayDoseItems.prefix(3)
        VStack(alignment: .leading, spacing: 4) {
            ForEach(items) { item in
                doseRow(item)
            }
        }
    }

    @ViewBuilder
    private func doseRow(_ item: WidgetDoseItem) -> some View {
        HStack(spacing: 6) {
            // Status dot
            Circle()
                .fill(statusColor(item.status))
                .frame(width: 6, height: 6)

            // Medication icon
            Image(systemName: item.iconName)
                .font(.system(size: 9))
                .foregroundStyle(Color(hex: item.colorHex).opacity(0.9))
                .frame(width: 12)

            // Name
            Text(item.medicationName)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(item.status == WidgetDoseStatus.taken.rawValue ? 0.5 : 0.9))
                .lineLimit(1)

            Spacer(minLength: 0)

            // Time
            Text(formattedTime(item.scheduledTime))
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.4))
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var backgroundView: some View {
        ContainerRelativeShape()
            .fill(
                LinearGradient(
                    colors: [Color(hex: "0F172A"), Color(hex: "1E293B")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
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

    private var subLabelColor: Color {
        switch state {
        case .allDone:   return Color(hex: "4ADE80")
        case .upcoming:  return Color(hex: "FACC15")
        case .overdue:   return Color(hex: "F87171")
        case .empty:     return Color(hex: "94A3B8")
        }
    }

    private var progressBarColor: Color {
        switch state {
        case .allDone:   return Color(hex: "4ADE80")
        case .upcoming:  return Color(hex: "FACC15")
        case .overdue:   return Color(hex: "F87171")
        case .empty:     return Color(hex: "64748B")
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case WidgetDoseStatus.taken.rawValue:   return Color(hex: "4ADE80")
        case WidgetDoseStatus.missed.rawValue:  return Color(hex: "F87171")
        case WidgetDoseStatus.skipped.rawValue: return Color(hex: "94A3B8")
        default:                                return Color(hex: "FACC15")
        }
    }

    private func formattedTime(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        return f.string(from: date)
    }

    @ViewBuilder
    private var stateSubtitle: some View {
        switch state {
        case .allDone:
            subtitleText("Keep it up!")
        case .upcoming(_, let dueDate) where dueDate > entry.date:
            Text(dueDate, style: .timer)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(subLabelColor.opacity(0.8))
                .lineLimit(1)
        case .upcoming:
            subtitleText("Due now")
        case .overdue:
            subtitleText("Open the app")
        case .empty:
            subtitleText("Enjoy your day")
        }
    }

    private func subtitleText(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .medium, design: .rounded))
            .foregroundStyle(subLabelColor.opacity(0.8))
            .lineLimit(1)
    }
}

// MARK: - Previews

#Preview("Medium – All Done", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.medication(summary: .allDone, state: .allDone)
}

#Preview("Medium – Upcoming", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.medication(summary: .placeholder, state: .upcoming(nextDoseName: "Omega-3", dueDate: .now.addingTimeInterval(2700)))
}

#Preview("Medium – Overdue", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.medication(summary: .overdue, state: .overdue(count: 2))
}

#Preview("Medium – Empty", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.medication(summary: .empty, state: .empty)
}
