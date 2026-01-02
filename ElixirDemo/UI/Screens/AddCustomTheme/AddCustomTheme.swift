//
//  AddCustomTheme.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

struct AddCustomTheme: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @State private var themeName = ""
    @State private var bgColor1 = Color(hex: "1E1B4B")
    @State private var bgColor2 = Color(hex: "312E81")
    @State private var bgColor3 = Color(hex: "1E3A8A")
    @State private var primaryColor = Color(hex: "A78BFA")
    @State private var secondaryColor = Color(hex: "60A5FA")
    @State private var accentColor = Color(hex: "C4B5FD")
    @State private var successColor = Color(hex: "34D399")
    @State private var warningColor = Color(hex: "FBBF24")
    @State private var errorColor = Color(hex: "F87171")

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.currentTheme.backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Preview
                        PreviewSection(
                            bgColor1: bgColor1,
                            bgColor2: bgColor2,
                            bgColor3: bgColor3,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            accentColor: accentColor,
                            successColor: successColor,
                            warningColor: warningColor,
                            errorColor: errorColor
                        )

                        // Theme Name
                        NameSection(themeName: $themeName)

                        // Background Colors
                        ColorSection(
                            title: "Background Gradient",
                            colors: [
                                ("Primary", $bgColor1),
                                ("Secondary", $bgColor2),
                                ("Tertiary", $bgColor3)
                            ]
                        )

                        // Brand Colors
                        ColorSection(
                            title: "Brand Colors",
                            colors: [
                                ("Primary", $primaryColor),
                                ("Secondary", $secondaryColor),
                                ("Accent", $accentColor)
                            ]
                        )

                        // Status Colors
                        ColorSection(
                            title: "Status Colors",
                            colors: [
                                ("Success", $successColor),
                                ("Warning", $warningColor),
                                ("Error", $errorColor)
                            ]
                        )

                        // Save Button
                        ThemeSaveButton(
                            isEnabled: !themeName.isEmpty,
                            primaryColor: primaryColor,
                            secondaryColor: secondaryColor,
                            action: saveTheme
                        )
                    }
                    .padding(Spacing.md)
                    .padding(.bottom, Spacing.xxl)
                }
            }
            .navigationTitle("Custom Theme")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                }
            }
        }
    }

    // MARK: - Save Logic
    private func saveTheme() {
        // Defaults for now. In a future update we can let users choose category/font/symbols.
        let defaultCategory: ThemeCategory = .rpg
        let defaultSymbols: ThemeSymbols = .rpg

        let theme = CustomTheme(
            id: UUID().uuidString,
            displayName: themeName,
            category: defaultCategory,
            fontName: nil, // Use system font
            headerFontName: nil,
            symbols: defaultSymbols,
            primaryColorHex: primaryColor.toHex(),
            secondaryColorHex: secondaryColor.toHex(),
            accentColorHex: accentColor.toHex(),
            backgroundColorHex: bgColor1.toHex(),
            surfaceColorHex: bgColor2.toHex(),
            successColorHex: successColor.toHex(),
            warningColorHex: warningColor.toHex(),
            errorColorHex: errorColor.toHex(),
            cornerRadius: 16,
            bgGradientColor1Hex: bgColor1.toHex(),
            bgGradientColor2Hex: bgColor2.toHex(),
            bgGradientColor3Hex: bgColor3.toHex()
        )

        themeManager.addCustomTheme(theme)
        dismiss()
    }
}

// MARK: - Color to Hex Extension
extension Color {
    func toHex() -> String {
        let components = UIColor(self).cgColor.components ?? [0, 0, 0, 1]
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = components.count > 2 ? Int(components[2] * 255.0) : Int(components[0] * 255.0)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}

// MARK: - Preview
#Preview {
    AddCustomTheme()
        .environment(ThemeManager.shared)
}
