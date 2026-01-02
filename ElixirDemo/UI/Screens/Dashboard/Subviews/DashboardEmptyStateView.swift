//
//  DashboardEmptyStateView.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct DashboardEmptyStateView: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(spacing: Spacing.md) {
            Image(systemName: themeManager.currentTheme.symbols.currency)
                .font(.system(size: 64))
                .foregroundColor(themeManager.currentTheme.primaryColor)

            Text("No rituals scheduled")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            Text("Add your first medication to begin your journey")
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .multilineTextAlignment(.center)

            HStack {
                Image(systemName: themeManager.currentTheme.symbols.streak)
                    .font(.system(size: 16))
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                Text("Tap the floating button to add your first ritual")
            }
            .font(themeManager.currentTheme.font(for: .callout))
            .foregroundColor(themeManager.currentTheme.textSecondary)
            .padding(.horizontal, Spacing.lg)
            .padding(.vertical, Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.xxl)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    DashboardEmptyStateView()
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
