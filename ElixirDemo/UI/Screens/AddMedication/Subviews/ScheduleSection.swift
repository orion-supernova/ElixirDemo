//
//  ScheduleSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct ScheduleSection: View {
    @Environment(ThemeManager.self) private var themeManager
    @Bindable var viewModel: AddMedicationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Schedule Times")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                Spacer()

                if viewModel.selectedFrequency != .asNeeded {
                    Button(action: {
                        viewModel.addScheduledTime()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(themeManager.currentTheme.primaryGradient)
                            .font(.system(size: 24))
                    }
                }
            }

            if viewModel.scheduledTimes.isEmpty {
                Text("No scheduled times (as needed)")
                    .font(themeManager.currentTheme.font(for: .callout))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                            .fill(.ultraThinMaterial)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(viewModel.scheduledTimes.enumerated()), id: \.offset) { index, time in
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.currentTheme.primaryColor)

                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { time },
                                    set: { viewModel.updateScheduledTime(at: index, to: $0) }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .tint(themeManager.currentTheme.primaryColor)

                            Spacer()

                            if viewModel.scheduledTimes.count > 1 {
                                Button(action: {
                                    viewModel.removeScheduledTime(at: index)
                                }) {
                                    Image(systemName: "trash.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(themeManager.currentTheme.errorColor)
                                        .padding(Spacing.sm)
                                }
                            }
                        }
                        .padding(Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.ultraThinMaterial)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var viewModel = AddMedicationViewModel(modelContext: DataController.preview.mainContext)

    ScheduleSection(viewModel: viewModel)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
