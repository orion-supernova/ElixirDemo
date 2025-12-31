//
//  Theme.swift
//  Elixir: Daily Ritual
//
//  Core design system for the Elixir app
//

import SwiftUI

// MARK: - Elixir Color Palette
extension Color {
    // Primary Brand Colors - Vibrant & Modern
    static let potionPurple = Color(hex: "A78BFA")      // Soft purple
    static let deepPurple = Color(hex: "7C3AED")        // Rich purple
    static let healingGreen = Color(hex: "34D399")      // Mint green
    static let manaBlue = Color(hex: "60A5FA")          // Sky blue
    static let darkBlue = Color(hex: "1E40AF")          // Deep blue

    // Supporting Colors
    static let mysticGold = Color(hex: "FBBF24")        // Warm gold
    static let phoenixRed = Color(hex: "F87171")        // Soft red
    static let lavender = Color(hex: "C4B5FD")          // Light lavender
    static let mint = Color(hex: "6EE7B7")              // Light mint

    // Background Colors
    static let bgDarkPurple = Color(hex: "1E1B4B")      // Deep indigo
    static let bgMidPurple = Color(hex: "312E81")       // Mid indigo
    static let bgDarkBlue = Color(hex: "1E3A8A")        // Deep blue

    // Gradient Collections
    static let elixirGradient = LinearGradient(
        colors: [potionPurple, manaBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let backgroundGradient = LinearGradient(
        colors: [bgDarkPurple, bgMidPurple, bgDarkBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let successGradient = LinearGradient(
        colors: [healingGreen, mint],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    // Hex Color Initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography System
extension Font {
    // SF Pro Rounded Hierarchy
    static let ritualLargeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let ritualTitle = Font.system(size: 28, weight: .bold, design: .rounded)
    static let ritualTitle2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let ritualTitle3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    static let ritualHeadline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let ritualBody = Font.system(size: 17, weight: .regular, design: .rounded)
    static let ritualCallout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let ritualSubheadline = Font.system(size: 15, weight: .medium, design: .rounded)
    static let ritualFootnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let ritualCaption = Font.system(size: 12, weight: .regular, design: .rounded)
}

// MARK: - Glassmorphism View Modifier
struct GlassCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 20
    var opacity: Double = 0.7

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(0.05))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.3),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

struct ElixirCardModifier: ViewModifier {
    var isPressed: Bool = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        LinearGradient(
                            colors: [Color.potionPurple.opacity(0.5), Color.manaBlue.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: isPressed ? Color.potionPurple.opacity(0.5) : Color.black.opacity(0.3),
                radius: isPressed ? 10 : 15,
                x: 0,
                y: isPressed ? 4 : 8
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - View Extensions
extension View {
    func glassCard(cornerRadius: CGFloat = 20, opacity: Double = 0.7) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, opacity: opacity))
    }

    func elixirCard(isPressed: Bool = false) -> some View {
        modifier(ElixirCardModifier(isPressed: isPressed))
    }

    func ritualFont(_ font: Font) -> some View {
        self.font(font)
    }

    // Haptic Feedback Helper
    func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

// MARK: - Animation Presets
extension Animation {
    static let ritualSpring = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let ritualBounce = Animation.spring(response: 0.5, dampingFraction: 0.6)
}

// MARK: - Spacing System
enum Spacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}
