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
        MenuItem(tab: .hydration, icon: "drop.fill", label: "Hydration"),
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
                        .fill(themeManager.currentTheme.primaryColor)
                        .frame(width: 56, height: 56)
                        .shadow(
                            color: Color.black.opacity(0.3),
                            radius: 10,
                            x: 0,
                            y: 5
                        )

                    if isExpanded {
                        Image(systemName: "xmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                            .rotationEffect(.degrees(90))
                    } else {
                        // Check if it's a custom theme (fairy)
                        if themeManager.currentTheme.isCustom {
                            Image(systemName: "bird")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: iconNameForCategory())
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            .scaleEffect(isExpanded ? 1.1 : 1.0)
        }
    }
    
    // MARK: - Icon Name Helper
    private func iconNameForCategory() -> String {
        switch themeManager.currentTheme.category {
        case .clean:
            return themeManager.currentTheme.symbols.level
        case .cyberpunk:
            return themeManager.currentTheme.symbols.streak
        case .rpg:
            return themeManager.currentTheme.symbols.streak
        }
    }

    // MARK: - Angle Calculation
    private func angleForIndex(_ index: Int) -> Double {
        // Position items in an arc from Top to Right (since button is Bottom-Left)
        // -90 = Top, 0 = Right.
        let totalItems = Double(menuItems.count)
        let startAngle = -90.0 // Top
        let endAngle = 0.0     // Right
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
                              themeManager.currentTheme.primaryColor :
                              Color.white.opacity(0.2)
                        )
                        .frame(width: 56, height: 56)

                    if !isSelected {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            .frame(width: 56, height: 56)
                    }

                    Image(systemName: item.icon)
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                }
                .shadow(
                    color: isSelected ?
                    themeManager.currentTheme.primaryColor.opacity(0.5) :
                        Color.black.opacity(0.3),
                    radius: 10,
                    x: 0,
                    y: 5
                )

                Text(item.label)
                    .font(themeManager.currentTheme.font(for: .caption))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
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
    case hydration = "Hydration"
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
