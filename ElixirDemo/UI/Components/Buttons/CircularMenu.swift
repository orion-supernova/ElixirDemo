//
//  CircularMenu.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct CircularMenu: View {
    @Environment(ThemeManager.self) private var themeManager
    @Binding var selectedTab: AppTab
    @State private var isExpanded = false
    
    let menuItems: [MenuItem] = [
        MenuItem(tab: .dashboard, icon: "house.fill", label: "Dashboard"),
        MenuItem(tab: .add, icon: "plus.circle.fill", label: "Add"),
        MenuItem(tab: .settings, icon: "gearshape.fill", label: "Settings")
    ]
    
    var body: some View {
        ZStack {
            // Menu Items
            if isExpanded {
                ForEach(Array(menuItems.enumerated()), id: \.element.tab) { index, item in
                    MenuButton(
                        item: item,
                        isSelected: selectedTab == item.tab,
                        angle: angleForIndex(index),
                        onTap: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                                selectedTab = item.tab
                                isExpanded = false
                            }
                        }
                    )
                    .transition(.scale.combined(with: .opacity))
                }
            }
            
            // Main Button
            Button(action: {
                hapticFeedback()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                    isExpanded.toggle()
                }
            }) {
                ZStack {
                    Circle()
                        .fill(themeManager.currentTheme.primaryGradient)
                        .frame(width: 64, height: 64)
                        .shadow(
                            color: themeManager.currentTheme.primaryColor.opacity(0.6),
                            radius: 20,
                            x: 0,
                            y: 10
                        )
                    
                    Image(systemName: isExpanded ? "xmark" : "sparkles")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
            }
            .scaleEffect(isExpanded ? 1.1 : 1.0)
        }
    }
    
    // MARK: - Angle Calculation
    private func angleForIndex(_ index: Int) -> Double {
        // Position items on the RIGHT side of the button
        // -45° = top-right, 0° = right, 45° = bottom-right
        let totalItems = Double(menuItems.count)
        let startAngle = -45.0  // Top-right
        let endAngle = 45.0     // Bottom-right
        let angleRange = endAngle - startAngle
        
        if totalItems == 1 {
            return 0.0 // Single item goes straight right
        }
        
        let step = angleRange / (totalItems - 1)
        return startAngle + (step * Double(index))
    }
    
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
}

// MARK: - Menu Button
struct MenuButton: View {
    @Environment(ThemeManager.self) private var themeManager
    let item: MenuItem
    let isSelected: Bool
    let angle: Double
    let onTap: () -> Void
    
    private let radius: CGFloat = 100
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(isSelected ?
                              themeManager.currentTheme.primaryGradient :
                                LinearGradient(
                                    colors: [Color.white.opacity(0.2)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                        )
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: item.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .shadow(
                    color: isSelected ?
                    themeManager.currentTheme.primaryColor.opacity(0.5) :
                        Color.black.opacity(0.2),
                    radius: 10,
                    x: 0,
                    y: 5
                )
                
                Text(item.label)
                    .font(themeManager.currentTheme.font(for: .caption))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
            }
        }
        .offset(x: cos(angle * .pi / 180) * radius,
                y: sin(angle * .pi / 180) * radius)
    }
}

// MARK: - Menu Item Model
struct MenuItem: Identifiable {
    let id = UUID()
    let tab: AppTab
    let icon: String
    let label: String
}

// MARK: - App Tab Enum
enum AppTab: String, CaseIterable {
    case dashboard = "Dashboard"
    case add = "Add Ritual"
    case settings = "Settings"
}

// MARK: - Preview
#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        
        CircularMenu(selectedTab: .constant(.dashboard))
            .environment(ThemeManager.shared)
    }
}
