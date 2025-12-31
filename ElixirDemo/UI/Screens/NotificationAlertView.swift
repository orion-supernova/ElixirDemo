//
//  NotificationAlertView.swift
//  Elixir: Daily Ritual
//
//  Full screen alert for foreground notifications
//

import SwiftUI
import SwiftData

struct NotificationAlertView: View {
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
                contentView(for: medication)
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            } else {
                // Fallback if medication not found (deleted?)
                fallbackView
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                appearAnimation = true
            }
        }
    }
    
    // MARK: - Main Content
    @ViewBuilder
    private func contentView(for medication: Medication) -> some View {
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
                dismiss()
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
    
    // MARK: - Fallback
    @ViewBuilder
    private var fallbackView: some View {
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
                dismiss()
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
    
    private func dismiss() {
        NotificationState.shared.dismiss()
    }
}
