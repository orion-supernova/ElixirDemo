//
//  SmallWaterWidgetView.swift
//  ElixirWidget
//
//  2x2 home screen widget — water droplet character + hydration progress.
//

import SwiftUI
import WidgetKit

struct SmallWaterWidgetView: View {
    let entry: ElixirWidgetEntry

    private var state: WaterHydrationState { entry.hydrationState }
    private var summary: WidgetWaterSummary { entry.waterSummary }
    private var celebrating: Bool { entry.isCelebrating }

    var body: some View {
        ZStack {
            backgroundView
            VStack(spacing: 6) {
                Spacer(minLength: 0)
                WaterDropletCharacterView(state: state, size: 54, celebrating: celebrating)
                percentageLabel
                stateLabel
                statBadge
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
        }
        .widgetURL(URL(string: WidgetConstants.deepLinkWater))
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
    private var percentageLabel: some View {
        Text("\(Int(summary.progress * 100))%")
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(activeColor)
    }

    @ViewBuilder
    private var stateLabel: some View {
        Text(celebrating ? celebrationLabel : state.stateLabel)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(activeColor)
            .multilineTextAlignment(.center)
            .lineLimit(1)
            .minimumScaleFactor(0.8)
    }

    @ViewBuilder
    private var statBadge: some View {
        if celebrating, let amount = entry.lastDrinkAmountMl {
            HStack(spacing: 3) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 9, weight: .semibold))
                Text("+\(amount) ml")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            .foregroundStyle(celebrationColor.opacity(0.85))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(celebrationColor.opacity(0.15))
            )
        } else if summary.goalMl > 0 {
            HStack(spacing: 3) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 9, weight: .semibold))
                Text("\(summary.totalIntakeMl) / \(summary.goalMl) ml")
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            .foregroundStyle(stateColor.opacity(0.85))
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(
                Capsule()
                    .fill(stateColor.opacity(0.15))
            )
        }
    }

    // MARK: - Computed

    private var celebrationColor: Color { Color(hex: "4ADE80") }

    private var activeColor: Color { celebrating ? celebrationColor : stateColor }

    private var celebrationLabel: String {
        summary.progress >= 1.0 ? "Well done!" : "Nice sip!"
    }

    private var stateColor: Color {
        switch state {
        case .dehydrated:    return Color(hex: "F87171")
        case .thirsty:       return Color(hex: "FDE68A")
        case .hydrating:     return Color(hex: "60A5FA")
        case .fullyHydrated: return Color(hex: "4ADE80")
        case .empty:         return Color(hex: "94A3B8")
        }
    }
}

// MARK: - Previews

#Preview("Small Water – Hydrating", as: .systemSmall) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .placeholder, state: .hydrating)
}

#Preview("Small Water – Fully Hydrated", as: .systemSmall) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .fullyHydrated, state: .fullyHydrated)
}

#Preview("Small Water – Dehydrated", as: .systemSmall) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .dehydrated, state: .dehydrated)
}

#Preview("Small Water – Empty", as: .systemSmall) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .empty, state: .empty)
}
