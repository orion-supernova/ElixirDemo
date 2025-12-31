//
//  CheckmarkButton.swift
//  Elixir: Daily Ritual
//
//  Created by Antigravity on 31.12.2025.
//

import SwiftUI

struct CheckmarkButton: View {
    let status: DoseStatus
    let action: () -> Void
    
    @Environment(ThemeManager.self) private var themeManager
    
    var buttonColor: Color {
        switch status {
        case .taken:
            return themeManager.currentTheme.successColor
        case .pending:
            return themeManager.currentTheme.primaryColor
        case .skipped:
            return .gray
        case .missed:
            return themeManager.currentTheme.errorColor
        }
    }
    
    var iconName: String {
        switch status {
        case .taken:
            return "checkmark.circle.fill"
        case .pending:
            return "circle"
        case .skipped:
            return "xmark.circle.fill"
        case .missed:
            return "exclamationmark.circle.fill"
        }
    }
    
    var body: some View {
        Button(action: {
            hapticFeedback(.medium)
            action()
        }) {
            ZStack {
                Circle()
                    .fill(buttonColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(buttonColor)
                    .symbolEffect(.bounce, value: status)
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
    
    private func hapticFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
