//
//  AddMedicationView.swift
//  Elixir: Daily Ritual
//
//  Screen for adding new medications
//

import SwiftUI
import SwiftData

struct AddMedicationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.themeManager) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: AddMedicationViewModel?

    var body: some View {
        ZStack {
            // Background
            themeManager.currentTheme.backgroundGradient.ignoresSafeArea()

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
                headerSection

                // Basic Info
                basicInfoSection(viewModel: viewModel)

                // Appearance
                appearanceSection(viewModel: viewModel)

                // Frequency
                frequencySection(viewModel: viewModel)

                // Schedule Times
                scheduleSection(viewModel: viewModel)

                // Save Button
                saveButton(viewModel: viewModel)
            }
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, 120)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
                .foregroundStyle(Color.elixirGradient)

            Text("Create Your Ritual")
                .ritualFont(.ritualTitle2)
                .foregroundColor(.white)

            Text("Track your medication journey with style")
                .ritualFont(.ritualCallout)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Spacing.lg)
    }

    // MARK: - Basic Info Section
    @ViewBuilder
    private func basicInfoSection(viewModel: AddMedicationViewModel) -> some View {
        @Bindable var vm = viewModel

        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Basic Information")
                .ritualFont(.ritualHeadline)
                .foregroundColor(.white)

            VStack(spacing: Spacing.md) {
                // Medication Name
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Medication Name")
                        .ritualFont(.ritualSubheadline)
                        .foregroundColor(.white.opacity(0.7))

                    TextField("e.g., Vitamin D", text: $vm.medicationName)
                        .textFieldStyle(ElixirTextFieldStyle())
                }

                // Dosage
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Dosage")
                        .ritualFont(.ritualSubheadline)
                        .foregroundColor(.white.opacity(0.7))

                    TextField("e.g., 1000 IU", text: $vm.dosage)
                        .textFieldStyle(ElixirTextFieldStyle())
                }
            }
            .padding(Spacing.md)
            .glassCard()
        }
    }

    // MARK: - Appearance Section
    @ViewBuilder
    private func appearanceSection(viewModel: AddMedicationViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Appearance")
                .ritualFont(.ritualHeadline)
                .foregroundColor(.white)

            VStack(spacing: Spacing.md) {
                // Icon Selection
                VStack(alignment: .leading, spacing: Spacing.sm) {
                    Text("Icon")
                        .ritualFont(.ritualSubheadline)
                        .foregroundColor(.white.opacity(0.7))

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: Spacing.sm) {
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
                        .ritualFont(.ritualSubheadline)
                        .foregroundColor(.white.opacity(0.7))

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
            .padding(Spacing.md)
            .glassCard()
        }
    }

    // MARK: - Frequency Section
    @ViewBuilder
    private func frequencySection(viewModel: AddMedicationViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Frequency")
                .ritualFont(.ritualHeadline)
                .foregroundColor(.white)

            VStack(spacing: Spacing.sm) {
                ForEach(Frequency.allCases, id: \.self) { frequency in
                    Button(action: {
                        viewModel.updateFrequency(frequency)
                    }) {
                        HStack {
                            Image(systemName: viewModel.selectedFrequency == frequency ?
                                  "checkmark.circle.fill" : "circle")
                                .foregroundColor(viewModel.selectedFrequency == frequency ?
                                               .potionPurple : .white.opacity(0.4))

                            Text(frequency.rawValue)
                                .ritualFont(.ritualCallout)
                                .foregroundColor(.white)

                            Spacer()
                        }
                        .padding(Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(viewModel.selectedFrequency == frequency ?
                                      Color.white.opacity(0.1) : Color.clear)
                        )
                    }
                }
            }
            .padding(Spacing.md)
            .glassCard()
        }
    }

    // MARK: - Schedule Section
    @ViewBuilder
    private func scheduleSection(viewModel: AddMedicationViewModel) -> some View {
        @Bindable var vm = viewModel

        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Schedule Times")
                    .ritualFont(.ritualHeadline)
                    .foregroundColor(.white)

                Spacer()

                if vm.selectedFrequency != .asNeeded {
                    Button(action: {
                        vm.addScheduledTime()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(Color.elixirGradient)
                            .font(.system(size: 24))
                    }
                }
            }

            if vm.scheduledTimes.isEmpty {
                Text("No scheduled times (as needed)")
                    .ritualFont(.ritualCallout)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.lg)
                    .glassCard()
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(vm.scheduledTimes.enumerated()), id: \.offset) { index, time in
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(.manaBlue)

                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { time },
                                    set: { vm.updateScheduledTime(at: index, to: $0) }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .colorScheme(.dark)

                            Spacer()

                            if vm.scheduledTimes.count > 1 {
                                Button(action: {
                                    vm.removeScheduledTime(at: index)
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.phoenixRed)
                                }
                            }
                        }
                        .padding(Spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.05))
                        )
                    }
                }
                .padding(Spacing.md)
                .glassCard()
            }
        }
    }

    // MARK: - Save Button
    @ViewBuilder
    private func saveButton(viewModel: AddMedicationViewModel) -> some View {
        Button(action: {
            if viewModel.saveMedication() {
                dismiss()
            }
        }) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                Text("Save Ritual")
            }
            .ritualFont(.ritualHeadline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(Color.elixirGradient)
            .cornerRadius(16)
            .shadow(color: Color.potionPurple.opacity(0.5), radius: 20, x: 0, y: 10)
        }
    }
}

// MARK: - Custom Text Field Style
struct ElixirTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .ritualFont(.ritualBody)
            .foregroundColor(.white)
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.potionPurple.opacity(0.3), lineWidth: 1)
            )
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        AddMedicationView()
            .modelContainer(DataController.preview)
    }
}
