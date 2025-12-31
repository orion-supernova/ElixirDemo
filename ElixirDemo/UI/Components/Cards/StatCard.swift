//
//  StatCard.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let iconName: String
    let color: Color
    
    @Environment(ThemeManager.self) private var themeManager
    
    var body: some View {
        VStack(spacing: 8) {
            if iconName.contains(".") {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(color)
            } else {
                Text(iconName)
                    .font(.system(size: 20))
            }
            
            Text(value)
                .font(themeManager.currentTheme.font(for: .title2))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            Text(title)
                .font(themeManager.currentTheme.font(for: .caption))
                .foregroundColor(themeManager.currentTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                .fill(.ultraThinMaterial)
                .stroke(
                    LinearGradient(
                        colors: [.white.opacity(0.1), .white.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}
