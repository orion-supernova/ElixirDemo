//
//  ElixirCharacterView.swift
//  ElixirWidget
//
//  The Elixir mascot — a Duolingo-style animated potion bottle character
//  whose face and decorations reflect today's medication adherence state.
//  Built entirely from SwiftUI shapes and SF Symbols. No image assets.
//

import SwiftUI
import WidgetKit

// MARK: - State Appearance

private extension WidgetState {
    var bodyGradient: LinearGradient {
        switch self {
        case .allDone:
            return LinearGradient(colors: [Color(hex: "2ECC71"), Color(hex: "1A9A50")], startPoint: .top, endPoint: .bottom)
        case .upcoming:
            return LinearGradient(colors: [Color(hex: "F5C518"), Color(hex: "E07B00")], startPoint: .top, endPoint: .bottom)
        case .overdue:
            return LinearGradient(colors: [Color(hex: "E74C3C"), Color(hex: "9B1C1C")], startPoint: .top, endPoint: .bottom)
        case .empty:
            return LinearGradient(colors: [Color(hex: "64748B"), Color(hex: "334155")], startPoint: .top, endPoint: .bottom)
        }
    }

    var liquidColor: Color {
        switch self {
        case .allDone:   return Color(hex: "16A34A").opacity(0.7)
        case .upcoming:  return Color(hex: "D97706").opacity(0.65)
        case .overdue:   return Color(hex: "B91C1C").opacity(0.7)
        case .empty:     return Color(hex: "475569").opacity(0.5)
        }
    }

    var glowColor: Color {
        switch self {
        case .allDone:   return Color(hex: "4ADE80")
        case .upcoming:  return Color(hex: "FACC15")
        case .overdue:   return Color(hex: "F87171")
        case .empty:     return Color(hex: "94A3B8")
        }
    }

    var liquidFill: CGFloat {
        switch self {
        case .allDone:   return 0.82
        case .upcoming:  return 0.55
        case .overdue:   return 0.18
        case .empty:     return 0.08
        }
    }

    var eyeColor: Color {
        switch self {
        case .allDone:   return Color(hex: "FFFFFF")
        case .upcoming:  return Color(hex: "FFFFFF")
        case .overdue:   return Color(hex: "FFE4E4")
        case .empty:     return Color(hex: "CBD5E1")
        }
    }
}

// MARK: - Main Character View

struct ElixirCharacterView: View {
    let state: WidgetState
    let size: CGFloat

    private var bodyWidth: CGFloat  { size * 0.72 }
    private var bodyHeight: CGFloat { size * 1.3 }

    var body: some View {
        ZStack(alignment: .bottom) {
            glowLayer
            bottleBody
            faceLayer
            decorationLayer
        }
        .frame(width: size, height: bodyHeight + size * 0.25)
    }

    // MARK: - Glow

    @ViewBuilder
    private var glowLayer: some View {
        Ellipse()
            .fill(state.glowColor.opacity(0.28))
            .frame(width: bodyWidth * 1.5, height: bodyHeight * 0.85)
            .blur(radius: size * 0.22)
            .offset(y: -bodyHeight * 0.1)
    }

    // MARK: - Bottle Body

    @ViewBuilder
    private var bottleBody: some View {
        ZStack(alignment: .bottom) {
            // Main bottle shape
            Capsule()
                .fill(state.bodyGradient)
                .frame(width: bodyWidth, height: bodyHeight)
                .overlay(
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.35), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )

            // Liquid fill (rises from bottom)
            liquidFillView

            // Glossy highlight on upper-right of bottle
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.45), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: bodyWidth * 0.2, height: bodyHeight * 0.18)
                .offset(x: bodyWidth * 0.18, y: -bodyHeight * 0.28)
                .allowsHitTesting(false)
        }
    }

    @ViewBuilder
    private var liquidFillView: some View {
        let fillHeight = bodyHeight * state.liquidFill
        GeometryReader { geo in
            Capsule()
                .fill(state.liquidColor)
                .frame(width: geo.size.width, height: fillHeight * 1.6)
                .offset(y: geo.size.height - fillHeight + 2)
        }
        .frame(width: bodyWidth - 4, height: bodyHeight - 4)
        .clipShape(Capsule())
    }

    // MARK: - Face

    @ViewBuilder
    private var faceLayer: some View {
        let faceOffsetY = -bodyHeight * 0.18
        VStack(spacing: size * 0.06) {
            eyeRow
            mouthShape
        }
        .offset(y: faceOffsetY)
    }

    @ViewBuilder
    private var eyeRow: some View {
        HStack(spacing: size * 0.18) {
            eyeView(isLeft: true)
            eyeView(isLeft: false)
        }
    }

    @ViewBuilder
    private func eyeView(isLeft: Bool) -> some View {
        let eyeSize = size * 0.15
        switch state {

        case .allDone:
            // Happy squint — crescent shape via overlapping circles
            ZStack {
                Circle()
                    .fill(state.eyeColor)
                    .frame(width: eyeSize, height: eyeSize)
                Circle()
                    .fill(state.bodyGradient)
                    .frame(width: eyeSize, height: eyeSize)
                    .offset(y: -eyeSize * 0.35)
            }
            .frame(width: eyeSize, height: eyeSize * 0.75)
            .clipped()

        case .upcoming:
            // Wide open alert eyes with pupil
            ZStack {
                Circle()
                    .fill(state.eyeColor)
                    .frame(width: eyeSize, height: eyeSize)
                Circle()
                    .fill(Color(hex: "1A1A2E"))
                    .frame(width: eyeSize * 0.55, height: eyeSize * 0.55)
                    .offset(x: isLeft ? 1 : -1, y: 1)
                // Specular dot
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: eyeSize * 0.2, height: eyeSize * 0.2)
                    .offset(x: isLeft ? eyeSize * 0.12 : -eyeSize * 0.1, y: -eyeSize * 0.12)
            }
            .frame(width: eyeSize, height: eyeSize)

        case .overdue:
            // Angry eyes with inward eyebrows
            let browAngle: Double = isLeft ? -22 : 22
            ZStack {
                // Eye whites
                Circle()
                    .fill(state.eyeColor)
                    .frame(width: eyeSize, height: eyeSize)
                // Pupil
                Circle()
                    .fill(Color(hex: "2D0000"))
                    .frame(width: eyeSize * 0.5, height: eyeSize * 0.5)
                // Eyebrow (angry slant)
                Capsule()
                    .fill(state.eyeColor)
                    .frame(width: eyeSize * 1.1, height: eyeSize * 0.2)
                    .rotationEffect(.degrees(browAngle))
                    .offset(y: -eyeSize * 0.72)
            }
            .frame(width: eyeSize, height: eyeSize * 1.4)

        case .empty:
            // Sleeping closed eyes — flat horizontal line
            Capsule()
                .fill(state.eyeColor.opacity(0.8))
                .frame(width: eyeSize * 1.05, height: eyeSize * 0.22)
        }
    }

    @ViewBuilder
    private var mouthShape: some View {
        let mouthWidth = size * 0.28
        let mouthHeight = size * 0.14
        switch state {

        case .allDone:
            // Big smile arc
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(
                    to: CGPoint(x: mouthWidth, y: 0),
                    control: CGPoint(x: mouthWidth / 2, y: mouthHeight)
                )
            }
            .stroke(state.eyeColor, style: StrokeStyle(lineWidth: size * 0.035, lineCap: .round))
            .frame(width: mouthWidth, height: mouthHeight)

        case .upcoming:
            // Small open "O"
            Circle()
                .stroke(state.eyeColor, lineWidth: size * 0.03)
                .frame(width: size * 0.12, height: size * 0.12)

        case .overdue:
            // Frown arc
            Path { path in
                path.move(to: CGPoint(x: 0, y: mouthHeight * 0.9))
                path.addQuadCurve(
                    to: CGPoint(x: mouthWidth, y: mouthHeight * 0.9),
                    control: CGPoint(x: mouthWidth / 2, y: -mouthHeight * 0.3)
                )
            }
            .stroke(state.eyeColor, style: StrokeStyle(lineWidth: size * 0.033, lineCap: .round))
            .frame(width: mouthWidth, height: mouthHeight)

        case .empty:
            // Flat sleeping mouth
            Capsule()
                .fill(state.eyeColor.opacity(0.7))
                .frame(width: size * 0.14, height: size * 0.03)
        }
    }

    // MARK: - Decorations

    @ViewBuilder
    private var decorationLayer: some View {
        let iconSize = size * 0.22
        switch state {

        case .allDone:
            ZStack {
                Image(systemName: "sparkle")
                    .font(.system(size: iconSize * 0.8, weight: .semibold))
                    .foregroundStyle(Color(hex: "FDE68A"))
                    .offset(x: -bodyWidth * 0.72, y: -bodyHeight * 0.42)

                Image(systemName: "sparkles")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(Color(hex: "FDE68A"))
                    .offset(x: bodyWidth * 0.68, y: -bodyHeight * 0.52)

                Image(systemName: "star.fill")
                    .font(.system(size: iconSize * 0.65, weight: .semibold))
                    .foregroundStyle(Color(hex: "FCD34D"))
                    .offset(x: bodyWidth * 0.6, y: -bodyHeight * 0.18)
            }

        case .upcoming:
            ZStack {
                Image(systemName: "exclamationmark")
                    .font(.system(size: iconSize * 1.1, weight: .black))
                    .foregroundStyle(Color(hex: "FBBF24"))
                    .offset(x: bodyWidth * 0.72, y: -bodyHeight * 0.55)

                Image(systemName: "alarm.fill")
                    .font(.system(size: iconSize * 0.85))
                    .foregroundStyle(Color(hex: "FCD34D").opacity(0.85))
                    .offset(x: -bodyWidth * 0.72, y: -bodyHeight * 0.35)
            }

        case .overdue:
            ZStack {
                Image(systemName: "bolt.fill")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(Color(hex: "FCA5A5"))
                    .offset(x: -bodyWidth * 0.7, y: -bodyHeight * 0.55)

                Image(systemName: "bolt.fill")
                    .font(.system(size: iconSize * 0.8))
                    .foregroundStyle(Color(hex: "F87171"))
                    .offset(x: bodyWidth * 0.72, y: -bodyHeight * 0.42)

                Image(systemName: "flame.fill")
                    .font(.system(size: iconSize * 0.75))
                    .foregroundStyle(Color(hex: "FCA5A5").opacity(0.7))
                    .offset(x: bodyWidth * 0.55, y: -bodyHeight * 0.65)
            }

        case .empty:
            ZStack {
                Text("z")
                    .font(.system(size: iconSize * 0.6, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "94A3B8").opacity(0.6))
                    .offset(x: bodyWidth * 0.5, y: -bodyHeight * 0.28)

                Text("z")
                    .font(.system(size: iconSize * 0.8, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "94A3B8").opacity(0.5))
                    .offset(x: bodyWidth * 0.65, y: -bodyHeight * 0.46)

                Text("Z")
                    .font(.system(size: iconSize, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "94A3B8").opacity(0.4))
                    .offset(x: bodyWidth * 0.78, y: -bodyHeight * 0.64)
            }
        }
    }
}

// MARK: - Previews

#Preview("All Done", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.medication(summary: .allDone, state: .allDone)
}

#Preview("Upcoming", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.medication(summary: .placeholder, state: .upcoming(nextDoseName: "Omega-3", dueDate: .now.addingTimeInterval(1800)))
}

#Preview("Overdue", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.medication(summary: .overdue, state: .overdue(count: 2))
}

#Preview("Empty", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.medication(summary: .empty, state: .empty)
}
