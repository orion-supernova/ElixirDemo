//
//  NameSection.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

struct NameSection: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var themeName: String

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text("Theme Name")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            TextField("e.g., Sunset Vibes", text: $themeName)
                .textFieldStyle(ElixirTextFieldStyle())
        }
    }
}

#Preview {
    NameSection(themeName: .constant("My Theme"))
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
