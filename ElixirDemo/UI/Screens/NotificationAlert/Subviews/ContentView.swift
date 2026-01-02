//
//  ContentView.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct NotificationContentView: View {
    @Environment(ThemeManager.self) private var themeManager

    let medication: Medication
    let content: UNNotificationContent
    let appearAnimation: Bool
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: Spacing.xl) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: medication.colorHex).opacity(0.2))
                    .frame(width: 120, height: 120)

                Circle()
                    .stroke(Color(hex: medication.colorHex), lineWidth: 2)
                    .frame(width: 120, height: 120)

                Image(systemName: medication.iconName)
                    .font(.system(size: 60))
                    .foregroundStyle(Color(hex: medication.colorHex))
            }
            .scaleEffect(appearAnimation ? 1 : 0.8)
            .shadow(color: Color(hex: medication.colorHex).opacity(0.5), radius: 20, x: 0, y: 0)

            VStack(spacing: Spacing.md) {
                Text(content.title)
                    .font(themeManager.currentTheme.font(for: .title2))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)

                Text(content.body)
                    .font(themeManager.currentTheme.font(for: .body))
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, Spacing.lg)
            }

            Spacer().frame(height: Spacing.xl)

            Button {
                onDismiss()
            } label: {
                Text("Dismiss")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: medication.colorHex))
                    )
            }
            .padding(.horizontal, Spacing.xl)
        }
        .padding(Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color(hex: "1C1C1E"))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(Spacing.xl)
    }
}
