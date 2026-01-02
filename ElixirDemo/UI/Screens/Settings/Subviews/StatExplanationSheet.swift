//
//  StatExplanationSheet.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct StatExplanationSheet: View {
    let detail: StatDetail
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: Spacing.lg) {
                // Handle
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(width: 40, height: 4)
                    .padding(.top, Spacing.sm)

                // Icon & Header
                VStack(spacing: Spacing.md) {
                    ZStack {
                        Circle()
                            .fill(detail.color.opacity(0.1))
                            .frame(width: 80, height: 80)

                        Image(systemName: detail.icon)
                            .font(.system(size: 40))
                            .foregroundColor(detail.color)
                    }

                    Text(detail.title)
                        .font(themeManager.currentTheme.font(for: .title2))
                        .foregroundColor(themeManager.currentTheme.textPrimary)

                    Text(detail.value)
                        .font(themeManager.currentTheme.font(for: .largeTitle))
                        .fontWeight(.bold)
                        .foregroundColor(detail.color)
                }

                Text(detail.description)
                    .font(themeManager.currentTheme.font(for: .body))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, Spacing.xl)

                Spacer()

                Button(action: { dismiss() }) {
                    Text("Understood")
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeManager.currentTheme.primaryGradient)
                        .cornerRadius(12)
                }
                .padding(.horizontal, Spacing.xl)
                .padding(.bottom, Spacing.xl)
            }
        }
        .presentationDetents([.height(450)])
        .presentationDragIndicator(.hidden)
    }
}
