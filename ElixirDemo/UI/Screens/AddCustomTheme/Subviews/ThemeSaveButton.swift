//
//  ThemeSaveButton.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

struct ThemeSaveButton: View {
    @Environment(ThemeManager.self) private var themeManager

    let isEnabled: Bool
    let primaryColor: Color
    let secondaryColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Theme")
            }
            .font(themeManager.currentTheme.font(for: .headline))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                LinearGradient(
                    colors: [primaryColor, secondaryColor],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: primaryColor.opacity(0.5), radius: 20, x: 0, y: 10)
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

#Preview {
    ThemeSaveButton(
        isEnabled: true,
        primaryColor: .purple,
        secondaryColor: .blue,
        action: {}
    )
    .environment(ThemeManager.shared)
    .padding()
    .background(Color.black)
}
