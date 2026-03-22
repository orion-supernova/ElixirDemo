//
//  SmallWidgetView.swift
//  ElixirWidget
//
//  2×2 home screen widget — character + state + quick stat.
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    let entry: ElixirWidgetEntry

    private var state: WidgetState { entry.widgetState }
    private var summary: WidgetDoseSummary { entry.summary }

    var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 6) {
                Spacer(minLength: 0)
                ElixirCharacterView(state: state, size: 54)
                stateLabel
                statBadge
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .widgetURL(URL(string: WidgetConstants.deepLinkDashboard))
    }

    // MARK: - Subviews

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

    @ViewBuilder
    private var stateLabel: some View {
        Text(state.stateLabel)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(stateLabelColor)
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.8)
    }

    @ViewBuilder
    private var statBadge: some View {
        if !summary.isEmpty {
            HStack(spacing: 3) {
                Image(systemName: statIcon)
                    .font(.system(size: 9, weight: .semibold))
                Text(statText)
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(statBadgeColor.opacity(0.85))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(statBadgeColor.opacity(0.15))
            )
        }
    }

    // MARK: - Computed

    private var stateLabelColor: Color {
        switch state {
        case .allDone:   return Color(hex: "4ADE80")
        case .upcoming:  return Color(hex: "FDE68A")
        case .overdue:   return Color(hex: "F87171")
        case .empty:     return Color(hex: "94A3B8")
        }
    }

    private var statBadgeColor: Color {
        switch state {
        case .allDone:   return Color(hex: "4ADE80")
        case .upcoming:  return Color(hex: "FACC15")
        case .overdue:   return Color(hex: "F87171")
        case .empty:     return Color(hex: "94A3B8")
        }
    }

    private var statIcon: String {
        switch state {
        case .allDone:   return "checkmark.circle.fill"
        case .upcoming:  return "clock.fill"
        case .overdue:   return "exclamationmark.circle.fill"
        case .empty:     return "moon.zzz.fill"
        }
    }

    private var statText: String {
        switch state {
        case .allDone:
            return "\(summary.takenToday)/\(summary.totalToday)"
        case .upcoming(_, let secs):
            if secs < 60 { return "Now" }
            let mins = Int(secs / 60)
            return mins < 60 ? "In \(mins)m" : "In \(mins / 60)h"
        case .overdue(let count):
            return "\(count) missed"
        case .empty:
            return "Rest day"
        }
    }
}

// MARK: - Previews

#Preview("Small – All Done", as: .systemSmall) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry(date: .now, summary: .allDone, widgetState: .allDone)
}

#Preview("Small – Upcoming", as: .systemSmall) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry(date: .now, summary: .placeholder, widgetState: .upcoming(nextDoseName: "Omega-3", secondsUntil: 2700))
}

#Preview("Small – Overdue", as: .systemSmall) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry(date: .now, summary: .overdue, widgetState: .overdue(count: 2))
}

#Preview("Small – Empty", as: .systemSmall) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry(date: .now, summary: .empty, widgetState: .empty)
}
