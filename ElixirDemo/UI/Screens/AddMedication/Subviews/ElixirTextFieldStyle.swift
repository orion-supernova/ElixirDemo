//
//  ElixirTextFieldStyle.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct ElixirTextFieldStyle: TextFieldStyle {
    @Environment(ThemeManager.self) private var themeManager

    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(themeManager.currentTheme.font(for: .body))
            .foregroundColor(themeManager.currentTheme.textPrimary)
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeManager.currentTheme.primaryColor.opacity(0.3), lineWidth: 1)
            )
    }
}
