//
//  PremiumThemes.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

// MARK: - RPG THEMES
struct RPGTheme_Paladin: ThemeProtocol {
    let id = ThemeIdentifier.paladin.rawValue
    let displayName = "Paladin"
    let category: ThemeCategory = .rpg
    let isCustom = false
    
    // Typography: Serif for fantasy feel
    // Using "Times New Roman" as a safe fallback for serif if custom isn't loaded,
    // but ideally we'd bundle "Cinzel" or "MedievalSharp". 
    // For now we use standard serif design.
    var fontName: String? = "Times New Roman" 
    var headerFontName: String? = "Times New Roman"
    
    var symbols: ThemeSymbols = .rpg
    
    // Palette: Royal Blue, Gold, White
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "0F172A"), // Dark Navy
                Color(hex: "1e1b4b"), // Very Dark Navy (Matte)
                Color(hex: "0f172a")  // Slate 900
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var primaryColor: Color = Color(hex: "FFD700") // Pure Gold
    var secondaryColor: Color = Color(hex: "3B82F6") // Royal Blue
    var accentColor: Color = Color(hex: "FCD34D") // Light Gold
    
    var surfaceColor: Color = Color.black.opacity(0.4)
    var textPrimary: Color = .white
    var textSecondary: Color = Color(hex: "94A3B8") // Slate 400
    
    var successColor: Color = Color(hex: "10B981") // Emerald
    var warningColor: Color = Color(hex: "F59E0B") // Amber
    var errorColor: Color = Color(hex: "EF4444") // Red
    
    var cornerRadius: CGFloat = 16
    var notificationMessage: String { "Focus on your ritual, Paladin. A glass of water is clarity for the mind. 🛡️💧" }
}

struct RPGTheme_Necromancer: ThemeProtocol {
    let id = ThemeIdentifier.necromancer.rawValue
    let displayName = "Necromancer"
    let category: ThemeCategory = .rpg
    let isCustom = false
    
    var fontName: String? = "Times New Roman"
    var headerFontName: String? = "Times New Roman"
    var symbols: ThemeSymbols = .rpg
    
    // Palette: Dark Slate, Eerie Green
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "020617"), Color(hex: "111827"), Color(hex: "064E3B")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var primaryColor: Color = Color(hex: "10B981") // Eerie Green
    var secondaryColor: Color = Color(hex: "34D399")
    var accentColor: Color = Color(hex: "A7F3D0")
    
    var surfaceColor: Color = Color.black.opacity(0.6)
    var textPrimary: Color = Color(hex: "ECFDF5")
    var textSecondary: Color = Color(hex: "6EE7B7")
    
    var successColor: Color = Color(hex: "059669")
    var warningColor: Color = Color(hex: "D97706")
    var errorColor: Color = Color(hex: "DC2626")
    
    var cornerRadius: CGFloat = 12
    var notificationMessage: String { "The dark path requires focus. Hydrate your vessel, Necromancer. 💀💧" }
}

struct RPGTheme_BloodMage: ThemeProtocol {
    let id = ThemeIdentifier.bloodMage.rawValue
    let displayName = "Blood Mage"
    let category: ThemeCategory = .rpg
    let isCustom = false
    
    var fontName: String? = "Times New Roman"
    var headerFontName: String? = "Times New Roman"
    var symbols: ThemeSymbols = .rpg
    
    // Palette: Charcoal, Crimson
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "18181B"), Color(hex: "450A0A"), Color(hex: "7F1D1D")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var primaryColor: Color = Color(hex: "EF4444") // Crimson
    var secondaryColor: Color = Color(hex: "DC2626")
    var accentColor: Color = Color(hex: "FCA5A5")
    
    var surfaceColor: Color = Color.black.opacity(0.5)
    var textPrimary: Color = .white
    var textSecondary: Color = Color(hex: "FECACA")
    
    var successColor: Color = Color(hex: "22C55E")
    var warningColor: Color = Color(hex: "EAB308")
    var errorColor: Color = Color(hex: "991B1B") // Deep Red
    
    var cornerRadius: CGFloat = 20
    var notificationMessage: String { "Blood requires balance. A vital ritual: drink water, Mage. 🩸💧" }
}

struct RPGTheme_Fairy: ThemeProtocol {
    let id = ThemeIdentifier.fairy.rawValue
    let displayName = "Fae Woods"
    let category: ThemeCategory = .rpg
    let isCustom = false
    
    // Typography: Whimsical but Readable
    var fontName: String? = "Baskerville" 
    var headerFontName: String? = "Baskerville-SemiBold"
    
    var symbols: ThemeSymbols = .fairy
    
    // Palette: Ethereal - Pink/Purple/Teal
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "2e1065"), // Deep Purple
                Color(hex: "4c1d95"), // Violet
                Color(hex: "be185d")  // Pink
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var primaryColor: Color = Color(hex: "f472b6") // Soft Pink
    var secondaryColor: Color = Color(hex: "c084fc") // Lavender
    var accentColor: Color = Color(hex: "2dd4bf") // Teal
    
    var surfaceColor: Color = Color.black.opacity(0.3)
    var textPrimary: Color = Color(hex: "fdf4ff") // Pale Pink White
    var textSecondary: Color = Color(hex: "e879f9") // Stronger Pink
    
    var successColor: Color = Color(hex: "34d399")
    var warningColor: Color = Color(hex: "fcd34d")
    var errorColor: Color = Color(hex: "fb7185")
    
    var cornerRadius: CGFloat = 24 // Very Round
    var notificationMessage: String { "Gentle reminder: a sip of water is a gift to your body, Fae. 🌸💧" }
}

// MARK: - CYBERPUNK THEMES
struct CyberpunkTheme_NeonCity: ThemeProtocol {
    let id = ThemeIdentifier.neonCity.rawValue
    let displayName = "Neon City"
    let category: ThemeCategory = .cyberpunk
    let isCustom = false
    
    // Typography: Mono / Tech
    var fontName: String? = "Courier New"
    var headerFontName: String? = "Courier New"
    var symbols: ThemeSymbols = .cyberpunk
    
    // Palette: Pitch Black, Hot Pink, Cyan
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "050505"), // Deep Black
                Color(hex: "2d001e"), // Dark Magenta
                Color(hex: "000a12")  // Dark Cyan tint
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var primaryColor: Color = Color(hex: "FF0099") // Neon Pink
    var secondaryColor: Color = Color(hex: "00FFEA") // Neon Cyan
    var accentColor: Color = Color(hex: "CCFF00") // Toxic Green
    
    var surfaceColor: Color = Color(hex: "111111").opacity(0.9)
    var textPrimary: Color = .white
    var textSecondary: Color = Color(hex: "00FFFF")
    
    var successColor: Color = Color(hex: "00FF00") // Lime
    var warningColor: Color = Color(hex: "FFFF00")
    var errorColor: Color = Color(hex: "FF0000") // Pure Red
    
    var cornerRadius: CGFloat = 4 // Sharp aesthetic
    var notificationMessage: String { "Neural links stable. Critical update: Hydrate your hardware. ⚡💧" }
}

struct CyberpunkTheme_Matrix: ThemeProtocol {
    let id = ThemeIdentifier.matrix.rawValue
    let displayName = "The Construct"
    let category: ThemeCategory = .cyberpunk
    let isCustom = false
    
    var fontName: String? = "Courier New"
    var headerFontName: String? = "Courier New"
    var symbols: ThemeSymbols = .cyberpunk
    
    // Palette: Digital Green
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "000000"), Color(hex: "001100"), Color(hex: "000000")],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var primaryColor: Color = Color(hex: "00FF41") // Matrix Green
    var secondaryColor: Color = Color(hex: "008F11")
    var accentColor: Color = Color(hex: "0D0208")
    
    var surfaceColor: Color = Color(hex: "001100").opacity(0.8)
    var textPrimary: Color = Color(hex: "00FF41")
    var textSecondary: Color = Color(hex: "008F11")
    
    var successColor: Color = Color(hex: "00FF41")
    var warningColor: Color = Color(hex: "FFFF00")
    var errorColor: Color = Color(hex: "FF0000")
    
    var cornerRadius: CGFloat = 0 // Very Boxy
    var notificationMessage: String { "The Construct demands precision. Initializing hydration protocol. 💹💧" }
    
    var masteryTitles: [Int: String] {
        [
            1: "Terminal 0",
            4: "Buffer",
            8: "Packet",
            13: "Encoder",
            19: "Subroutine",
            26: "Mainframe",
            36: "Root Access",
            51: "Architect",
            76: "Source Code",
            100: "The Architect"
        ]
    }
}

// MARK: - CLEAN THEMES
struct CleanTheme: ThemeProtocol {
    let id = ThemeIdentifier.system.rawValue
    let displayName = "System"
    let category: ThemeCategory = .clean
    let isCustom = false
    
    // Typography: System Default
    var fontName: String? = nil
    var headerFontName: String? = nil
    var symbols: ThemeSymbols = .clean
    
    // Palette: System Adaptive
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: "000000"), Color(hex: "1C1C1E")], // iOS System Backgrounds
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var primaryColor: Color = Color.blue // System Blue
    var secondaryColor: Color = Color.indigo
    var accentColor: Color = Color.teal
    
    var surfaceColor: Color = Color(hex: "1C1C1E").opacity(0.8) // Secondary System Background
    var textPrimary: Color = .white
    var textSecondary: Color = Color(hex: "8E8E93") // System Gray
    
    var successColor: Color = Color.green
    var warningColor: Color = Color.orange
    var errorColor: Color = Color.red
    
    var cornerRadius: CGFloat = 10 // Apple Standard curve
    var notificationMessage: String { "Stay hydrated. A healthy ritual for a balanced day. 💧" }
}

struct CleanTheme_Lilac: ThemeProtocol {
    let id = ThemeIdentifier.lilac.rawValue
    let displayName = "Lilac Dream"
    let category: ThemeCategory = .clean
    let isCustom = false
    
    // Typography: System Default (Clean)
    var fontName: String? = nil
    var headerFontName: String? = nil
    var symbols: ThemeSymbols = .clean
    
    // Palette: White/Lilac Gradient for a stunning light/soft look, or dark lilac.
    // User likes "Stunning". Let's go for a rich, modern Dark Lilac.
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(hex: "1e1b4b"), // Deep Indigo
                Color(hex: "4c1d95"), // Violet 800
                Color(hex: "5b21b6")  // Violet 700
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    var primaryColor: Color = Color(hex: "d8b4fe") // Lavender 300
    var secondaryColor: Color = Color(hex: "a78bfa") // Violet 400
    var accentColor: Color = Color(hex: "c4b5fd") // Violet 300
    
    var surfaceColor: Color = Color.white.opacity(0.1)
    var textPrimary: Color = .white
    var textSecondary: Color = Color(hex: "e9d5ff") // Pale Purple
    
    var successColor: Color = Color(hex: "34d399")
    var warningColor: Color = Color(hex: "fcd34d")
    var errorColor: Color = Color(hex: "fb7185")
    
    var cornerRadius: CGFloat = 16
    var notificationMessage: String { "Dreaming of clarity? A refreshing sip of water awaits. 💜💧" }
}
