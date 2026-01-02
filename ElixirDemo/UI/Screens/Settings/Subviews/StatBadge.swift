//
//  StatBadge.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct StatBadge: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    var action: (() -> Void)? = nil

    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        Button(action: { action?() }) {
            VStack(spacing: Spacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)

                Text(value)
                    .font(themeManager.currentTheme.font(for: .title2))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                Text(label)
                    .font(themeManager.currentTheme.font(for: .caption))
                    .foregroundColor(themeManager.currentTheme.textSecondary)

                if action != nil {
                    Image(systemName: "info.circle")
                        .font(.system(size: 10))
                        .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
                        .padding(.top, 2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StatBadge(
        value: "7",
        label: "Streak",
        icon: "flame.fill",
        color: .orange,
        action: {}
    )
    .environment(ThemeManager.shared)
    .padding()
    .background(Color.black)
}
