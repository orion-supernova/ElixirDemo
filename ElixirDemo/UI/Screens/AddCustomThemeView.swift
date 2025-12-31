//
//  AddCustomThemeView.swift
//  Elixir: Daily Ritual
//
//  Create custom app themes
//

import SwiftUI

struct AddCustomThemeView: View {
    @Environment(\.themeManager) private var themeManager
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

    var previewGradient: LinearGradient {
        LinearGradient(
            colors: [bgColor1, bgColor2, bgColor3],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                themeManager.currentTheme.backgroundGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Spacing.lg) {
                        // Preview
                        previewSection

                        // Theme Name
                        nameSection

                        // Background Colors
                        colorSection(
                            title: "Background Gradient",
                            colors: [
                                ("Primary", $bgColor1),
                                ("Secondary", $bgColor2),
                                ("Tertiary", $bgColor3)
                            ]
                        )

                        // Brand Colors
                        colorSection(
                            title: "Brand Colors",
                            colors: [
                                ("Primary", $primaryColor),
                                ("Secondary", $secondaryColor),
                                ("Accent", $accentColor)
                            ]
                        )

                        // Status Colors
                        colorSection(
                            title: "Status Colors",
                            colors: [
                                ("Success", $successColor),
                                ("Warning", $warningColor),
                                ("Error", $errorColor)
                            ]
                        )

                        // Save Button
                        saveButton
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
                    .foregroundColor(.white)
                }
            }
        }
    }

    // MARK: - Preview Section
    private var previewSection: some View {
        VStack(spacing: Spacing.md) {
            Text("Preview")
                .ritualFont(.ritualHeadline)
                .foregroundColor(.white)

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
                        .ritualFont(.ritualHeadline)
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

    // MARK: - Name Section
    private var nameSection: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Theme Name")
                .ritualFont(.ritualHeadline)
                .foregroundColor(.white)

            TextField("e.g., Sunset Vibes", text: $themeName)
                .textFieldStyle(ElixirTextFieldStyle())
        }
    }

    // MARK: - Color Section
    @ViewBuilder
    private func colorSection(title: String, colors: [(String, Binding<Color>)]) -> some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .ritualFont(.ritualHeadline)
                .foregroundColor(.white)

            VStack(spacing: Spacing.sm) {
                ForEach(colors, id: \.0) { label, colorBinding in
                    HStack {
                        Text(label)
                            .ritualFont(.ritualCallout)
                            .foregroundColor(.white.opacity(0.7))

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
            .glassCard()
        }
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: saveTheme) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Theme")
            }
            .ritualFont(.ritualHeadline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: primaryColor.opacity(0.5), radius: 20, x: 0, y: 10)
        }
        .disabled(themeName.isEmpty)
        .opacity(themeName.isEmpty ? 0.5 : 1.0)
    }

    // MARK: - Save Logic
    private func saveTheme() {
        let theme = AppTheme(
            id: UUID().uuidString,
            name: themeName,
            isCustom: true,
            bgColor1: bgColor1.toHex(),
            bgColor2: bgColor2.toHex(),
            bgColor3: bgColor3.toHex(),
            primaryColor: primaryColor.toHex(),
            secondaryColor: secondaryColor.toHex(),
            accentColor: accentColor.toHex(),
            successColor: successColor.toHex(),
            warningColor: warningColor.toHex(),
            errorColor: errorColor.toHex()
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
        let b = Int(components[2] * 255.0)
        return String(format: "%02X%02X%02X", r, g, b)
    }
}

// MARK: - Preview
#Preview {
    AddCustomThemeView()
        .environment(ThemeManager.shared)
}
