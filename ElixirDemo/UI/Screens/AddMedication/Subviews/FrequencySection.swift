//
//  FrequencySection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct FrequencySection: View {
    @Environment(ThemeManager.self) private var themeManager
    @Bindable var viewModel: AddMedicationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Frequency")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: Spacing.sm) {
                let displayedFrequencies: [Frequency] = [.daily, .specificDays, .everyOtherDay, .weekly, .asNeeded]
                ForEach(displayedFrequencies, id: \.self) { frequency in
                    Button(action: {
                        viewModel.updateFrequency(frequency)
                    }) {
                        Text(frequency.rawValue)
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(viewModel.selectedFrequency == frequency ?
                                             .white : themeManager.currentTheme.textPrimary)
                            .padding(.vertical, Spacing.sm)
                            .padding(.horizontal, Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.selectedFrequency == frequency ?
                                          themeManager.currentTheme.primaryColor : Color.white.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(viewModel.selectedFrequency == frequency ?
                                            Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                            )
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

    FrequencySection(viewModel: viewModel)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
