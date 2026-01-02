//
//  FallbackView.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct NotificationFallbackView: View {
    let content: UNNotificationContent
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: Spacing.lg) {
            Image(systemName: "bell.fill")
                .font(.system(size: 60))
                .foregroundColor(.white)

            Text(content.title)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(content.body)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)

            Button("Dismiss") {
                onDismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(hex: "1C1C1E"))
        )
        .padding(Spacing.xl)
    }
}
