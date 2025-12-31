//
//  ThemeProtocol.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

// MARK: - Theme Category Hierarchy
enum ThemeCategory: String, CaseIterable, Identifiable, Codable {
    case rpg = "RPG"
    case cyberpunk = "Cyberpunk"
    case clean = "Clean"
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .rpg: return "Fantasy aesthetics with serif fonts and magical effects."
        case .cyberpunk: return "High-contrast neon visuals with tech-inspired fonts."
        case .clean: return "Modern, minimalist iOS native aesthetics."
        }
    }
}

// MARK: - Theme Identifiers
enum ThemeIdentifier: String, CaseIterable {
    case paladin = "rpg-paladin"
    case necromancer = "rpg-necromancer"
    case bloodMage = "rpg-bloodmage"
    case fairy = "rpg-fairy"
    case neonCity = "cyberpunk-neon"
    case matrix = "cyberpunk-matrix"
    case system = "clean-ios"
    case lilac = "clean-lilac"
}

// MARK: - Theme Symbols
struct ThemeSymbols: Codable {
    let check: String
    let uncheck: String
    let streak: String
    let level: String
    let xp: String
    let currency: String
    let health: String
    
    static let rpg = ThemeSymbols(
        check: "shield.fill", 
        uncheck: "shield", 
        streak: "flame.fill", 
        level: "star.fill", 
        xp: "sparkles", 
        currency: "diamond.fill", 
        health: "heart.fill"
    )
    
    static let cyberpunk = ThemeSymbols(
        check: "cpu.fill", 
        uncheck: "cpu", 
        streak: "bolt.fill", 
        level: "antenna.radiowaves.left.and.right", 
        xp: "opticaldisc.fill", 
        currency: "hexagon.fill", 
        health: "heart.fill"
    )
    
    static let clean = ThemeSymbols(
        check: "checkmark.circle.fill", 
        uncheck: "circle", 
        streak: "chart.line.uptrend.xyaxis", 
        level: "medal.fill", 
        xp: "p.circle.fill", 
        currency: "dollarsign.circle.fill", 
        health: "heart.fill"
    )
    
    static let fairy = ThemeSymbols(
        check: "sparkles", 
        uncheck: "circle.dotted", 
        streak: "bird.fill", 
        level: "crown.fill", 
        xp: "wand.and.stars", 
        currency: "leaf.fill", 
        health: "heart.circle.fill"
    )
}

// MARK: - Theme Protocol
protocol ThemeProtocol: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var category: ThemeCategory { get }
    var isCustom: Bool { get }
    
    // MARK: Typography
    // Custom font name (e.g., "MedievalSharp-Regular"). Nil implies system font.
    var fontName: String? { get }
    var headerFontName: String? { get }
    
    // MARK: Symbols
    var symbols: ThemeSymbols { get }
    
    // MARK: Colors - Palette
    var backgroundGradient: LinearGradient { get }
    
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    
    // Semantic Colors
    var surfaceColor: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    
    var successColor: Color { get }
    var warningColor: Color { get }
    var errorColor: Color { get }
    
    // MARK: UI Metrics
    var cornerRadius: CGFloat { get }
    
    // MARK: Helper for Gradients
    var primaryGradient: LinearGradient { get }
    
    // MARK: Helper for Fonts
    func font(for style: Font.TextStyle) -> Font
}

// MARK: - Default Implementation
extension ThemeProtocol {
    // Default implementation for primary gradient based on colors
    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, secondaryColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // Dynamic Font Loader
    func font(for style: Font.TextStyle) -> Font {
        // Size mapping for standard styles
        let size: CGFloat
        switch style {
        case .largeTitle: size = 34
        case .title: size = 28
        case .title2: size = 22
        case .title3: size = 20
        case .headline: size = 17
        case .body: size = 17
        case .callout: size = 16
        case .subheadline: size = 15
        case .footnote: size = 13
        case .caption: size = 12
        case .caption2: size = 11
        @unknown default: size = 17
        }
        
        // Use custom font if available, otherwise system
        if let customFont = (style == .largeTitle || style == .title || style == .title2 || style == .title3 || style == .headline) ? headerFontName : fontName {
            // Check if it's the Clean theme (which should force system) OR just fallback
            // For now, if fontName is nil, we use standard.
            return Font.custom(customFont, size: size, relativeTo: style)
        } else if let mainFont = fontName {
             return Font.custom(mainFont, size: size, relativeTo: style)
        } else {
            // Clean/System theme
            return Font.system(style, design: .default)
        }
    }
}
