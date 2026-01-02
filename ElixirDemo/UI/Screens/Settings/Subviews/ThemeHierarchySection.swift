//
//  ThemeHierarchySection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct ThemeHierarchySection: View {
    @Environment(ThemeManager.self) private var themeManager

    @Binding var selectedCategoryForDisplay: ThemeCategory
    @Binding var showingAddTheme: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {

            // Title & Custom Button
            HStack {
                Text("Theme Realm")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                Spacer()

                Button(action: {
                    showingAddTheme = true
                }) {
                    Text("New Custom")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }

            // Step 1: Category Selector (Horizontal)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.md) {
                    ForEach(ThemeCategory.allCases) { category in
                        CategoryButton(
                            category: category,
                            isSelected: selectedCategoryForDisplay == category,
                            action: {
                                withAnimation {
                                    selectedCategoryForDisplay = category
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 2)
            }

            // Description of Category
            Text(selectedCategoryForDisplay.description)
                .font(themeManager.currentTheme.font(for: .caption))
                .foregroundColor(themeManager.currentTheme.textSecondary)
                .padding(.vertical, Spacing.xs)

            // Step 2: Variants Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: Spacing.md) {
                if let themes = themeManager.themesByCategory[selectedCategoryForDisplay] {
                    ForEach(themes, id: \.id) { theme in
                        ThemeVariantCard(
                            theme: theme,
                            isSelected: themeManager.currentTheme.id == theme.id,
                            onSelect: {
                                themeManager.setTheme(id: theme.id)
                            },
                            onDelete: theme.isCustom ? {
                                themeManager.deleteCustomTheme(id: theme.id)
                            } : nil
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var selectedCategory: ThemeCategory = .rpg
    @Previewable @State var showingAddTheme = false

    ThemeHierarchySection(
        selectedCategoryForDisplay: $selectedCategory,
        showingAddTheme: $showingAddTheme
    )
    .environment(ThemeManager.shared)
    .padding()
    .background(Color.black)
}
