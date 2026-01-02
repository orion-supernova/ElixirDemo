//
//  AddWaterButton.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct AddWaterButton: View {
    @Environment(ThemeManager.self) private var themeManager
    let amount: Double
    let label: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)

                Text(label)
                    .font(themeManager.currentTheme.font(for: .caption2))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.currentTheme.primaryGradient.opacity(0.8))
                    .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
    }
}

#Preview {
    AddWaterButton(amount: 0.2, label: "200ml", icon: "cup.and.saucer.fill", action: {})
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
