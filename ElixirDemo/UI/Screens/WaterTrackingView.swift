//
//  WaterTrackingView.swift
//  Elixir: Daily Ritual
//
//  A comprehensive, immersive view for tracking daily water intake.
//

import SwiftUI
import SwiftData

struct WaterTrackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss
    
    @Query(sort: \WaterEntry.date, order: .forward) private var entries: [WaterEntry]
    @Query private var waterSettings: [WaterSettings]
    
    @State private var waveOffset = Angle(degrees: 0)
    @State private var showingAddConfirmation = false
    @State private var lastAddedAmount: Double = 0
    @State private var showingResetConfirmation = false
    @State private var showingHistory = false
    
    private var totalIntakeToday: Double {
        let calendar = Calendar.current
        return entries
            .filter { calendar.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.amountLiters }
    }
    
    private var dailyGoal: Double {
        waterSettings.first?.dailyGoalLiters ?? 2.0
    }
    
    private var progress: Double {
        min(totalIntakeToday / dailyGoal, 1.0)
    }
    
    private var waterStreak: Int {
        let calendar = Calendar.current
        let groupedEntries = Dictionary(grouping: entries) { entry in
            calendar.startOfDay(for: entry.date)
        }
        
        var streak = 0
        var checkDate = calendar.startOfDay(for: Date())
        
        // Check if streak continues from today or yesterday
        if groupedEntries[checkDate] == nil {
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        while groupedEntries[checkDate] != nil {
            streak += 1
            checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
        }
        
        return streak
    }
    
    var body: some View {
        ZStack {
            // Background
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: Spacing.xl) {
                // Liquid Progress
                liquidContainer
                    .frame(height: 350)
                    .padding(.top, Spacing.lg)
                
                // Stats
                HStack(spacing: Spacing.xl) {
                    VStack(spacing: 4) {
                        Text("\(Int(totalIntakeToday * 1000))")
                            .font(themeManager.currentTheme.font(for: .title2))
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                        Text("ml Taken")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }
                    
                    VStack(spacing: 4) {
                        Text("\(waterStreak)")
                            .font(themeManager.currentTheme.font(for: .title2))
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                        Text("Day Streak")
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(themeManager.currentTheme.textSecondary)
                    }
                }
                
                // Controls
                VStack(spacing: Spacing.lg) {
                    Text("Hydration Ritual")
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                    
                    HStack(spacing: Spacing.md) {
                        AddWaterButton(amount: 0.05, label: "Sip", icon: "mouth.fill") { addWater(0.05) }
                        AddWaterButton(amount: 0.2, label: "200ml", icon: "cup.and.saucer.fill") { addWater(0.2) }
                        AddWaterButton(amount: 0.5, label: "500ml", icon: "drop.fill") { addWater(0.5) }
                        AddWaterButton(amount: 0.75, label: "750ml", icon: "mug.fill") { addWater(0.75) }
                    }
                    
                    // Decrease Functionality
                    Button(action: decreaseWater) {
                        HStack {
                            Image(systemName: "minus.circle.fill")
                            Text("Remove Last Entry")
                        }
                        .font(themeManager.currentTheme.font(for: .callout))
                        .foregroundColor(themeManager.currentTheme.errorColor.opacity(0.8))
                        .padding(.top, Spacing.sm)
                    }
                    .disabled(entries.isEmpty)
                }
                
                Spacer()
            }
            .padding(Spacing.md)
            
            // Success Overlay
            if showingAddConfirmation {
                VStack {
                    ZStack {
                        Circle()
                            .fill(themeManager.currentTheme.successColor)
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .transition(.scale.combined(with: .opacity))
                    
                    Text("+\(Int(lastAddedAmount * 1000))ml added")
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(.white)
                        .padding(.top, 8)
                }
                .padding(24)
                .background(Color.black.opacity(0.7))
                .cornerRadius(20)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        withAnimation {
                            showingAddConfirmation = false
                        }
                    }
                }
                .zIndex(10)
            }
        }
        .navigationTitle("Hydration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
            
            ToolbarItem(placement: .topBarLeading) {
                HStack {
                    Button {
                        showingHistory = true
                    } label: {
                        Image(systemName: "calendar")
                            .foregroundColor(themeManager.currentTheme.primaryColor)
                    }
                    
                    Button(role: .destructive) {
                        showingResetConfirmation = true
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(themeManager.currentTheme.errorColor)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showingHistory) {
            NavigationStack {
                WaterHistoryView()
            }
        }
        .alert("Reset Today's Water?", isPresented: $showingResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) { resetTodayWater() }
        } message: {
            Text("This will clear all water entries for today. Are you sure?")
        }
    }
    
    private var liquidContainer: some View {
        ZStack {
            // Circle Background
            Circle()
                .fill(Color.white.opacity(0.1))
                .overlay(
                    Circle()
                        .stroke(themeManager.currentTheme.primaryColor.opacity(0.3), lineWidth: 4)
                )
            
            // Progress Text
            VStack {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                Text("Goal: \(String(format: "%.1f", dailyGoal))L")
                    .font(themeManager.currentTheme.font(for: .callout))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
            }
            .zIndex(2)
            
            // Liquid Shape
            GeometryReader { geo in
                let size = geo.size
                WaveShape(offset: waveOffset, percent: progress)
                    .fill(
                        LinearGradient(
                            colors: [
                                themeManager.currentTheme.primaryColor.opacity(0.8),
                                themeManager.currentTheme.secondaryColor.opacity(0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: size.width, height: size.height)
            }
            .mask(Circle())
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                waveOffset = Angle(degrees: 360)
            }
        }
    }
    
    private func addWater(_ amount: Double) {
        let entry = WaterEntry(amountLiters: amount)
        modelContext.insert(entry)
        lastAddedAmount = amount
        
        withAnimation {
            showingAddConfirmation = true
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        try? modelContext.save()
    }
    
    private func decreaseWater() {
        let calendar = Calendar.current
        let todayEntries = entries.filter { calendar.isDateInToday($0.date) }
        
        if let lastEntry = todayEntries.last {
            modelContext.delete(lastEntry)
            try? modelContext.save()
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    private func resetTodayWater() {
        let calendar = Calendar.current
        let todayEntries = entries.filter { calendar.isDateInToday($0.date) }
        
        for entry in todayEntries {
            modelContext.delete(entry)
        }
        try? modelContext.save()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
}

// WaveShape and AddWaterButton remain the same or slightly adjusted for width
struct WaveShape: Shape {
    var offset: Angle
    var percent: Double
    
    var animatableData: Double {
        get { offset.degrees }
        set { offset = Angle(degrees: newValue) }
    }
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let lowThreshold = 0.01
        let highThreshold = 0.99
        
        let waveHeight = 0.015 * rect.height
        let yOffset = CGFloat(1 - percent) * rect.height
        
        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: yOffset))
        
        if percent < lowThreshold {
            path.addLine(to: CGPoint(x: rect.width, y: yOffset))
        } else if percent > highThreshold {
            path.addLine(to: CGPoint(x: rect.width, y: yOffset))
        } else {
            for x in stride(from: 0, through: rect.width, by: 1) {
                let relativeX = x / rect.width
                let sine = sin(relativeX * .pi * 2 + offset.radians)
                let y = yOffset + sine * waveHeight
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}

struct AddWaterButton: View {
    @Environment(ThemeManager.self) private var themeManager
    let amount: Double
    let label: String
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(themeManager.currentTheme.font(for: .caption2))
                    .foregroundColor(.white.opacity(0.8))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 70)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.currentTheme.primaryGradient.opacity(0.8))
                    .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)
            )
        }
    }
}

#Preview {
    WaterTrackingView()
        .environment(ThemeManager.shared)
        .modelContainer(DataController.preview)
}
