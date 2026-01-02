//
//  ColorSection.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

struct ColorSection: View {
    @Environment(ThemeManager.self) private var themeManager

    let title: String
    let colors: [(String, Binding<Color>)]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            VStack(spacing: Spacing.sm) {
                ForEach(colors, id: \.0) { label, colorBinding in
                    HStack {
                        Text(label)
                            .font(themeManager.currentTheme.font(for: .callout))
                            .foregroundColor(themeManager.currentTheme.textSecondary)

                        Spacer()

                        ColorPicker("", selection: colorBinding, supportsOpacity: false)
                            .labelsHidden()
                            .frame(width: 44, height: 44)
                    }
                    .padding(Spacing.sm)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.05))
                    )
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                    .fill(.ultraThinMaterial)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ColorSection(
        title: "Brand Colors",
        colors: [
            ("Primary", .constant(Color.blue)),
            ("Secondary", .constant(Color.purple)),
            ("Accent", .constant(Color.pink))
        ]
    )
    .environment(ThemeManager.shared)
    .padding()
    .background(Color.black)
}
