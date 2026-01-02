//
//  ThemeVariantCard.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct ThemeVariantCard: View {
    @Environment(ThemeManager.self) private var themeManager
    let theme: ThemeProtocol
    let isSelected: Bool
    let onSelect: () -> Void
    let onDelete: (() -> Void)?

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: Spacing.sm) {
                // Mini Preview
                HStack(spacing: 0) {
                    Rectangle().fill(theme.primaryColor)
                    Rectangle().fill(theme.secondaryColor)
                    Rectangle().fill(theme.accentColor)
                }
                .frame(height: 60)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? .white : Color.clear, lineWidth: 2)
                )

                HStack {
                    Text(theme.displayName)
                        .font(themeManager.currentTheme.font(for: .caption))
                        .foregroundColor(themeManager.currentTheme.textPrimary)

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }

                    if let onDelete = onDelete {
                        Button(action: onDelete) {
                            Image(systemName: "trash.fill")
                                .foregroundColor(themeManager.currentTheme.errorColor)
                        }
                    }
                }
            }
            .padding(Spacing.sm)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.currentTheme.surfaceColor)
                    .shadow(color: isSelected ? theme.primaryColor.opacity(0.4) : Color.clear, radius: 10)
            )
        }
    }
}

#Preview {
    ThemeVariantCard(
        theme: ThemeManager.shared.currentTheme,
        isSelected: true,
        onSelect: {},
        onDelete: nil
    )
    .environment(ThemeManager.shared)
    .padding()
    .background(Color.black)
}
