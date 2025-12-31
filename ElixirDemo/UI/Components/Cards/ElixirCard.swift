//
//  ElixirCard.swift
//  Elixir: Daily Ritual
//
//  High-end medication card component
//

import SwiftUI

struct ElixirCard: View {
    let medication: Medication
    let doseLog: DoseLog
    let onCheckmarkTapped: () -> Void

    @State private var isPressed = false

    var iconColor: Color {
        Color(hex: medication.colorHex)
    }

    var statusColor: Color {
        Color(hex: doseLog.status.color)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: doseLog.scheduledTime)
    }

    var body: some View {
        HStack(spacing: Spacing.md) {
            // Left: Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: medication.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(iconColor)
            }

            // Middle: Info
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .ritualFont(.ritualHeadline)
                    .foregroundColor(.white)

                HStack(spacing: Spacing.xs) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))

                    Text(formattedTime)
                        .ritualFont(.ritualSubheadline)
                        .foregroundColor(.white.opacity(0.7))

                    Text("•")
                        .foregroundColor(.white.opacity(0.5))

                    Text(medication.dosage)
                        .ritualFont(.ritualSubheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Spacer()

            // Right: Checkmark Button
            CheckmarkButton(
                status: doseLog.status,
                action: {
                    onCheckmarkTapped()
                }
            )
        }
        .padding(Spacing.md)
        .elixirCard(isPressed: isPressed)
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.ritualSpring) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.ritualSpring) {
                    isPressed = false
                }
            }
        }
    }
}

// MARK: - Checkmark Button Component
struct CheckmarkButton: View {
    let status: DoseStatus
    let action: () -> Void

    @State private var isPressed = false

    var buttonColor: Color {
        switch status {
        case .taken:
            return .healingGreen
        case .pending:
            return .potionPurple
        case .skipped:
            return .gray
        case .missed:
            return .phoenixRed
        }
    }

    var iconName: String {
        switch status {
        case .taken:
            return "checkmark.circle.fill"
        case .pending:
            return "circle"
        case .skipped:
            return "xmark.circle.fill"
        case .missed:
            return "exclamationmark.circle.fill"
        }
    }

    var body: some View {
        Button(action: {
            hapticFeedback(.medium)
            action()
        }) {
            ZStack {
                Circle()
                    .fill(buttonColor.opacity(0.15))
                    .frame(width: 48, height: 48)

                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(buttonColor)
                    .symbolEffect(.bounce, value: status)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Scale Button Style
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.ritualSpring, value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview("Pending Dose") {
    let medication = Medication(
        name: "Vitamin D",
        dosage: "1000 IU",
        iconName: "sun.max.fill",
        colorHex: "FBBF24"
    )

    let doseLog = DoseLog(
        scheduledTime: Date(),
        medication: medication,
        status: .pending
    )

    return ZStack {
        ThemeManager.shared.currentTheme.backgroundGradient.ignoresSafeArea()

        ElixirCard(
            medication: medication,
            doseLog: doseLog,
            onCheckmarkTapped: {}
        )
        .padding()
    }
    .environment(ThemeManager.shared)
}

#Preview("Taken Dose") {
    let medication = Medication(
        name: "Omega-3",
        dosage: "500mg",
        iconName: "drop.fill",
        colorHex: "60A5FA"
    )

    let doseLog = DoseLog(
        scheduledTime: Date(),
        medication: medication,
        status: .taken
    )

    return ZStack {
        ThemeManager.shared.currentTheme.backgroundGradient.ignoresSafeArea()

        ElixirCard(
            medication: medication,
            doseLog: doseLog,
            onCheckmarkTapped: {}
        )
        .padding()
    }
    .environment(ThemeManager.shared)
}

#Preview("Multiple Cards") {
    let meds = [
        (Medication(name: "Vitamin D", dosage: "1000 IU", iconName: "sun.max.fill", colorHex: "FBBF24"), DoseStatus.taken),
        (Medication(name: "Omega-3", dosage: "500mg", iconName: "drop.fill", colorHex: "60A5FA"), DoseStatus.pending),
        (Medication(name: "Aspirin", dosage: "81mg", iconName: "heart.fill", colorHex: "F87171"), DoseStatus.pending)
    ]

    return ZStack {
        ThemeManager.shared.currentTheme.backgroundGradient.ignoresSafeArea()

        ScrollView {
            VStack(spacing: Spacing.md) {
                ForEach(meds.indices, id: \.self) { index in
                    let (med, status) = meds[index]
                    let log = DoseLog(scheduledTime: Date(), medication: med, status: status)

                    ElixirCard(
                        medication: med,
                        doseLog: log,
                        onCheckmarkTapped: {}
                    )
                }
            }
            .padding()
        }
    }
    .environment(ThemeManager.shared)
}
