//
//  MedicationsEmptyStateView.swift
//  Elixir: Daily Ritual
//
//  Created by Claude on 31.12.2025.
//

import SwiftUI

struct MedicationsListEmptyStateView: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: themeManager.currentTheme.symbols.currency)
                .font(.system(size: 64))
                .foregroundColor(themeManager.currentTheme.primaryColor)

            Text("No rituals yet")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            Text("Add your first medication to begin tracking")
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
    }
}

#Preview {
    MedicationsListEmptyStateView()
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
