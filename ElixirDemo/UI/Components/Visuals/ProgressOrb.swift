//
//  ProgressOrb.swift
//  Elixir: Daily Ritual
//
//  Central progress visualization component
//

import SwiftUI

struct ProgressOrb: View {
    let progress: Double // 0.0 to 1.0
    let totalDoses: Int
    let takenDoses: Int
    let size: CGFloat

    @State private var animatedProgress: Double = 0

    init(
        progress: Double,
        totalDoses: Int,
        takenDoses: Int,
        size: CGFloat = 220
    ) {
        self.progress = min(max(progress, 0), 1) // Clamp between 0 and 1
        self.totalDoses = totalDoses
        self.takenDoses = takenDoses
        self.size = size
    }

    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 16
                )
                .frame(width: size, height: size)

            // Animated Progress Ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color.elixirGradient,
                    style: StrokeStyle(
                        lineWidth: 16,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .shadow(
                    color: Color.potionPurple.opacity(0.6),
                    radius: 12,
                    x: 0,
                    y: 6
                )

            // Inner Content
            VStack(spacing: Spacing.sm) {
                // Completion Icon
                if progress >= 1.0 {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.healingGreen)
                        .symbolEffect(.bounce, value: progress)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 32))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.potionPurple, Color.manaBlue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                // Progress Percentage
                Text("\(Int(progress * 100))%")
                    .ritualFont(.ritualLargeTitle)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.potionPurple, Color.manaBlue],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Dose Count
                Text("\(takenDoses)/\(totalDoses)")
                    .ritualFont(.ritualCallout)
                    .foregroundColor(.secondary)

                Text("Elixirs")
                    .ritualFont(.ritualCaption)
                    .foregroundColor(.secondary.opacity(0.7))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.ritualSpring) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Preview
#Preview("Partial Progress") {
    ZStack {
        ThemeManager.shared.currentTheme.backgroundGradient.ignoresSafeArea()

        ProgressOrb(
            progress: 0.6,
            totalDoses: 5,
            takenDoses: 3
        )
    }
    .environment(ThemeManager.shared)
}

#Preview("Complete Progress") {
    ZStack {
        ThemeManager.shared.currentTheme.backgroundGradient.ignoresSafeArea()

        ProgressOrb(
            progress: 1.0,
            totalDoses: 4,
            takenDoses: 4
        )
    }
    .environment(ThemeManager.shared)
}

#Preview("Zero Progress") {
    ZStack {
        ThemeManager.shared.currentTheme.backgroundGradient.ignoresSafeArea()

        ProgressOrb(
            progress: 0.0,
            totalDoses: 3,
            takenDoses: 0
        )
    }
    .environment(ThemeManager.shared)
}
