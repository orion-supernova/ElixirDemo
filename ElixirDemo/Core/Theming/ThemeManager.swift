//
//  ThemeManager.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

@MainActor
@Observable
final class ThemeManager {
    static let shared = ThemeManager()
    
    var currentTheme: ThemeProtocol
    private var customThemes: [CustomTheme] = []
    
    private let userDefaultsKey = "selectedThemeId"
    private let customThemesKey = "customThemes_v2"
    
    private let defaultThemes: [ThemeProtocol] = [
        RPGTheme(),
        PlainTheme(),
        CyberpunkTheme(),
        RPGSubTheme(id: "rpg-ocean", displayName: "RPG: Deep Ocean", primaryColor: Color(hex: "0077BE"), secondaryColor: Color(hex: "00C3FF")),
        RPGSubTheme(id: "rpg-forest", displayName: "RPG: Forest", primaryColor: Color(hex: "228B22"), secondaryColor: Color(hex: "32CD32"))
    ]
    
    var availableThemes: [ThemeProtocol] {
        defaultThemes + customThemes
    }
    
    private init() {
        // 1. Create defaults (locally or use the property if it were static, but here we can just init them or trust self.defaultThemes if we handle order).
        // BUT 'defaultThemes' is an instance property. We cannot access 'self.defaultThemes' before full init.
        // We will duplicate the literal list or make it static. Making it static or lazy is better?
        // Let's just define the default list locally for init to use, and also have the property.
        
        // Actually, simplest fix: initialize properties first with temp values, then configure.
        // OR better: use local variables for everything.
        
        let defaults: [ThemeProtocol] = [
            RPGTheme(),
            PlainTheme(),
            CyberpunkTheme(),
            RPGSubTheme(id: "rpg-ocean", displayName: "RPG: Deep Ocean", primaryColor: Color(hex: "0077BE"), secondaryColor: Color(hex: "00C3FF")),
            RPGSubTheme(id: "rpg-forest", displayName: "RPG: Forest", primaryColor: Color(hex: "228B22"), secondaryColor: Color(hex: "32CD32"))
        ]
        
        // 2. Load custom themes into a local var
        var loadedCustomThemes: [CustomTheme] = []
        if let data = UserDefaults.standard.data(forKey: "customThemes_v2"),
           let decoded = try? JSONDecoder().decode([CustomTheme].self, from: data) {
            loadedCustomThemes = decoded
        }
        
        // 3. Assign to self stored properties
        self.customThemes = loadedCustomThemes
        // self.defaultThemes is already initialized by the default value expression above
        
        // 4. Determine current theme
        let savedId = UserDefaults.standard.string(forKey: "selectedThemeId") ?? "rpg-default"
        let all = defaults + loadedCustomThemes
        self.currentTheme = all.first(where: { $0.id == savedId }) ?? RPGTheme()
    }
    
    func setTheme(id: String) {
        if let theme = availableThemes.first(where: { $0.id == id }) {
            withAnimation(.easeInOut) {
                currentTheme = theme
            }
            UserDefaults.standard.set(id, forKey: userDefaultsKey)
        }
    }
    
    func addCustomTheme(_ theme: CustomTheme) {
        customThemes.append(theme)
        saveCustomThemes()
        // Automatically select the new theme
        setTheme(id: theme.id)
    }
    
    func deleteCustomTheme(id: String) {
        customThemes.removeAll { $0.id == id }
        saveCustomThemes()
        
        // If deleted theme was active, revert to default
        if currentTheme.id == id {
            setTheme(id: "rpg-default")
        }
    }
    
    private func saveCustomThemes() {
        if let encoded = try? JSONEncoder().encode(customThemes) {
            UserDefaults.standard.set(encoded, forKey: customThemesKey)
        }
    }
}
