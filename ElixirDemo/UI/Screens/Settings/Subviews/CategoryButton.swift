//
//  CategoryButton.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct CategoryButton: View {
    @Environment(ThemeManager.self) private var themeManager
    let category: ThemeCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(themeManager.currentTheme.font(for: .subheadline))
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(isSelected ? themeManager.currentTheme.textPrimary : themeManager.currentTheme.textSecondary)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? themeManager.currentTheme.primaryColor : themeManager.currentTheme.surfaceColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.currentTheme.primaryColor.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
                )
        }
    }
}

#Preview {
    CategoryButton(
        category: .rpg,
        isSelected: true,
        action: {}
    )
    .environment(ThemeManager.shared)
    .padding()
    .background(Color.black)
}
