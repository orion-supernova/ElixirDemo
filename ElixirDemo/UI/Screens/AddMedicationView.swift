//
//  AddMedicationView.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct AddMedicationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
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
                .foregroundStyle(themeManager.currentTheme.primaryGradient)
            
            Text("Create Your Ritual")
                .font(themeManager.currentTheme.font(for: .title2))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            Text("Track your medication journey with style")
                .font(themeManager.currentTheme.font(for: .callout))
                .foregroundColor(themeManager.currentTheme.textSecondary)
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
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            VStack(spacing: Spacing.md) {
                // Medication Name
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Medication Name")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    
                    TextField("e.g., Vitamin D", text: $vm.medicationName)
                        .textFieldStyle(ElixirTextFieldStyle())
                }
                
                // Dosage
                VStack(alignment: .leading, spacing: Spacing.xs) {
                    Text("Dosage")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    
                    TextField("e.g., 1000 IU", text: $vm.dosage)
                        .textFieldStyle(ElixirTextFieldStyle())
                }
            }
            .padding(Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                    .fill(.ultraThinMaterial)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Appearance Section
    @ViewBuilder
    private func appearanceSection(viewModel: AddMedicationViewModel) -> some View {
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
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(themeManager.currentTheme.textSecondary)
                    
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
            .background(
                RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                    .fill(.ultraThinMaterial)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Frequency Section
    @ViewBuilder
    private func frequencySection(viewModel: AddMedicationViewModel) -> some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Frequency")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)
            
            VStack(spacing: Spacing.sm) {
                ForEach(Frequency.allCases, id: \.self) { frequency in
                    Button(action: {
                        viewModel.updateFrequency(frequency)
                    }) {
                        HStack {
                            Image(systemName: viewModel.selectedFrequency == frequency ?
                                  "checkmark.circle.fill" : "circle")
                            .foregroundColor(viewModel.selectedFrequency == frequency ?
                                             themeManager.currentTheme.primaryColor : .white.opacity(0.4))
                            
                            Text(frequency.rawValue)
                                .font(themeManager.currentTheme.font(for: .callout))
                                .foregroundColor(themeManager.currentTheme.textPrimary)
                            
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
            .background(
                RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                    .fill(.ultraThinMaterial)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Schedule Section
    @ViewBuilder
    private func scheduleSection(viewModel: AddMedicationViewModel) -> some View {
        @Bindable var vm = viewModel
        
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Schedule Times")
                    .font(themeManager.currentTheme.font(for: .headline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                
                Spacer()
                
                if vm.selectedFrequency != .asNeeded {
                    Button(action: {
                        vm.addScheduledTime()
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(themeManager.currentTheme.primaryGradient)
                            .font(.system(size: 24))
                    }
                }
            }
            
            if vm.scheduledTimes.isEmpty {
                Text("No scheduled times (as needed)")
                    .font(themeManager.currentTheme.font(for: .callout))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                            .fill(.ultraThinMaterial)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(vm.scheduledTimes.enumerated()), id: \.offset) { index, time in
                        HStack {
                            Image(systemName: "clock.fill")
                                .foregroundColor(themeManager.currentTheme.secondaryColor)
                            
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
                                        .foregroundColor(themeManager.currentTheme.errorColor)
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
                .background(
                    RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                        .fill(.ultraThinMaterial)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
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
            .font(themeManager.currentTheme.font(for: .headline))
            .foregroundColor(themeManager.currentTheme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Spacing.md)
            .background(themeManager.currentTheme.primaryGradient)
            .cornerRadius(16)
            .shadow(color: themeManager.currentTheme.primaryColor.opacity(0.5), radius: 20, x: 0, y: 10)
        }
    }
}

// MARK: - Custom Text Field Style
struct ElixirTextFieldStyle: TextFieldStyle {
    @Environment(ThemeManager.self) private var themeManager
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .font(themeManager.currentTheme.font(for: .body))
            .foregroundColor(themeManager.currentTheme.textPrimary)
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

// MARK: - Preview
#Preview {
    NavigationStack {
        AddMedicationView()
            .modelContainer(DataController.preview)
            .environment(ThemeManager.shared)
    }
}
