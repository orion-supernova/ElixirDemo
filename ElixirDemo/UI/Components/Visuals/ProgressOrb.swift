//
//  ProgressOrb.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct ProgressOrb: View {
    let progress: Double // 0.0 to 1.0
    let totalDoses: Int
    let takenDoses: Int
    let size: CGFloat
    
    @Environment(ThemeManager.self) private var themeManager
    @State private var animatedProgress: Double = 0
    
    init(
        progress: Double,
        totalDoses: Int,
        takenDoses: Int,
        size: CGFloat = 220
    ) {
        self.progress = min(max(progress, 0), 1) // Clamp between 0 and 1
        self.totalDoses = totalDoses
        self.takenDoses = takenDoses
        self.size = size
    }
    
    var body: some View {
        ZStack {
            // Background Circle
            Circle()
                .stroke(
                    Color.white.opacity(0.1),
                    lineWidth: 16
                )
                .frame(width: size, height: size)
            
            // Animated Progress Ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    themeManager.currentTheme.primaryGradient,
                    style: StrokeStyle(
                        lineWidth: 16,
                        lineCap: .round
                    )
                )
                .frame(width: size, height: size)
                .rotationEffect(.degrees(-90))
                .shadow(
                    color: themeManager.currentTheme.primaryColor.opacity(0.6),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            
            // Inner Content
            VStack(spacing: Spacing.sm) {
                // Completion Icon
                if progress >= 1.0 {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(themeManager.currentTheme.successColor)
                        .symbolEffect(.bounce, value: progress)
                } else {
                    Image(systemName: "sparkles")
                        .font(.system(size: 32))
                        .foregroundStyle(themeManager.currentTheme.primaryGradient)
                }
                
                // Progress Percentage
                Text("\(Int(progress * 100))%")
                    .font(themeManager.currentTheme.font(for: .largeTitle))
                    .foregroundStyle(themeManager.currentTheme.primaryGradient)
                
                // Dose Count
                Text("\(takenDoses)/\(totalDoses)")
                    .font(themeManager.currentTheme.font(for: .callout))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                
                Text("Elixirs")
                    .font(themeManager.currentTheme.font(for: .caption))
                    .foregroundColor(themeManager.currentTheme.textSecondary.opacity(0.7))
            }
        }
        .onAppear {
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                animatedProgress = newValue
            }
        }
    }
}
