//
//  MediumWaterWidgetView.swift
//  ElixirWidget
//
//  4x2 home screen widget — water droplet on left, hydration stats on right.
//

import SwiftUI
import WidgetKit

struct MediumWaterWidgetView: View {
    let entry: ElixirWidgetEntry

    private var state: WaterHydrationState { entry.hydrationState }
    private var summary: WidgetWaterSummary { entry.waterSummary }
    private var celebrating: Bool { entry.isCelebrating }

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
        .widgetURL(URL(string: WidgetConstants.deepLinkWater))
    }

    // MARK: - Columns

    @ViewBuilder
    private var characterColumn: some View {
        VStack(spacing: 6) {
            WaterDropletCharacterView(state: state, size: 60, celebrating: celebrating)
            stateSubtitle
        }
        .frame(width: 76)
    }

    @ViewBuilder
    private var infoColumn: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(celebrating ? celebrationLabel : state.stateLabel)
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(activeColor)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            if summary.goalMl > 0 {
                progressBar
            }

            if celebrating, let amount = entry.lastDrinkAmountMl {
                Text("+\(amount) ml")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(celebrationColor.opacity(0.85))
            }

            HStack(spacing: 14) {
                statItem(value: "\(summary.totalIntakeMl)", label: "ml")
                statItem(value: "\(summary.goalMl)", label: "goal")
                if summary.streak > 0 {
                    statItem(value: "\(summary.streak)", label: "streak")
                }
            }
        }
    }

    @ViewBuilder
    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "3B82F6"), Color(hex: "22D3EE")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * summary.progress, height: 4)
            }
        }
        .frame(height: 4)
    }

    @ViewBuilder
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 1) {
            Text(value)
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(Color.white.opacity(0.9))
            Text(label)
                .font(.system(size: 9, weight: .medium, design: .rounded))
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

    private var subLabelColor: Color { headlineColor }

    @ViewBuilder
    private var stateSubtitle: some View {
        if summary.goalMl > 0 {
            Text("\(Int(summary.progress * 100))%")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(subLabelColor.opacity(0.8))
                .lineLimit(1)
        } else {
            Text("No goal set")
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(subLabelColor.opacity(0.8))
                .lineLimit(1)
        }
    }
}

// MARK: - Previews

#Preview("Medium Water – Hydrating", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .placeholder, state: .hydrating)
}

#Preview("Medium Water – Fully Hydrated", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .fullyHydrated, state: .fullyHydrated)
}

#Preview("Medium Water – Dehydrated", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .dehydrated, state: .dehydrated)
}

#Preview("Medium Water – Empty", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .empty, state: .empty)
}
