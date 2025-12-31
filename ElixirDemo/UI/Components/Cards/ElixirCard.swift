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
    
    @Environment(ThemeManager.self) private var themeManager
    @State private var isPressed = false
    
    var iconColor: Color {
        Color(hex: medication.colorHex)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: doseLog.scheduledTime)
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
            
            // Right: Checkmark Button
            CheckmarkButton(
                status: doseLog.status,
                action: {
                    onCheckmarkTapped()
                }
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                .fill(.ultraThinMaterial)
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
