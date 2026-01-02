//
//  WeeklySection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct WeeklySection: View {
    @Environment(ThemeManager.self) private var themeManager
    @Bindable var viewModel: AddMedicationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Day of Week")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: Spacing.sm) {
                ForEach(1...7, id: \.self) { weekday in
                    let dayName = weekdayName(for: weekday)
                    Button(action: {
                        viewModel.selectedWeekday = weekday
                    }) {
                        Text(dayName)
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(viewModel.selectedWeekday == weekday ? .white : themeManager.currentTheme.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(viewModel.selectedWeekday == weekday ?
                                          themeManager.currentTheme.primaryColor : Color.white.opacity(0.1))
                            )
                            .overlay(
                                Circle()
                                    .stroke(viewModel.selectedWeekday == weekday ?
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

    private func weekdayName(for weekday: Int) -> String {
        let calendar = Calendar.current
        let symbols = calendar.shortWeekdaySymbols
        return symbols[weekday - 1]
    }
}

#Preview {
    @Previewable @State var viewModel = AddMedicationViewModel(modelContext: DataController.preview.mainContext)

    WeeklySection(viewModel: viewModel)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
