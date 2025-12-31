//
//  ElixirCard.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct ElixirCard: View {
    let medication: Medication
    let doseLog: DoseLog
    let onCheckmarkTapped: () -> Void
    let onMarkMissed: (() -> Void)?
    let onMarkSkipped: (() -> Void)?

    @Environment(ThemeManager.self) private var themeManager
    @State private var isPressed = false

    init(medication: Medication, doseLog: DoseLog, onCheckmarkTapped: @escaping () -> Void, onMarkMissed: (() -> Void)? = nil, onMarkSkipped: (() -> Void)? = nil) {
        self.medication = medication
        self.doseLog = doseLog
        self.onCheckmarkTapped = onCheckmarkTapped
        self.onMarkMissed = onMarkMissed
        self.onMarkSkipped = onMarkSkipped
    }
    
    var iconColor: Color {
        Color(hex: medication.colorHex)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: doseLog.scheduledTime)
    }

    @ViewBuilder
    var statusIcon: some View {
        switch doseLog.status {
        case .taken:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(themeManager.currentTheme.successColor)
        case .pending:
            Image(systemName: "circle")
                .font(.system(size: 28))
                .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
        case .skipped:
            Image(systemName: "forward.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(themeManager.currentTheme.accentColor)
        case .missed:
            Image(systemName: "exclamationmark.circle.fill")
                .font(.system(size: 28))
                .foregroundColor(themeManager.currentTheme.errorColor)
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Left: Icon
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 56, height: 56)
                
                Image(systemName: medication.iconName)
                    .font(.system(size: 24))
                    .foregroundStyle(iconColor)
            }
            
            // Middle: Info
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.name)
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.8))
                    
                    Text(formattedTime)
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    
                    Text("•")
                        .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.5))
                    
                    Text(medication.dosage)
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                }
            }
            
            Spacer()

            // Right: Status Icon & Menu
            HStack(spacing: Spacing.sm) {
                // Status Icon
                statusIcon

                // Three-dot Menu
                Menu {
                    if doseLog.status != .taken {
                        Button {
                            onCheckmarkTapped()
                        } label: {
                            Label("Mark as Taken", systemImage: "checkmark.circle.fill")
                        }
                    }

                    if doseLog.status == .taken {
                        Button {
                            onCheckmarkTapped()
                        } label: {
                            Label("Mark as Pending", systemImage: "circle")
                        }
                    }

                    if let onMarkSkipped = onMarkSkipped, doseLog.status != .skipped {
                        Button {
                            onMarkSkipped()
                        } label: {
                            Label("Mark as Skipped", systemImage: "forward.fill")
                        }
                    }

                    if let onMarkMissed = onMarkMissed, doseLog.status != .missed {
                        Button(role: .destructive) {
                            onMarkMissed()
                        } label: {
                            Label("Mark as Missed", systemImage: "exclamationmark.triangle.fill")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                .stroke(
                    LinearGradient(
                        colors: [themeManager.currentTheme.primaryColor.opacity(0.5), themeManager.currentTheme.secondaryColor.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: isPressed ? themeManager.currentTheme.primaryColor.opacity(0.5) : Color.black.opacity(0.3),
            radius: isPressed ? 10 : 15,
            x: 0,
            y: isPressed ? 4 : 8
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
        .contentShape(Rectangle())
        .onTapGesture {
            // Tap on main card to toggle taken/pending
            onCheckmarkTapped()

            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isPressed = false
                }
            }
        }
    }
}
