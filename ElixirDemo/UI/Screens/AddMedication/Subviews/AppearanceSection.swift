//
//  AppearanceSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct AppearanceSection: View {
    @Environment(ThemeManager.self) private var themeManager
    @Bindable var viewModel: AddMedicationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Appearance")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            VStack(spacing: Spacing.md) {
                // Icon Selection
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Icon")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: Spacing.sm) {
                        ForEach(AddMedicationViewModel.iconOptions, id: \.self) { icon in
                            Button(action: {
                                viewModel.selectedIcon = icon
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(viewModel.selectedIcon == icon ?
                                              Color(hex: viewModel.selectedColor).opacity(0.3) :
                                                Color.white.opacity(0.1))
                                        .frame(width: 44, height: 44)

                                    Image(systemName: icon)
                                        .font(.system(size: 20))
                                        .foregroundColor(viewModel.selectedIcon == icon ?
                                                         Color(hex: viewModel.selectedColor) : .white.opacity(0.6))
                                }
                            }
                        }
                    }
                }

                // Color Selection
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Color")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: Spacing.sm) {
                            ForEach(AddMedicationViewModel.colorOptions, id: \.0) { hex, name in
                                Button(action: {
                                    viewModel.selectedColor = hex
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: hex))
                                            .frame(width: 40, height: 40)

                                        if viewModel.selectedColor == hex {
                                            Circle()
                                                .strokeBorder(Color.white, lineWidth: 3)
                                                .frame(width: 46, height: 46)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    @Previewable @State var viewModel = AddMedicationViewModel(modelContext: DataController.preview.mainContext)

    AppearanceSection(viewModel: viewModel)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
