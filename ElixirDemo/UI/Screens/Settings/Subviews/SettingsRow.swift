//
//  SettingsRow.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct SettingsRow: View {
    let icon: String
    let title: String
    let value: String

    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .frame(width: 24)

            Text(title)
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            Spacer()

            Text(value)
                .font(themeManager.currentTheme.font(for: .subheadline))
                .foregroundColor(themeManager.currentTheme.textSecondary)

            Image(systemName: "chevron.right")
                .font(.system(size: 12))
                .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
        }
        .padding(.vertical, Spacing.sm)
    }
}

#Preview {
    SettingsRow(
        icon: "info.circle.fill",
        title: "Version",
        value: "1.0.0"
    )
    .environment(ThemeManager.shared)
    .padding()
    .background(Color.black)
}
