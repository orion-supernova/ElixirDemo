//
//  WaterDropletCharacterView.swift
//  ElixirWidget
//
//  The Elixir hydration mascot — a water droplet character whose face
//  and decorations reflect today's hydration progress.
//  Built entirely from SwiftUI shapes and SF Symbols. No image assets.
//

import SwiftUI
import WidgetKit

// MARK: - State Appearance

private extension WaterHydrationState {
    var bodyGradient: LinearGradient {
        switch self {
        case .dehydrated:
            return LinearGradient(colors: [Color(hex: "E74C3C"), Color(hex: "DC2626")], startPoint: .top, endPoint: .bottom)
        case .thirsty:
            return LinearGradient(colors: [Color(hex: "F59E0B"), Color(hex: "D97706")], startPoint: .top, endPoint: .bottom)
        case .hydrating:
            return LinearGradient(colors: [Color(hex: "60A5FA"), Color(hex: "3B82F6")], startPoint: .top, endPoint: .bottom)
        case .fullyHydrated:
            return LinearGradient(colors: [Color(hex: "22D3EE"), Color(hex: "0EA5E9")], startPoint: .top, endPoint: .bottom)
        case .empty:
            return LinearGradient(colors: [Color(hex: "64748B"), Color(hex: "334155")], startPoint: .top, endPoint: .bottom)
        }
    }

    var glowColor: Color {
        switch self {
        case .dehydrated:    return Color(hex: "F87171")
        case .thirsty:       return Color(hex: "FBBF24")
        case .hydrating:     return Color(hex: "60A5FA")
        case .fullyHydrated: return Color(hex: "22D3EE")
        case .empty:         return Color(hex: "94A3B8")
        }
    }

    var eyeColor: Color {
        switch self {
        case .dehydrated:    return Color(hex: "FFE4E4")
        case .thirsty:       return Color(hex: "FFFFFF")
        case .hydrating:     return Color(hex: "FFFFFF")
        case .fullyHydrated: return Color(hex: "FFFFFF")
        case .empty:         return Color(hex: "CBD5E1")
        }
    }
}

// MARK: - Droplet Shape

private struct DropletShape: InsettableShape {
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> DropletShape {
        DropletShape(insetAmount: insetAmount + amount)
    }

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let w = rect.width
        let h = rect.height
        // Teardrop: pointed top, rounded bottom
        var path = Path()
        path.move(to: CGPoint(x: w / 2, y: 0))
        path.addQuadCurve(
            to: CGPoint(x: w, y: h * 0.55),
            control: CGPoint(x: w * 0.92, y: h * 0.18)
        )
        path.addCurve(
            to: CGPoint(x: w / 2, y: h),
            control1: CGPoint(x: w, y: h * 0.82),
            control2: CGPoint(x: w * 0.72, y: h)
        )
        path.addCurve(
            to: CGPoint(x: 0, y: h * 0.55),
            control1: CGPoint(x: w * 0.28, y: h),
            control2: CGPoint(x: 0, y: h * 0.82)
        )
        path.addQuadCurve(
            to: CGPoint(x: w / 2, y: 0),
            control: CGPoint(x: w * 0.08, y: h * 0.18)
        )
        return path
    }
}

// MARK: - Main Character View

struct WaterDropletCharacterView: View {
    let state: WaterHydrationState
    let size: CGFloat
    var celebrating: Bool = false

    private var bodyWidth: CGFloat  { size * 0.78 }
    private var bodyHeight: CGFloat { size * 1.2 }

    /// When celebrating, override appearance to happy/celebratory regardless of actual state.
    private var effectiveState: WaterHydrationState {
        celebrating ? .fullyHydrated : state
    }

    var body: some View {
        ZStack(alignment: .center) {
            glowLayer
            dropletBody
            faceLayer
            decorationLayer
        }
        .frame(width: size, height: bodyHeight + size * 0.15)
    }

    // MARK: - Glow

    @ViewBuilder
    private var glowLayer: some View {
        Ellipse()
            .fill(celebrating ? Color(hex: "22D3EE").opacity(0.45) : effectiveState.glowColor.opacity(0.3))
            .frame(width: bodyWidth * 1.4, height: bodyHeight * 0.8)
            .blur(radius: size * 0.2)
            .offset(y: bodyHeight * 0.08)
    }

    // MARK: - Droplet Body

    @ViewBuilder
    private var dropletBody: some View {
        let bodyFill = celebrating
            ? LinearGradient(colors: [Color(hex: "22D3EE"), Color(hex: "4ADE80")], startPoint: .top, endPoint: .bottom)
            : effectiveState.bodyGradient
        ZStack {
            DropletShape()
                .fill(bodyFill)
                .frame(width: bodyWidth, height: bodyHeight)
                .overlay(
                    DropletShape()
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.35), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                )

            // Glossy highlight
            Ellipse()
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.45), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: bodyWidth * 0.18, height: bodyHeight * 0.15)
                .offset(x: bodyWidth * 0.15, y: -bodyHeight * 0.18)
                .allowsHitTesting(false)
        }
    }

    // MARK: - Face

    @ViewBuilder
    private var faceLayer: some View {
        let faceOffsetY = bodyHeight * 0.08
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
        let eyeSize = size * 0.14
        switch effectiveState {

        case .fullyHydrated:
            // Happy squint — crescent
            ZStack {
                Circle()
                    .fill(effectiveState.eyeColor)
                    .frame(width: eyeSize, height: eyeSize)
                Circle()
                    .fill(effectiveState.bodyGradient)
                    .frame(width: eyeSize, height: eyeSize)
                    .offset(y: -eyeSize * 0.35)
            }
            .frame(width: eyeSize, height: eyeSize * 0.75)
            .clipped()

        case .hydrating:
            // Happy open eyes with pupil
            ZStack {
                Circle()
                    .fill(effectiveState.eyeColor)
                    .frame(width: eyeSize, height: eyeSize)
                Circle()
                    .fill(Color(hex: "1A1A2E"))
                    .frame(width: eyeSize * 0.5, height: eyeSize * 0.5)
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: eyeSize * 0.18, height: eyeSize * 0.18)
                    .offset(x: isLeft ? eyeSize * 0.1 : -eyeSize * 0.1, y: -eyeSize * 0.1)
            }

        case .thirsty:
            // Wide alert eyes
            ZStack {
                Circle()
                    .fill(effectiveState.eyeColor)
                    .frame(width: eyeSize * 1.1, height: eyeSize * 1.1)
                Circle()
                    .fill(Color(hex: "1A1A2E"))
                    .frame(width: eyeSize * 0.55, height: eyeSize * 0.55)
                    .offset(x: isLeft ? 1 : -1, y: 1)
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: eyeSize * 0.2, height: eyeSize * 0.2)
                    .offset(x: isLeft ? eyeSize * 0.12 : -eyeSize * 0.1, y: -eyeSize * 0.12)
            }

        case .dehydrated:
            // Sad droopy eyes with downward eyebrows
            let browAngle: Double = isLeft ? 18 : -18
            ZStack {
                Circle()
                    .fill(effectiveState.eyeColor)
                    .frame(width: eyeSize, height: eyeSize)
                Circle()
                    .fill(Color(hex: "2D0000"))
                    .frame(width: eyeSize * 0.5, height: eyeSize * 0.5)
                    .offset(y: eyeSize * 0.05)
                // Droopy eyebrow
                Capsule()
                    .fill(effectiveState.eyeColor)
                    .frame(width: eyeSize * 1.1, height: eyeSize * 0.18)
                    .rotationEffect(.degrees(browAngle))
                    .offset(y: -eyeSize * 0.7)
            }
            .frame(width: eyeSize, height: eyeSize * 1.4)

        case .empty:
            // Sleeping closed eyes
            Capsule()
                .fill(effectiveState.eyeColor.opacity(0.8))
                .frame(width: eyeSize * 1.05, height: eyeSize * 0.22)
        }
    }

    @ViewBuilder
    private var mouthShape: some View {
        let mouthWidth = size * 0.26
        let mouthHeight = size * 0.13
        switch effectiveState {

        case .fullyHydrated:
            // Big smile arc
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(
                    to: CGPoint(x: mouthWidth, y: 0),
                    control: CGPoint(x: mouthWidth / 2, y: mouthHeight)
                )
            }
            .stroke(effectiveState.eyeColor, style: StrokeStyle(lineWidth: size * 0.035, lineCap: .round))
            .frame(width: mouthWidth, height: mouthHeight)

        case .hydrating:
            // Gentle smile
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addQuadCurve(
                    to: CGPoint(x: mouthWidth * 0.8, y: 0),
                    control: CGPoint(x: mouthWidth * 0.4, y: mouthHeight * 0.7)
                )
            }
            .stroke(effectiveState.eyeColor, style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round))
            .frame(width: mouthWidth * 0.8, height: mouthHeight * 0.7)

        case .thirsty:
            // Small open "O"
            Circle()
                .stroke(effectiveState.eyeColor, lineWidth: size * 0.03)
                .frame(width: size * 0.11, height: size * 0.11)

        case .dehydrated:
            // Frown arc
            Path { path in
                path.move(to: CGPoint(x: 0, y: mouthHeight * 0.9))
                path.addQuadCurve(
                    to: CGPoint(x: mouthWidth, y: mouthHeight * 0.9),
                    control: CGPoint(x: mouthWidth / 2, y: -mouthHeight * 0.3)
                )
            }
            .stroke(effectiveState.eyeColor, style: StrokeStyle(lineWidth: size * 0.033, lineCap: .round))
            .frame(width: mouthWidth, height: mouthHeight)

        case .empty:
            // Flat sleeping mouth
            Capsule()
                .fill(effectiveState.eyeColor.opacity(0.7))
                .frame(width: size * 0.13, height: size * 0.03)
        }
    }

    // MARK: - Decorations

    @ViewBuilder
    private var decorationLayer: some View {
        let iconSize = size * 0.2
        if celebrating {
            celebrationDecorations(iconSize: iconSize)
        } else {
            normalDecorations(iconSize: iconSize)
        }
    }

    @ViewBuilder
    private func celebrationDecorations(iconSize: CGFloat) -> some View {
        ZStack {
            Image(systemName: "sparkle")
                .font(.system(size: iconSize, weight: .semibold))
                .foregroundStyle(Color(hex: "FDE68A"))
                .offset(x: -bodyWidth * 0.7, y: -bodyHeight * 0.15)

            Image(systemName: "sparkles")
                .font(.system(size: iconSize * 1.1, weight: .semibold))
                .foregroundStyle(Color(hex: "A5F3FC"))
                .offset(x: bodyWidth * 0.68, y: -bodyHeight * 0.22)

            Image(systemName: "star.fill")
                .font(.system(size: iconSize * 0.6, weight: .semibold))
                .foregroundStyle(Color(hex: "FCD34D"))
                .offset(x: bodyWidth * 0.58, y: bodyHeight * 0.18)

            Image(systemName: "star.fill")
                .font(.system(size: iconSize * 0.45, weight: .semibold))
                .foregroundStyle(Color(hex: "4ADE80").opacity(0.8))
                .offset(x: -bodyWidth * 0.6, y: bodyHeight * 0.12)

            Image(systemName: "sparkle")
                .font(.system(size: iconSize * 0.5, weight: .semibold))
                .foregroundStyle(Color(hex: "22D3EE").opacity(0.7))
                .offset(x: -bodyWidth * 0.45, y: -bodyHeight * 0.35)
        }
    }

    @ViewBuilder
    private func normalDecorations(iconSize: CGFloat) -> some View {
        switch effectiveState {

        case .fullyHydrated:
            ZStack {
                Image(systemName: "sparkle")
                    .font(.system(size: iconSize * 0.8, weight: .semibold))
                    .foregroundStyle(Color(hex: "FDE68A"))
                    .offset(x: -bodyWidth * 0.68, y: -bodyHeight * 0.12)

                Image(systemName: "sparkles")
                    .font(.system(size: iconSize, weight: .semibold))
                    .foregroundStyle(Color(hex: "A5F3FC"))
                    .offset(x: bodyWidth * 0.65, y: -bodyHeight * 0.2)

                Image(systemName: "star.fill")
                    .font(.system(size: iconSize * 0.55, weight: .semibold))
                    .foregroundStyle(Color(hex: "FCD34D"))
                    .offset(x: bodyWidth * 0.55, y: bodyHeight * 0.15)
            }

        case .hydrating:
            ZStack {
                Image(systemName: "bubble.left.fill")
                    .font(.system(size: iconSize * 0.55))
                    .foregroundStyle(Color(hex: "BAE6FD").opacity(0.7))
                    .offset(x: bodyWidth * 0.6, y: -bodyHeight * 0.22)

                Image(systemName: "bubble.left.fill")
                    .font(.system(size: iconSize * 0.4))
                    .foregroundStyle(Color(hex: "BAE6FD").opacity(0.5))
                    .offset(x: -bodyWidth * 0.58, y: -bodyHeight * 0.08)

                Image(systemName: "sparkle")
                    .font(.system(size: iconSize * 0.5, weight: .semibold))
                    .foregroundStyle(Color(hex: "93C5FD").opacity(0.6))
                    .offset(x: bodyWidth * 0.5, y: bodyHeight * 0.2)
            }

        case .thirsty:
            ZStack {
                Image(systemName: "exclamationmark")
                    .font(.system(size: iconSize * 1.0, weight: .black))
                    .foregroundStyle(Color(hex: "FBBF24"))
                    .offset(x: bodyWidth * 0.68, y: -bodyHeight * 0.25)

                Image(systemName: "drop.fill")
                    .font(.system(size: iconSize * 0.6))
                    .foregroundStyle(Color(hex: "FCD34D").opacity(0.7))
                    .offset(x: -bodyWidth * 0.65, y: bodyHeight * 0.05)
            }

        case .dehydrated:
            ZStack {
                // Sweat drops
                Image(systemName: "drop.fill")
                    .font(.system(size: iconSize * 0.5))
                    .foregroundStyle(Color(hex: "FCA5A5").opacity(0.8))
                    .offset(x: bodyWidth * 0.55, y: -bodyHeight * 0.18)

                Image(systemName: "drop.fill")
                    .font(.system(size: iconSize * 0.4))
                    .foregroundStyle(Color(hex: "FCA5A5").opacity(0.6))
                    .offset(x: -bodyWidth * 0.6, y: -bodyHeight * 0.05)

                Image(systemName: "flame.fill")
                    .font(.system(size: iconSize * 0.6))
                    .foregroundStyle(Color(hex: "F87171").opacity(0.5))
                    .offset(x: bodyWidth * 0.6, y: bodyHeight * 0.18)
            }

        case .empty:
            ZStack {
                Text("z")
                    .font(.system(size: iconSize * 0.55, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "94A3B8").opacity(0.6))
                    .offset(x: bodyWidth * 0.45, y: -bodyHeight * 0.15)

                Text("z")
                    .font(.system(size: iconSize * 0.75, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "94A3B8").opacity(0.5))
                    .offset(x: bodyWidth * 0.6, y: -bodyHeight * 0.3)

                Text("Z")
                    .font(.system(size: iconSize * 0.95, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color(hex: "94A3B8").opacity(0.4))
                    .offset(x: bodyWidth * 0.72, y: -bodyHeight * 0.45)
            }
        }
    }
}

// MARK: - Previews

#Preview("Fully Hydrated", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .fullyHydrated, state: .fullyHydrated)
}

#Preview("Hydrating", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .placeholder, state: .hydrating)
}

#Preview("Thirsty", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .dehydrated, state: .thirsty)
}

#Preview("Dehydrated", as: .systemMedium) {
    ElixirWidget()
} timeline: {
    ElixirWidgetEntry.water(summary: .dehydrated, state: .dehydrated)
}
