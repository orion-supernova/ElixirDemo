//
//  MedicationHeaderSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct MedicationHeaderSection: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(spacing: Spacing.sm) {
            // Use different symbols for different themes
            Group {
                Image(systemName: themeManager.currentTheme.symbols.currency)
                    .font(.system(size: 56))
                    .foregroundStyle(themeManager.currentTheme.primaryGradient)
            }

            Text("Create Your Ritual")
                .font(themeManager.currentTheme.font(for: .title2))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            Text("Track your medication journey with style")
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
    }
}

#Preview {
    MedicationHeaderSection()
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
