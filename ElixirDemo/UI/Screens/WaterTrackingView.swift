//
//  WaterTrackingView.swift
//  Elixir: Daily Ritual
//
//  A comprehensive, immersive view for tracking daily water intake.
//

import SwiftUI
import SwiftData

struct WaterTrackingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThemeManager.self) private var themeManager
    
    @State private var showingHistory = false
    @State private var showingResetConfirmation = false

    var body: some View {
        ZStack {
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()
            
            WaterTrackingContent(showHistory: $showingHistory, showReset: $showingResetConfirmation)
        }
        .navigationTitle("Hydration")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
            }
        }
        .fullScreenCover(isPresented: $showingHistory) {
            NavigationStack {
                WaterHistoryView()
            }
        }
    }
}

struct WaterTrackingContent: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    
    @Query(sort: \WaterEntry.date, order: .forward) private var entries: [WaterEntry]
    @Query private var waterSettings: [WaterSettings]
    
    @Binding var showHistory: Bool
    @Binding var showReset: Bool
    
    @State private var showingAddConfirmation = false
    @State private var lastAddedAmount: Double = 0
    
    @State private var undoableEntryIDs: [UUID] = []
    
    // Initializers to allow optional bindings if used directly in Dashboard
    init(showHistory: Binding<Bool> = .constant(false), showReset: Binding<Bool> = .constant(false)) {
        self._showHistory = showHistory
        self._showReset = showReset
    }
    
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
                    HStack {
                        Text("Hydration Ritual")
                            .font(themeManager.currentTheme.font(for: .headline))
                            .foregroundColor(themeManager.currentTheme.textPrimary)
                        
                        Spacer()
                        
                        HStack(spacing: Spacing.md) {
                            Button {
                                showHistory = true
                            } label: {
                                Image(systemName: "calendar")
                                    .font(.system(size: 18))
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                                    .padding(8)
                                    .background(themeManager.currentTheme.primaryColor.opacity(0.1))
                                    .clipShape(Circle())
                            }
                            
                            Button {
                                showReset = true
                            } label: {
                                Image(systemName: "trash")
                                    .font(.system(size: 18))
                                    .foregroundColor(themeManager.currentTheme.errorColor)
                                    .padding(8)
                                    .background(themeManager.currentTheme.errorColor.opacity(0.1))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    HStack(spacing: Spacing.md) {
                        AddWaterButton(amount: 0.05, label: "Sip", icon: "mouth.fill") { addWater(0.05) }
                        AddWaterButton(amount: 0.2, label: "200ml", icon: "cup.and.saucer.fill") { addWater(0.2) }
                        AddWaterButton(amount: 0.5, label: "500ml", icon: "drop.fill") { addWater(0.5) }
                        AddWaterButton(amount: 0.75, label: "750ml", icon: "mug.fill") { addWater(0.75) }
                    }
                    
                    // Undo Functionality
                    if !undoableEntryIDs.isEmpty {
                        Button(action: decreaseWater) {
                            HStack {
                                Image(systemName: "arrow.uturn.backward.circle.fill")
                                Text("Undo Last Entry (\(undoableEntryIDs.count))")
                            }
                            .font(themeManager.currentTheme.font(for: .callout))
                            .foregroundColor(themeManager.currentTheme.errorColor.opacity(0.8))
                            .padding(.top, Spacing.sm)
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
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
        .onDisappear {
            undoableEntryIDs.removeAll()
        }
        .alert("Reset Today's Water?", isPresented: $showReset) {
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
            
            // Liquid Shape with TimelineView for guaranteed animation
            TimelineView(.animation) { timeline in
                let now = timeline.date.timeIntervalSinceReferenceDate
                let angle = Angle(degrees: now.remainder(dividingBy: 2) * 180) // 2 second cycle
                
                GeometryReader { geo in
                    let size = geo.size
                    WaveShape(offset: angle, percent: progress)
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
            }
            .mask(Circle())
        }
    }
    
    private func addWater(_ amount: Double) {
        let entry = WaterEntry(amountLiters: amount)
        modelContext.insert(entry)
        lastAddedAmount = amount
        
        withAnimation {
            showingAddConfirmation = true
            undoableEntryIDs.append(entry.id)
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        try? modelContext.save()
        
        // Timer to remove this specific ID after 30 seconds
        let idToRemove = entry.id
        Task {
            try? await Task.sleep(nanoseconds: 30 * 1_000_000_000)
            withAnimation {
                undoableEntryIDs.removeAll(where: { $0 == idToRemove })
            }
        }
    }
    
    private func decreaseWater() {
        guard let lastID = undoableEntryIDs.last else { return }
        
        // Find the specific entry to delete
        let calendar = Calendar.current
        let todayEntries = entries.filter { calendar.isDateInToday($0.date) }
        
        if let entryToDelete = todayEntries.first(where: { $0.id == lastID }) {
            modelContext.delete(entryToDelete)
            try? modelContext.save()
            
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            withAnimation {
                undoableEntryIDs.removeLast()
            }
        } else {
            // Fallback: if ID not found but undo was possible, remove last entry from model anyway
            if let lastEntry = todayEntries.last {
                modelContext.delete(lastEntry)
                try? modelContext.save()
                withAnimation { undoableEntryIDs.removeLast() }
            }
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
