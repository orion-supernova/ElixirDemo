//
//  EveryOtherDaySection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct EveryOtherDaySection: View {
    @Environment(ThemeManager.self) private var themeManager
    @Bindable var viewModel: AddMedicationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Start Day")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            HStack(spacing: Spacing.sm) {
                Button(action: {
                    viewModel.startDayOffset = 0
                }) {
                    Text("Today")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(viewModel.startDayOffset == 0 ? .white : themeManager.currentTheme.textPrimary)
                        .padding(.vertical, Spacing.sm)
                        .padding(.horizontal, Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.startDayOffset == 0 ?
                                      themeManager.currentTheme.primaryColor : Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.startDayOffset == 0 ?
                                        Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                        )
                }

                Button(action: {
                    viewModel.startDayOffset = 1
                }) {
                    Text("Tomorrow")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(viewModel.startDayOffset == 1 ? .white : themeManager.currentTheme.textPrimary)
                        .padding(.vertical, Spacing.sm)
                        .padding(.horizontal, Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.startDayOffset == 1 ?
                                      themeManager.currentTheme.primaryColor : Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(viewModel.startDayOffset == 1 ?
                                        Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                        )
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

    EveryOtherDaySection(viewModel: viewModel)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
