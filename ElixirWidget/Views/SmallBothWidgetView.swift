//
//  SmallBothWidgetView.swift
//  ElixirWidget
//
//  2x2 "Both" mode — urgency-based smart priority.
//  Shows whichever needs attention most:
//  1. Overdue medication doses
//  2. Medication due within 30 minutes
//  3. Water overdue (past reminder interval)
//  4. Default: medication status
//

import SwiftUI
import WidgetKit

struct SmallBothWidgetView: View {
    let entry: ElixirWidgetEntry

    private var doseSummary: WidgetDoseSummary { entry.doseSummary }
    private var doseState: WidgetState { entry.widgetState }
    private var waterSummary: WidgetWaterSummary { entry.waterSummary }
    private var hydrationState: WaterHydrationState { entry.hydrationState }

    private var showWater: Bool {
        // Priority 1: Overdue medication → show medication
        if case .overdue = doseState { return false }

        // Priority 2: Medication due within 30 minutes → show medication
        if case .upcoming(_, let dueDate) = doseState,
           dueDate.timeIntervalSince(entry.date) <= 30 * 60 {
            return false
        }

        // Priority 3: No medication today → show water
        if case .empty = doseState { return true }

        // Priority 4: Water overdue → show water
        if waterSummary.isWaterOverdue(at: entry.date) { return true }

        // Priority 5: All meds done → show water
        if case .allDone = doseState { return true }

        // Priority 6: Default → medication (active pending doses)
        return false
    }

    var body: some View {
        ZStack {
            backgroundView
            if showWater {
                waterContent
            } else {
                medicationContent
            }
        }
        .widgetURL(URL(string: showWater ? WidgetConstants.deepLinkWater : WidgetConstants.deepLinkDashboard))
    }

    // MARK: - Medication Content

    @ViewBuilder
    private var medicationContent: some View {
        VStack(spacing: 5) {
            Spacer(minLength: 0)
            ElixirCharacterView(state: doseState, size: 46)

            Text(doseState.stateLabel)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(medColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            medBadge
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var medBadge: some View {
        if !doseSummary.isEmpty {
            HStack(spacing: 3) {
                Image(systemName: "pills.fill")
                    .font(.system(size: 8, weight: .semibold))
                Text("\(doseSummary.takenToday)/\(doseSummary.totalToday)")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            .foregroundStyle(medColor.opacity(0.85))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(medColor.opacity(0.15)))
        }
    }

    // MARK: - Water Content

    private var celebrating: Bool { entry.isCelebrating }
    private var activeWaterColor: Color { celebrating ? Color(hex: "4ADE80") : waterColor }

    @ViewBuilder
    private var waterContent: some View {
        VStack(spacing: 5) {
            Spacer(minLength: 0)
            WaterDropletCharacterView(state: hydrationState, size: 46, celebrating: celebrating)

            Text(celebrating ? (waterSummary.progress >= 1.0 ? "Well done!" : "Nice sip!") : hydrationState.stateLabel)
                .font(.system(size: 10, weight: .bold, design: .rounded))
                .foregroundStyle(activeWaterColor)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            waterBadge
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var waterBadge: some View {
        if celebrating, let amount = entry.lastDrinkAmountMl {
            HStack(spacing: 3) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 8, weight: .semibold))
                Text("+\(amount) ml")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            .foregroundStyle(activeWaterColor.opacity(0.85))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(activeWaterColor.opacity(0.15)))
        } else if waterSummary.goalMl > 0 {
            HStack(spacing: 3) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 8, weight: .semibold))
                Text("\(Int(waterSummary.progress * 100))%")
                    .font(.system(size: 9, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            .foregroundStyle(waterColor.opacity(0.85))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Capsule().fill(waterColor.opacity(0.15)))
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

#Preview("Small Both – Meds Priority", as: .systemSmall) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.both(doseSummary: .overdue, widgetState: .overdue(count: 2), waterSummary: .placeholder, hydrationState: .hydrating)
}

#Preview("Small Both – Water Priority", as: .systemSmall) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.both(doseSummary: .allDone, widgetState: .allDone, waterSummary: .dehydrated, hydrationState: .dehydrated)
}
