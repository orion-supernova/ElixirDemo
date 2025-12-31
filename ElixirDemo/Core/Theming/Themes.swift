//
//  Themes.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

// MARK: - RPG Theme
struct RPGTheme: ThemeProtocol {
    let id = "rpg-default"
    let displayName = "RPG: Mystic"
    
    var primaryColor: Color { Color(hex: "8E44AD") } // Potion Purple
    var secondaryColor: Color { Color(hex: "3498DB") } // Mana Blue
    var accentColor: Color { Color(hex: "F1C40F") } // Gold
    var backgroundColor: Color { Color(hex: "2C3E50") } // Dark Slate
    var surfaceColor: Color { Color(hex: "34495E") } // Midnight Blue
    
    var successColor: Color { Color(hex: "27AE60") }
    var warningColor: Color { Color(hex: "E67E22") }
    var errorColor: Color { Color(hex: "C0392B") }
    
    var textPrimary: Color { .white }
    var textSecondary: Color { .white.opacity(0.7) }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "1A1A2E"), Color(hex: "16213E")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

struct RPGSubTheme: ThemeProtocol {
    let id: String
    let displayName: String
    let primaryColor: Color
    let secondaryColor: Color
    var accentColor: Color { Color(hex: "F1C40F") }
    var backgroundColor: Color { Color(hex: "2C3E50") }
    var surfaceColor: Color { Color(hex: "34495E") }
    var successColor: Color { Color(hex: "27AE60") }
    var warningColor: Color { Color(hex: "E67E22") }
    var errorColor: Color { Color(hex: "C0392B") }
    var textPrimary: Color { .white }
    var textSecondary: Color { .white.opacity(0.7) }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "1A1A2E"), Color(hex: "0F3460")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Plain Theme
struct PlainTheme: ThemeProtocol {
    let id = "plain-default"
    let displayName = "Clean: Light"
    
    var primaryColor: Color { Color(hex: "007AFF") } // System Blue
    var secondaryColor: Color { Color(hex: "5AC8FA") } // System Teal
    var accentColor: Color { Color(hex: "FFCC00") }
    var backgroundColor: Color { Color(hex: "F2F2F7") } // System Grouped Background
    var surfaceColor: Color { .white }
    
    var successColor: Color { Color(hex: "34C759") }
    var warningColor: Color { Color(hex: "FF9500") }
    var errorColor: Color { Color(hex: "FF3B30") }
    
    var textPrimary: Color { .black }
    var textSecondary: Color { .gray }
    
    var cornerRadius: CGFloat { 12.0 }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "F2F2F7"), Color(hex: "FFFFFF")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Cyberpunk Theme
struct CyberpunkTheme: ThemeProtocol {
    let id = "cyberpunk-neon"
    let displayName = "Cyberpunk: Neon City"
    
    var primaryColor: Color { Color(hex: "FF00FF") } // Hot Pink
    var secondaryColor: Color { Color(hex: "00FFFF") } // Cyan
    var accentColor: Color { Color(hex: "FFE600") } // Neon Yellow
    var backgroundColor: Color { .black }
    var surfaceColor: Color { Color(hex: "111111") }
    
    var successColor: Color { Color(hex: "00FF00") } // Lime
    var warningColor: Color { Color(hex: "FF8800") }
    var errorColor: Color { Color(hex: "FF0000") }
    
    var textPrimary: Color { Color(hex: "E0E0E0") }
    var textSecondary: Color { Color(hex: "A0A0A0") }
    
    var cornerRadius: CGFloat { 0.0 } // Sharp edges for cyberpunk
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color.black, Color(hex: "120024")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
