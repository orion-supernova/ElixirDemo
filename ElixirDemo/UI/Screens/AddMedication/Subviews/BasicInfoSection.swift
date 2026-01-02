//
//  BasicInfoSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct BasicInfoSection: View {
    @Environment(ThemeManager.self) private var themeManager
    @Bindable var viewModel: AddMedicationViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Basic Information")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            VStack(spacing: Spacing.md) {
                // Medication Name
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Medication Name")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)

                    TextField("e.g., Vitamin D", text: $viewModel.medicationName)
                        .textFieldStyle(ElixirTextFieldStyle())
                }

                // Dosage
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Dosage")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)

                    HStack(spacing: Spacing.sm) {
                        TextField("Amount", text: $viewModel.dosageAmount)
                            .textFieldStyle(ElixirTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .frame(maxWidth: .infinity)

                        Menu {
                            ForEach(AddMedicationViewModel.dosageUnits, id: \.self) { unit in
                                Button(unit) {
                                    viewModel.dosageUnit = unit
                                }
                            }
                        } label: {
                            HStack {
                                Text(viewModel.dosageUnit)
                                    .font(themeManager.currentTheme.font(for: .body))
                                    .foregroundColor(themeManager.currentTheme.textPrimary)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(themeManager.currentTheme.textSecondary)
                            }
                            .padding(Spacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.white.opacity(0.1))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.currentTheme.primaryColor.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }

                // Start Date
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Start Date")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)

                    DatePicker("", selection: $viewModel.startDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(themeManager.currentTheme.primaryColor)
                }

                // End Date Toggle
                Toggle("Set End Date", isOn: $viewModel.hasEndDate)
                    .font(themeManager.currentTheme.font(for: .subheadline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                    .tint(themeManager.currentTheme.primaryColor)

                if viewModel.hasEndDate {
                    DatePicker("", selection: $viewModel.endDate, in: viewModel.startDate..., displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(themeManager.currentTheme.primaryColor)
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

    BasicInfoSection(viewModel: viewModel)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
