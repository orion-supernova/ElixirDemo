//
//  AddWidgetSheet.swift
//  Elixir: Daily Ritual
//
//  Prompt shown on launch when no Elixir widget is installed.
//

import SwiftUI

struct AddWidgetSheet: View {
    @Environment(ThemeManager.self) private var themeManager
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 28) {
                    header
                    widgetPreviewRow
                    stepsList
                    actionButtons
                }
                .padding(.horizontal, 24)
                .padding(.top, 36)
                .padding(.bottom, 48)
            }
        }
    }

    // MARK: - Header

    @ViewBuilder
    private var header: some View {
        VStack(spacing: 12) {
            // Character preview — medication + water mascots
            HStack(spacing: 24) {
                VStack(spacing: 6) {
                    MiniCharacter(state: .allDone, size: 56)
                    Text("Medication")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(themeManager.currentTheme.textSecondary.opacity(0.7))
                }
                VStack(spacing: 6) {
                    MiniWaterDroplet(state: .hydrated, size: 56)
                    Text("Water")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundStyle(themeManager.currentTheme.textSecondary.opacity(0.7))
                }
            }
            .padding(.bottom, 4)

            Text("Add the Elixir Widget")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(themeManager.currentTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("Track your meds or hydration right\nfrom your home screen — pick your mode.")
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(themeManager.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }

    // MARK: - Widget Size Previews

    @ViewBuilder
    private var widgetPreviewRow: some View {
        HStack(alignment: .bottom, spacing: 12) {
            WidgetSizeCard(label: "Small", icon: "square.fill", width: 80, height: 80)
            WidgetSizeCard(label: "Medium", icon: "rectangle.fill", width: 160, height: 80)
        }
        HStack {
            WidgetSizeCard(label: "Large", icon: "square.fill", width: 160, height: 160)
        }
    }

    // MARK: - Steps

    @ViewBuilder
    private var stepsList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("HOW TO ADD")
                .font(.system(size: 11, weight: .heavy, design: .rounded))
                .foregroundStyle(themeManager.currentTheme.textSecondary.opacity(0.6))
                .tracking(1.5)
                .padding(.bottom, 12)

            VStack(spacing: 0) {
                StepRow(number: 1, text: "Long press your home screen until icons jiggle", isLast: false)
                StepRow(number: 2, text: "Tap the  +  button in the top-left corner", isLast: false)
                StepRow(number: 3, text: "Search for \"Elixir\" and tap it", isLast: false)
                StepRow(number: 4, text: "Swipe to choose Small, Medium or Large", isLast: false)
                StepRow(number: 5, text: "Tap Add Widget, then long press it to choose Medication or Water mode", isLast: true)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
            )
        }
    }

    // MARK: - Buttons

    @ViewBuilder
    private var actionButtons: some View {
        Button {
            onDismiss()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "plus.square.on.square")
                Text("Got it, I'll add it!")
                    .fontWeight(.semibold)
            }
            .font(.system(size: 16, design: .rounded))
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(themeManager.currentTheme.primaryColor)
            )
        }
    }
}

// MARK: - Mini Character (pure SwiftUI, standalone for main app)

private struct MiniCharacter: View {
    enum CharState { case allDone, upcoming, overdue }

    let state: CharState
    let size: CGFloat

    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(glowColor.opacity(0.3))
                .frame(width: size * 1.3, height: size * 1.3)
                .blur(radius: size * 0.2)

            // Body
            Capsule()
                .fill(bodyGradient)
                .frame(width: size * 0.65, height: size)
                .overlay(
                    Capsule()
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                )

            // Liquid fill
            GeometryReader { _ in
                Capsule()
                    .fill(liquidColor)
                    .frame(width: size * 0.61, height: size * liquidFill)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .offset(y: -2)
            }
            .frame(width: size * 0.61, height: size - 4)
            .clipShape(Capsule())

            // Face
            VStack(spacing: size * 0.06) {
                HStack(spacing: size * 0.16) {
                    eyeView(isLeft: true)
                    eyeView(isLeft: false)
                }
                mouthView
            }
            .offset(y: -size * 0.12)
        }
        .frame(width: size, height: size * 1.3)
    }

    @ViewBuilder
    private func eyeView(isLeft: Bool) -> some View {
        let s = size * 0.13
        switch state {
        case .allDone:
            ZStack {
                Circle().fill(Color.white).frame(width: s, height: s)
                Circle().fill(bodyGradient).frame(width: s, height: s).offset(y: -s * 0.35)
            }.frame(width: s, height: s * 0.7).clipped()
        case .upcoming:
            ZStack {
                Circle().fill(Color.white).frame(width: s, height: s)
                Circle().fill(Color(red: 0.1, green: 0.1, blue: 0.2)).frame(width: s * 0.5, height: s * 0.5)
            }
        case .overdue:
            ZStack {
                Circle().fill(Color.white).frame(width: s, height: s)
                Circle().fill(Color(red: 0.18, green: 0, blue: 0)).frame(width: s * 0.45, height: s * 0.45)
                Capsule()
                    .fill(Color.white)
                    .frame(width: s * 1.1, height: s * 0.18)
                    .rotationEffect(.degrees(isLeft ? -22 : 22))
                    .offset(y: -s * 0.7)
            }.frame(width: s, height: s * 1.35)
        }
    }

    @ViewBuilder
    private var mouthView: some View {
        let w = size * 0.25
        let h = size * 0.12
        switch state {
        case .allDone:
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0))
                p.addQuadCurve(to: CGPoint(x: w, y: 0), control: CGPoint(x: w/2, y: h))
            }
            .stroke(Color.white, style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round))
            .frame(width: w, height: h)
        case .upcoming:
            Circle()
                .stroke(Color.white, lineWidth: size * 0.03)
                .frame(width: size * 0.1, height: size * 0.1)
        case .overdue:
            Path { p in
                p.move(to: CGPoint(x: 0, y: h * 0.9))
                p.addQuadCurve(to: CGPoint(x: w, y: h * 0.9), control: CGPoint(x: w/2, y: -h * 0.2))
            }
            .stroke(Color.white, style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round))
            .frame(width: w, height: h)
        }
    }

    private var glowColor: Color {
        switch state {
        case .allDone:  return Color(red: 0.29, green: 0.8, blue: 0.44)
        case .upcoming: return Color(red: 0.95, green: 0.8, blue: 0.08)
        case .overdue:  return Color(red: 0.91, green: 0.3, blue: 0.24)
        }
    }

    private var bodyGradient: LinearGradient {
        switch state {
        case .allDone:
            return LinearGradient(colors: [Color(red: 0.18, green: 0.8, blue: 0.44), Color(red: 0.1, green: 0.6, blue: 0.32)], startPoint: .top, endPoint: .bottom)
        case .upcoming:
            return LinearGradient(colors: [Color(red: 0.96, green: 0.77, blue: 0.09), Color(red: 0.88, green: 0.49, blue: 0.0)], startPoint: .top, endPoint: .bottom)
        case .overdue:
            return LinearGradient(colors: [Color(red: 0.91, green: 0.3, blue: 0.24), Color(red: 0.75, green: 0.11, blue: 0.17)], startPoint: .top, endPoint: .bottom)
        }
    }

    private var liquidColor: Color {
        switch state {
        case .allDone:  return Color(red: 0.1, green: 0.64, blue: 0.28).opacity(0.65)
        case .upcoming: return Color(red: 0.85, green: 0.48, blue: 0.0).opacity(0.6)
        case .overdue:  return Color(red: 0.73, green: 0.11, blue: 0.11).opacity(0.65)
        }
    }

    private var liquidFill: CGFloat {
        switch state {
        case .allDone:  return 0.82
        case .upcoming: return 0.5
        case .overdue:  return 0.18
        }
    }
}

// MARK: - Mini Water Droplet (main app standalone)

private struct MiniWaterDroplet: View {
    enum DropState { case hydrated, thirsty }

    let state: DropState
    let size: CGFloat

    var body: some View {
        ZStack {
            // Glow
            Circle()
                .fill(glowColor.opacity(0.3))
                .frame(width: size * 1.3, height: size * 1.3)
                .blur(radius: size * 0.2)

            // Droplet body
            MiniDropletShape()
                .fill(bodyGradient)
                .frame(width: size * 0.65, height: size)
                .overlay(
                    MiniDropletShape()
                        .strokeBorder(Color.white.opacity(0.25), lineWidth: 1)
                )

            // Face
            VStack(spacing: size * 0.06) {
                HStack(spacing: size * 0.16) {
                    dropEye(isLeft: true)
                    dropEye(isLeft: false)
                }
                dropMouth
            }
            .offset(y: size * 0.06)
        }
        .frame(width: size, height: size * 1.3)
    }

    @ViewBuilder
    private func dropEye(isLeft: Bool) -> some View {
        let s = size * 0.12
        switch state {
        case .hydrated:
            ZStack {
                Circle().fill(Color.white).frame(width: s, height: s)
                Circle().fill(bodyGradient).frame(width: s, height: s).offset(y: -s * 0.35)
            }.frame(width: s, height: s * 0.7).clipped()
        case .thirsty:
            ZStack {
                Circle().fill(Color.white).frame(width: s * 1.1, height: s * 1.1)
                Circle().fill(Color(red: 0.1, green: 0.1, blue: 0.2)).frame(width: s * 0.5, height: s * 0.5)
            }
        }
    }

    @ViewBuilder
    private var dropMouth: some View {
        let w = size * 0.22
        let h = size * 0.1
        switch state {
        case .hydrated:
            Path { p in
                p.move(to: CGPoint(x: 0, y: 0))
                p.addQuadCurve(to: CGPoint(x: w, y: 0), control: CGPoint(x: w / 2, y: h))
            }
            .stroke(Color.white, style: StrokeStyle(lineWidth: size * 0.03, lineCap: .round))
            .frame(width: w, height: h)
        case .thirsty:
            Circle()
                .stroke(Color.white, lineWidth: size * 0.03)
                .frame(width: size * 0.09, height: size * 0.09)
        }
    }

    private var glowColor: Color {
        switch state {
        case .hydrated: return Color(red: 0.13, green: 0.83, blue: 0.93)
        case .thirsty:  return Color(red: 0.96, green: 0.62, blue: 0.04)
        }
    }

    private var bodyGradient: LinearGradient {
        switch state {
        case .hydrated:
            return LinearGradient(colors: [Color(red: 0.13, green: 0.83, blue: 0.93), Color(red: 0.05, green: 0.65, blue: 0.91)], startPoint: .top, endPoint: .bottom)
        case .thirsty:
            return LinearGradient(colors: [Color(red: 0.96, green: 0.62, blue: 0.04), Color(red: 0.85, green: 0.47, blue: 0.02)], startPoint: .top, endPoint: .bottom)
        }
    }
}

private struct MiniDropletShape: InsettableShape {
    var insetAmount: CGFloat = 0

    func inset(by amount: CGFloat) -> MiniDropletShape {
        MiniDropletShape(insetAmount: insetAmount + amount)
    }

    func path(in rect: CGRect) -> Path {
        let rect = rect.insetBy(dx: insetAmount, dy: insetAmount)
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + h * 0.55),
            control: CGPoint(x: rect.maxX - w * 0.08, y: rect.minY + h * 0.18)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.minY + h * 0.82),
            control2: CGPoint(x: rect.midX + w * 0.22, y: rect.maxY)
        )
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.minY + h * 0.55),
            control1: CGPoint(x: rect.midX - w * 0.22, y: rect.maxY),
            control2: CGPoint(x: rect.minX, y: rect.minY + h * 0.82)
        )
        path.addQuadCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control: CGPoint(x: rect.minX + w * 0.08, y: rect.minY + h * 0.18)
        )
        return path
    }
}

// MARK: - Widget Size Card

private struct WidgetSizeCard: View {
    @Environment(ThemeManager.self) private var themeManager
    let label: String
    let icon: String
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.07), Color.white.opacity(0.03)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )

            VStack(spacing: 6) {
                Image(systemName: "app.fill")
                    .font(.system(size: height * 0.25))
                    .foregroundStyle(themeManager.currentTheme.primaryColor.opacity(0.7))
                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(themeManager.currentTheme.textSecondary.opacity(0.7))
            }
        }
        .frame(width: width, height: height)
    }
}

// MARK: - Step Row

private struct StepRow: View {
    @Environment(ThemeManager.self) private var themeManager
    let number: Int
    let text: String
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Number badge
            ZStack {
                Circle()
                    .fill(themeManager.currentTheme.primaryColor.opacity(0.2))
                    .frame(width: 28, height: 28)
                Text("\(number)")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(themeManager.currentTheme.primaryColor)
            }

            Text(text)
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(themeManager.currentTheme.textPrimary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)

        if !isLast {
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1)
                .padding(.leading, 58)
        }
    }
}
