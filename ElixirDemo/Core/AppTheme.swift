//
//  AppTheme.swift
//  Elixir: Daily Ritual
//
//  Dynamic theme system with multiple presets
//

import SwiftUI

// MARK: - App Theme Model
struct AppTheme: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let isCustom: Bool

    // Background Colors
    let bgColor1: String
    let bgColor2: String
    let bgColor3: String

    // Brand Colors
    let primaryColor: String
    let secondaryColor: String
    let accentColor: String

    // Supporting Colors
    let successColor: String
    let warningColor: String
    let errorColor: String

    // Computed Properties
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: bgColor1),
                Color(hex: bgColor2),
                Color(hex: bgColor3)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: primaryColor),
                Color(hex: secondaryColor)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var primary: Color { Color(hex: primaryColor) }
    var secondary: Color { Color(hex: secondaryColor) }
    var accent: Color { Color(hex: accentColor) }
    var success: Color { Color(hex: successColor) }
    var warning: Color { Color(hex: warningColor) }
    var error: Color { Color(hex: errorColor) }
}

// MARK: - Default Themes
extension AppTheme {
    static let mysticPurple = AppTheme(
        id: "mystic-purple",
        name: "Mystic Purple",
        isCustom: false,
        bgColor1: "1E1B4B",
        bgColor2: "312E81",
        bgColor3: "1E3A8A",
        primaryColor: "A78BFA",
        secondaryColor: "60A5FA",
        accentColor: "C4B5FD",
        successColor: "34D399",
        warningColor: "FBBF24",
        errorColor: "F87171"
    )

    static let deepOcean = AppTheme(
        id: "deep-ocean",
        name: "Deep Ocean",
        isCustom: false,
        bgColor1: "0F172A",
        bgColor2: "1E3A5F",
        bgColor3: "0C4A6E",
        primaryColor: "0EA5E9",
        secondaryColor: "06B6D4",
        accentColor: "22D3EE",
        successColor: "10B981",
        warningColor: "F59E0B",
        errorColor: "EF4444"
    )

    static let cyberpunk = AppTheme(
        id: "cyberpunk",
        name: "Cyberpunk",
        isCustom: false,
        bgColor1: "18181B",
        bgColor2: "27272A",
        bgColor3: "3F3F46",
        primaryColor: "EC4899",
        secondaryColor: "8B5CF6",
        accentColor: "F472B6",
        successColor: "22C55E",
        warningColor: "EAB308",
        errorColor: "DC2626"
    )

    static let defaultThemes = [mysticPurple, deepOcean, cyberpunk]
}

// MARK: - Theme Manager
@MainActor
@Observable
final class ThemeManager {
    static let shared = ThemeManager()

    private let userDefaultsKey = "selectedThemeId"
    private let customThemesKey = "customThemes"

    var currentTheme: AppTheme
    var customThemes: [AppTheme] = []

    var allThemes: [AppTheme] {
        AppTheme.defaultThemes + customThemes
    }

    private init() {
        // Load saved theme
        if let savedThemeId = UserDefaults.standard.string(forKey: userDefaultsKey),
           let theme = AppTheme.defaultThemes.first(where: { $0.id == savedThemeId }) {
            currentTheme = theme
        } else {
            currentTheme = .mysticPurple
        }

        // Load custom themes
        loadCustomThemes()
    }

    func selectTheme(_ theme: AppTheme) {
        currentTheme = theme
        UserDefaults.standard.set(theme.id, forKey: userDefaultsKey)
    }

    func addCustomTheme(_ theme: AppTheme) {
        customThemes.append(theme)
        saveCustomThemes()
    }

    func deleteCustomTheme(_ theme: AppTheme) {
        customThemes.removeAll { $0.id == theme.id }
        saveCustomThemes()
    }

    private func saveCustomThemes() {
        if let encoded = try? JSONEncoder().encode(customThemes) {
            UserDefaults.standard.set(encoded, forKey: customThemesKey)
        }
    }

    private func loadCustomThemes() {
        if let data = UserDefaults.standard.data(forKey: customThemesKey),
           let decoded = try? JSONDecoder().decode([AppTheme].self, from: data) {
            customThemes = decoded
        }
    }
}

// MARK: - Environment Key
private struct ThemeManagerKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeManagerKey.self] }
        set { self[ThemeManagerKey.self] = newValue }
    }
}
