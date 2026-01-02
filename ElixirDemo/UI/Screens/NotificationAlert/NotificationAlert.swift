//
//  NotificationAlert.swift
//  Elixir: Daily Ritual
//
//  Full screen alert for foreground notifications
//

import SwiftUI
import SwiftData

struct NotificationAlert: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager

    // We observe the state to get the ID, but we fetch from context
    let medicationId: UUID
    let content: UNNotificationContent

    @Query private var medications: [Medication]

    private var medication: Medication? {
        medications.first { $0.id == medicationId }
    }

    @State private var appearAnimation = false

    var body: some View {
        ZStack {
            // Blurred Background
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            // Dark Overlay
            Color.black.opacity(0.6)
                .ignoresSafeArea()

            if let medication = medication {
                NotificationContentView(
                    medication: medication,
                    content: content,
                    appearAnimation: appearAnimation,
                    onDismiss: dismiss
                )
                .transition(.scale(scale: 0.9).combined(with: .opacity))
            } else {
                // Fallback if medication not found (deleted?)
                NotificationFallbackView(content: content, onDismiss: dismiss)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appearAnimation = true
            }
        }
    }

    private func dismiss() {
        NotificationState.shared.dismiss()
    }
}
