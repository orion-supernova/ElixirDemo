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
            // Character preview — three states side by side
            HStack(spacing: 16) {
                MiniCharacter(state: .overdue,   size: 52)
                MiniCharacter(state: .upcoming,  size: 64)
                MiniCharacter(state: .allDone,   size: 52)
            }
            .padding(.bottom, 4)

            Text("Add the Elixir Widget")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(themeManager.currentTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("Stay on top of your ritual from your\nhome screen — at a glance.")
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
                StepRow(number: 5, text: "Tap Add Widget — done!", isLast: true)
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
