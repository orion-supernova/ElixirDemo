//
//  PreviewSection.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

struct PreviewSection: View {
    @Environment(ThemeManager.self) private var themeManager

    let bgColor1: Color
    let bgColor2: Color
    let bgColor3: Color
    let primaryColor: Color
    let secondaryColor: Color
    let accentColor: Color
    let successColor: Color
    let warningColor: Color
    let errorColor: Color

    var previewGradient: LinearGradient {
        LinearGradient(
            colors: [bgColor1, bgColor2, bgColor3],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Preview")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(previewGradient)
                    .frame(height: 200)

                VStack(spacing: Spacing.md) {
                    HStack(spacing: Spacing.sm) {
                        Circle()
                            .fill(primaryColor)
                            .frame(width: 30, height: 30)

                        Circle()
                            .fill(secondaryColor)
                            .frame(width: 30, height: 30)

                        Circle()
                            .fill(accentColor)
                            .frame(width: 30, height: 30)
                    }

                    Text("Theme Preview")
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(.white)

                    HStack(spacing: Spacing.sm) {
                        Circle()
                            .fill(successColor)
                            .frame(width: 20, height: 20)

                        Circle()
                            .fill(warningColor)
                            .frame(width: 20, height: 20)

                        Circle()
                            .fill(errorColor)
                            .frame(width: 20, height: 20)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    PreviewSection(
        bgColor1: Color(hex: "1E1B4B"),
        bgColor2: Color(hex: "312E81"),
        bgColor3: Color(hex: "1E3A8A"),
        primaryColor: Color(hex: "A78BFA"),
        secondaryColor: Color(hex: "60A5FA"),
        accentColor: Color(hex: "C4B5FD"),
        successColor: Color(hex: "34D399"),
        warningColor: Color(hex: "FBBF24"),
        errorColor: Color(hex: "F87171")
    )
    .environment(ThemeManager.shared)
    .padding()
    .background(Color.black)
}
