//
//  ThemeProtocol.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

/// Defines the blueprint for all themes in the application.
protocol ThemeProtocol: Identifiable {
    var id: String { get }
    var displayName: String { get }
    var isCustom: Bool { get }
    
    // MARK: - Color Palette
    var primaryColor: Color { get }
    var secondaryColor: Color { get }
    var accentColor: Color { get }
    var backgroundColor: Color { get }
    var surfaceColor: Color { get }
    
    // MARK: - Semantic Colors
    var successColor: Color { get }
    var warningColor: Color { get }
    var errorColor: Color { get }
    var textPrimary: Color { get }
    var textSecondary: Color { get }
    
    // MARK: - Gradients
    var backgroundGradient: LinearGradient { get }
    var primaryGradient: LinearGradient { get }
    
    // MARK: - Typography
    func font(for style: Font.TextStyle) -> Font
    
    // MARK: - UI Configuration
    var cornerRadius: CGFloat { get }
    var buttonScale: CGFloat { get }
}

extension ThemeProtocol {
    // Default values
    var isCustom: Bool { false }
    var cornerRadius: CGFloat { 16.0 }
    var buttonScale: CGFloat { 0.95 }
    
    var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundColor, backgroundColor.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    var primaryGradient: LinearGradient {
        LinearGradient(
            colors: [primaryColor, secondaryColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    func font(for style: Font.TextStyle) -> Font {
        switch style {
        case .largeTitle: return .system(size: 34, weight: .bold, design: .rounded)
        case .title: return .system(size: 28, weight: .bold, design: .rounded)
        case .title2: return .system(size: 22, weight: .semibold, design: .rounded)
        case .title3: return .system(size: 20, weight: .semibold, design: .rounded)
        case .headline: return .system(size: 17, weight: .semibold, design: .rounded)
        case .body: return .system(size: 17, weight: .regular, design: .rounded)
        case .callout: return .system(size: 16, weight: .regular, design: .rounded)
        case .subheadline: return .system(size: 15, weight: .medium, design: .rounded)
        case .footnote: return .system(size: 13, weight: .regular, design: .rounded)
        case .caption: return .system(size: 12, weight: .regular, design: .rounded)
        default: return .system(style, design: .rounded)
        }
    }
}
