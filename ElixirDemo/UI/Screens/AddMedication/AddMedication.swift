//
//  AddMedication.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct AddMedication: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: AddMedicationViewModel?
    @State private var showSuccessAlert = false

    var body: some View {
        ZStack {
            // Background
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            if let vm = viewModel {
                contentView(viewModel: vm)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Add Ritual")
        .alert("Error", isPresented: Binding(
            get: { viewModel?.showError ?? false },
            set: { if !$0 { viewModel?.showError = false } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel?.errorMessage ?? "")
        }
        .alert("Success!", isPresented: $showSuccessAlert) {
            Button("Done") {
                dismiss()
            }
        } message: {
            Text("Your ritual has been added successfully!")
        }
        .onAppear {
            if viewModel == nil {
                viewModel = AddMedicationViewModel(modelContext: modelContext)
            }
        }
    }

    // MARK: - Content View
    @ViewBuilder
    private func contentView(viewModel: AddMedicationViewModel) -> some View {
        ScrollView {
            VStack(spacing: Spacing.lg) {
                // Header
                MedicationHeaderSection()

                // Basic Info
                BasicInfoSection(viewModel: viewModel)

                // Appearance
                AppearanceSection(viewModel: viewModel)

                // Frequency
                FrequencySection(viewModel: viewModel)

                // Every Other Day Options
                if viewModel.selectedFrequency == .everyOtherDay {
                    EveryOtherDaySection(viewModel: viewModel)
                }

                // Weekly Options
                if viewModel.selectedFrequency == .weekly {
                    WeeklySection(viewModel: viewModel)
                }

                // Specific Days Options
                if viewModel.selectedFrequency == .specificDays {
                    SpecificDaysSection(viewModel: viewModel)
                }

                // Schedule Times
                ScheduleSection(viewModel: viewModel)

                // Save Button at end
                MedicationSaveButton(viewModel: viewModel, showSuccessAlert: $showSuccessAlert)
                    .padding(.top, Spacing.md)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.lg)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AddMedication()
            .modelContainer(DataController.preview)
            .environment(ThemeManager.shared)
    }
}
