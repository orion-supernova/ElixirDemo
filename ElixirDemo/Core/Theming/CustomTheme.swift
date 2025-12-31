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
    
    // Custom Background Gradient using 3 colors if needed, simplified here to 2 for protocol match
    // For specific 3-color gradient logic in the view, we might need to handle it differently,
    // but here we map to the protocol's requirement.
    // To support the 3-color bg from the old view, let's store 3 bg hexes but protocol only asks for 'backgroundGradient'.
    
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
