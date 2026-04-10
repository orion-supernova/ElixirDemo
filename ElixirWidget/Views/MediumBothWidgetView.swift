//
//  MediumBothWidgetView.swift
//  ElixirWidget
//
//  4x2 "Both" mode — medication status left, water progress right.
//

import SwiftUI
import WidgetKit

struct MediumBothWidgetView: View {
    let entry: ElixirWidgetEntry

    private var doseSummary: WidgetDoseSummary { entry.doseSummary }
    private var doseState: WidgetState { entry.widgetState }
    private var waterSummary: WidgetWaterSummary { entry.waterSummary }
    private var hydrationState: WaterHydrationState { entry.hydrationState }
    private var celebrating: Bool { entry.isCelebrating }

    var body: some View {
        ZStack {
            backgroundView
            HStack(spacing: 0) {
                medicationSide
                    .frame(maxWidth: .infinity)

                Divider()
                    .frame(height: 80)
                    .overlay(Color.white.opacity(0.1))

                waterSide
                    .frame(maxWidth: .infinity)
            }
            .padding(12)
        }
        .widgetURL(URL(string: WidgetConstants.deepLinkDashboard))
    }

    // MARK: - Medication Side

    @ViewBuilder
    private var medicationSide: some View {
        VStack(spacing: 5) {
            ElixirCharacterView(state: doseState, size: 44)

            Text(doseState.stateLabel)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(medColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if !doseSummary.isEmpty {
                medProgressBar
                Text("\(doseSummary.takenToday)/\(doseSummary.totalToday) doses")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.5))
            }
        }
    }

    @ViewBuilder
    private var medProgressBar: some View {
        let progress = doseSummary.totalToday > 0
            ? Double(doseSummary.takenToday) / Double(doseSummary.totalToday)
            : 0
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 3)
                Capsule()
                    .fill(medColor)
                    .frame(width: geo.size.width * progress, height: 3)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, 8)
    }

    // MARK: - Water Side

    private var activeWaterColor: Color { celebrating ? Color(hex: "4ADE80") : waterColor }

    @ViewBuilder
    private var waterSide: some View {
        VStack(spacing: 5) {
            WaterDropletCharacterView(state: hydrationState, size: 44, celebrating: celebrating)

            Text(celebrating ? (waterSummary.progress >= 1.0 ? "Well done!" : "Nice sip!") : hydrationState.stateLabel)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(activeWaterColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            if waterSummary.goalMl > 0 {
                waterProgressBar
                if celebrating, let amount = entry.lastDrinkAmountMl {
                    Text("+\(amount) ml")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(activeWaterColor.opacity(0.7))
                } else {
                    Text("\(waterSummary.totalIntakeMl)/\(waterSummary.goalMl) ml")
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.5))
                }
            }
        }
    }

    @ViewBuilder
    private var waterProgressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 3)
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "3B82F6"), Color(hex: "22D3EE")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * waterSummary.progress, height: 3)
            }
        }
        .frame(height: 3)
        .padding(.horizontal, 8)
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

    // MARK: - Colors

    private var medColor: Color {
        switch doseState {
        case .allDone:   return Color(hex: "4ADE80")
        case .upcoming:  return Color(hex: "FDE68A")
        case .overdue:   return Color(hex: "F87171")
        case .empty:     return Color(hex: "94A3B8")
        }
    }

    private var waterColor: Color {
        switch hydrationState {
        case .dehydrated:    return Color(hex: "F87171")
        case .thirsty:       return Color(hex: "FDE68A")
        case .hydrating:     return Color(hex: "60A5FA")
        case .fullyHydrated: return Color(hex: "4ADE80")
        case .empty:         return Color(hex: "94A3B8")
        }
    }
}

// MARK: - Previews

#Preview("Medium Both – Mixed", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.both(doseSummary: .placeholder, widgetState: .upcoming(nextDoseName: "Omega-3", dueDate: .now.addingTimeInterval(2700)), waterSummary: .placeholder, hydrationState: .hydrating)
}

#Preview("Medium Both – All Good", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.both(doseSummary: .allDone, widgetState: .allDone, waterSummary: .fullyHydrated, hydrationState: .fullyHydrated)
}
