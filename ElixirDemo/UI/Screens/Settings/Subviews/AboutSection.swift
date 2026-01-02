//
//  AboutSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct AboutSection: View {
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("About")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            VStack(spacing: 0) {
                SettingsRow(icon: "info.circle.fill", title: "Version", value: appVersion)
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "hammer.fill", title: "Build", value: appBuild)
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "doc.text.fill", title: "Privacy Policy", value: "")
                Divider().background(Color.white.opacity(0.1))
                SettingsRow(icon: "envelope.fill", title: "Support", value: "")
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                    .fill(themeManager.currentTheme.surfaceColor)
            )
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
}

#Preview {
    AboutSection()
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
