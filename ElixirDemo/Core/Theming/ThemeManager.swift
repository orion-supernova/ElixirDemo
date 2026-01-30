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
    var selectedCategory: ThemeCategory
    
    private var customThemes: [CustomTheme] = []
    
    private let userDefaultsKey = "selectedThemeId"
    private let customThemesKey = "customThemes_v2"
    
    // Default Themes Collection
    private let allDefaultThemes: [ThemeProtocol] = [
        RPGTheme_Paladin(),
        RPGTheme_Necromancer(),
        RPGTheme_BloodMage(),
        RPGTheme_Fairy(),
        CyberpunkTheme_NeonCity(),
        CyberpunkTheme_Matrix(),
        CleanTheme(),
        CleanTheme_Lilac()
    ]
    
    var availableThemes: [ThemeProtocol] {
        allDefaultThemes + customThemes
    }
    
    // Grouped for UI
    var themesByCategory: [ThemeCategory: [ThemeProtocol]] {
        Dictionary(grouping: availableThemes, by: { $0.category })
    }
    
    private init() {
        // 1. Load Custom Themes
        var loadedCustomThemes: [CustomTheme] = []
        if let data = UserDefaults.standard.data(forKey: "customThemes_v2"),
           let decoded = try? JSONDecoder().decode([CustomTheme].self, from: data) {
            loadedCustomThemes = decoded
        }
        self.customThemes = loadedCustomThemes
        
        // 2. Determine Current Theme
        let all = allDefaultThemes + loadedCustomThemes
        let savedId = UserDefaults.standard.string(forKey: userDefaultsKey) ?? ThemeIdentifier.system.rawValue
        
        // Fallback to System/Clean if saved ID is invalid
        let validTheme = all.first(where: { $0.id == savedId }) ?? CleanTheme()
        self.currentTheme = validTheme
        self.selectedCategory = validTheme.category
    }
    
    func setTheme(id: String) {
        if let theme = availableThemes.first(where: { $0.id == id }) {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                currentTheme = theme
                selectedCategory = theme.category
            }
            UserDefaults.standard.set(id, forKey: userDefaultsKey)
            
            NotificationCenter.default.post(name: .themeChanged, object: nil)
        }
    }
    
    func addCustomTheme(_ theme: CustomTheme) {
        customThemes.append(theme)
        saveCustomThemes()
        // Automatically select
        setTheme(id: theme.id)
    }
    
    func deleteCustomTheme(id: String) {
        customThemes.removeAll { $0.id == id }
        saveCustomThemes()
        
        // If active, revert to default
        if currentTheme.id == id {
            setTheme(id: ThemeIdentifier.paladin.rawValue)
        }
    }
    
    private func saveCustomThemes() {
        if let encoded = try? JSONEncoder().encode(customThemes) {
            UserDefaults.standard.set(encoded, forKey: customThemesKey)
        }
    }
}
