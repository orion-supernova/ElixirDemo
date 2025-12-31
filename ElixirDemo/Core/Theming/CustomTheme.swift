//
//  CustomTheme.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

struct CustomTheme: ThemeProtocol, Codable, Identifiable {
    let id: String
    let displayName: String
    let isCustom: Bool = true
    
    // New Protocol Requirements
    var category: ThemeCategory = .rpg // Defaulting to RPG for custom themes for now
    var fontName: String? = nil // System font default
    var headerFontName: String? = nil
    var emojis: ThemeEmojis = .rpg // Default emojis
    
    // Stored as Hex Strings for Codable conformance
    let primaryColorHex: String
    let secondaryColorHex: String
    let accentColorHex: String
    let backgroundColorHex: String
    let surfaceColorHex: String
    let successColorHex: String
    let warningColorHex: String
    let errorColorHex: String
    
    var primaryColor: Color { Color(hex: primaryColorHex) }
    var secondaryColor: Color { Color(hex: secondaryColorHex) }
    var accentColor: Color { Color(hex: accentColorHex) }
    var backgroundColor: Color { Color(hex: backgroundColorHex) }
    var surfaceColor: Color { Color(hex: surfaceColorHex) }
    var successColor: Color { Color(hex: successColorHex) }
    var warningColor: Color { Color(hex: warningColorHex) }
    var errorColor: Color { Color(hex: errorColorHex) }
    
    var textPrimary: Color { .white }
    var textSecondary: Color { .white.opacity(0.7) }
    
    // UI Metrics
    var cornerRadius: CGFloat = 16.0
    
    let bgGradientColor1Hex: String
    let bgGradientColor2Hex: String
    let bgGradientColor3Hex: String
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: bgGradientColor1Hex),
                Color(hex: bgGradientColor2Hex),
                Color(hex: bgGradientColor3Hex)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
