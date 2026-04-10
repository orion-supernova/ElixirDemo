//
//  LargeBothWidgetView.swift
//  ElixirWidget
//
//  4x4 "Both" mode — medication section top, water section bottom.
//

import SwiftUI
import WidgetKit

struct LargeBothWidgetView: View {
    let entry: ElixirWidgetEntry

    private var doseSummary: WidgetDoseSummary { entry.doseSummary }
    private var doseState: WidgetState { entry.widgetState }
    private var waterSummary: WidgetWaterSummary { entry.waterSummary }
    private var hydrationState: WaterHydrationState { entry.hydrationState }
    private var celebrating: Bool { entry.isCelebrating }

    var body: some View {
        ZStack {
            backgroundView
            VStack(alignment: .leading, spacing: 0) {
                medicationSection
                divider
                    .padding(.vertical, 10)
                waterSection
                Spacer(minLength: 0)
            }
            .padding(16)
        }
        .widgetURL(URL(string: WidgetConstants.deepLinkDashboard))
    }

    // MARK: - Medication Section

    @ViewBuilder
    private var medicationSection: some View {
        HStack(alignment: .center, spacing: 12) {
            ElixirCharacterView(state: doseState, size: 60)

            VStack(alignment: .leading, spacing: 6) {
                Text(doseState.stateLabel)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(medColor)
                    .lineLimit(1)

                if !doseSummary.isEmpty {
                    HStack(spacing: 8) {
                        miniMedRing
                        VStack(alignment: .leading, spacing: 1) {
                            Text("\(doseSummary.takenToday) of \(doseSummary.totalToday) taken")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.8))
                            if doseSummary.overdueCount > 0 {
                                Text("\(doseSummary.overdueCount) overdue")
                                    .font(.system(size: 10, design: .rounded))
                                    .foregroundStyle(Color(hex: "F87171"))
                            } else if doseSummary.pendingToday > 0 {
                                Text("\(doseSummary.pendingToday) upcoming")
                                    .font(.system(size: 10, design: .rounded))
                                    .foregroundStyle(Color(hex: "FDE68A").opacity(0.8))
                            }
                        }
                    }
                }

                // Top 2 dose items
                doseItemList
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var miniMedRing: some View {
        let progress = doseSummary.totalToday > 0
            ? Double(doseSummary.takenToday) / Double(doseSummary.totalToday)
            : 0
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 4)
                .frame(width: 32, height: 32)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(medColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .frame(width: 32, height: 32)
                .rotationEffect(.degrees(-90))
            Text("\(Int(progress * 100))%")
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.9))
        }
    }

    @ViewBuilder
    private var doseItemList: some View {
        let items = doseSummary.todayDoseItems.prefix(2)
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 3) {
                ForEach(items) { item in
                    HStack(spacing: 5) {
                        Circle()
                            .fill(doseStatusColor(item.status))
                            .frame(width: 5, height: 5)
                        Image(systemName: item.iconName)
                            .font(.system(size: 8))
                            .foregroundStyle(Color(hex: item.colorHex).opacity(0.9))
                            .frame(width: 10)
                        Text(item.medicationName)
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(item.status == WidgetDoseStatus.taken.rawValue ? 0.5 : 0.85))
                            .lineLimit(1)
                    }
                }
            }
            .padding(.top, 2)
        }
    }

    // MARK: - Water Section

    private var activeWaterColor: Color { celebrating ? Color(hex: "4ADE80") : waterColor }

    @ViewBuilder
    private var waterSection: some View {
        HStack(alignment: .center, spacing: 12) {
            WaterDropletCharacterView(state: hydrationState, size: 60, celebrating: celebrating)

            VStack(alignment: .leading, spacing: 6) {
                Text(celebrating ? (waterSummary.progress >= 1.0 ? "Well done!" : "Nice sip!") : hydrationState.stateLabel)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(activeWaterColor)
                    .lineLimit(1)

                if waterSummary.goalMl > 0 {
                    HStack(spacing: 8) {
                        miniWaterRing
                        VStack(alignment: .leading, spacing: 1) {
                            Text("\(waterSummary.totalIntakeMl) of \(waterSummary.goalMl) ml")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.8))
                            if waterSummary.streak > 0 {
                                Text("\(waterSummary.streak) day streak")
                                    .font(.system(size: 10, design: .rounded))
                                    .foregroundStyle(Color(hex: "22D3EE").opacity(0.8))
                            }
                        }
                    }

                    // Recent entries
                    waterEntryList
                }
            }
            Spacer(minLength: 0)
        }
    }

    @ViewBuilder
    private var miniWaterRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 4)
                .frame(width: 32, height: 32)
            Circle()
                .trim(from: 0, to: waterSummary.progress)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "3B82F6"), Color(hex: "22D3EE")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .frame(width: 32, height: 32)
                .rotationEffect(.degrees(-90))
            Text("\(Int(waterSummary.progress * 100))%")
                .font(.system(size: 8, weight: .bold, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.9))
        }
    }

    @ViewBuilder
    private var waterEntryList: some View {
        let items = waterSummary.recentEntries.prefix(2)
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 3) {
                ForEach(items) { item in
                    HStack(spacing: 5) {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(Color(hex: "60A5FA").opacity(0.8))
                            .frame(width: 10)
                        Text("+\(item.amountMl) ml")
                            .font(.system(size: 10, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.85))
                        Text(formattedTime(item.date))
                            .font(.system(size: 9, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.35))
                    }
                }
            }
            .padding(.top, 2)
        }
    }

    // MARK: - Common

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

    private func doseStatusColor(_ status: String) -> Color {
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
}

// MARK: - Previews

#Preview("Large Both – Mixed", as: .systemLarge) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.both(doseSummary: .placeholder, widgetState: .upcoming(nextDoseName: "Omega-3", dueDate: .now.addingTimeInterval(2700)), waterSummary: .placeholder, hydrationState: .hydrating)
}

#Preview("Large Both – All Good", as: .systemLarge) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.both(doseSummary: .allDone, widgetState: .allDone, waterSummary: .fullyHydrated, hydrationState: .fullyHydrated)
}
