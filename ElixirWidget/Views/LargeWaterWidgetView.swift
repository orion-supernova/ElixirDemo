//
//  LargeWaterWidgetView.swift
//  ElixirWidget
//
//  4x4 home screen widget — full hydration overview with character,
//  progress ring, and recent intake entries.
//

import SwiftUI
import WidgetKit

struct LargeWaterWidgetView: View {
    let entry: ElixirWidgetEntry

    private var state: WaterHydrationState { entry.hydrationState }
    private var summary: WidgetWaterSummary { entry.waterSummary }
    private var celebrating: Bool { entry.isCelebrating }

    var body: some View {
        ZStack {
            backgroundView
            VStack(alignment: .leading, spacing: 0) {
                headerSection
                    .padding(.bottom, 12)

                if !summary.recentEntries.isEmpty {
                    divider
                        .padding(.bottom, 10)
                    intakeList
                }

                Spacer(minLength: 0)
                footerView
            }
            .padding(16)
        }
        .widgetURL(URL(string: WidgetConstants.deepLinkWater))
    }

    // MARK: - Header

    @ViewBuilder
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 14) {
            WaterDropletCharacterView(state: state, size: 80, celebrating: celebrating)

            VStack(alignment: .leading, spacing: 8) {
                Text(celebrating ? celebrationLabel : state.stateLabel)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(activeColor)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                if summary.goalMl > 0 {
                    HStack(spacing: 10) {
                        miniProgressRing
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(summary.totalIntakeMl) of \(summary.goalMl) ml")
                                .font(.system(size: 12, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.8))
                            if summary.streak > 0 {
                                Text("\(summary.streak) day streak")
                                    .font(.system(size: 11, design: .rounded))
                                    .foregroundStyle(Color(hex: "22D3EE").opacity(0.8))
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
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 5)
                .frame(width: 40, height: 40)
            Circle()
                .trim(from: 0, to: summary.progress)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "3B82F6"), Color(hex: "22D3EE")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 5, lineCap: .round)
                )
                .frame(width: 40, height: 40)
                .rotationEffect(.degrees(-90))
            Text("\(Int(summary.progress * 100))%")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.9))
        }
    }

    // MARK: - Intake List

    @ViewBuilder
    private var intakeList: some View {
        let displayedItems = Array(summary.recentEntries.prefix(5))
        VStack(alignment: .leading, spacing: 0) {
            Text("TODAY'S INTAKE")
                .font(.system(size: 9, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.3))
                .tracking(1.2)
                .padding(.bottom, 7)

            ForEach(displayedItems) { item in
                intakeRow(item)
                if item.id != displayedItems.last?.id {
                    Color.white.opacity(0.06)
                        .frame(height: 1)
                        .padding(.vertical, 4)
                }
            }
        }
    }

    @ViewBuilder
    private func intakeRow(_ item: WidgetWaterEntryItem) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color(hex: "3B82F6").opacity(0.2))
                    .frame(width: 30, height: 30)
                Image(systemName: "drop.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(hex: "60A5FA"))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text("+\(item.amountMl) ml")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.92))
                    .lineLimit(1)
                Text(formattedTime(item.date))
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.35))
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 3)
    }

    // MARK: - Footer

    @ViewBuilder
    private var footerView: some View {
        HStack {
            Image(systemName: "drop.fill")
                .font(.system(size: 9))
            if let lastDrink = summary.lastDrinkTime {
                Text("Last drink \(relativeTimeString(lastDrink))")
                    .font(.system(size: 10, design: .rounded))
            } else {
                Text("No water logged today")
                    .font(.system(size: 10, design: .rounded))
            }
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

    private var celebrationColor: Color { Color(hex: "4ADE80") }
    private var activeColor: Color { celebrating ? celebrationColor : headlineColor }
    private var celebrationLabel: String { summary.progress >= 1.0 ? "Well done!" : "Nice sip!" }

    private var headlineColor: Color {
        switch state {
        case .dehydrated:    return Color(hex: "F87171")
        case .thirsty:       return Color(hex: "FDE68A")
        case .hydrating:     return Color(hex: "60A5FA")
        case .fullyHydrated: return Color(hex: "4ADE80")
        case .empty:         return Color(hex: "94A3B8")
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

#Preview("Large Water – Hydrating", as: .systemLarge) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .placeholder, state: .hydrating)
}

#Preview("Large Water – Fully Hydrated", as: .systemLarge) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .fullyHydrated, state: .fullyHydrated)
}

#Preview("Large Water – Dehydrated", as: .systemLarge) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .dehydrated, state: .dehydrated)
}

#Preview("Large Water – Empty", as: .systemLarge) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .empty, state: .empty)
}
