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
                headerSection

                // Basic Info
                basicInfoSection(viewModel: viewModel)

                // Appearance
                appearanceSection(viewModel: viewModel)

                // Frequency
                frequencySection(viewModel: viewModel)

                // Every Other Day Options
                if viewModel.selectedFrequency == .everyOtherDay {
                    everyOtherDaySection(viewModel: viewModel)
                }

                // Weekly Options
                if viewModel.selectedFrequency == .weekly {
                    weeklySection(viewModel: viewModel)
                }

                // Specific Days Options
                if viewModel.selectedFrequency == .specificDays {
                    specificDaysSection(viewModel: viewModel)
                }

                // Schedule Times
                scheduleSection(viewModel: viewModel)

                // Save Button at end
                saveButton(viewModel: viewModel)
                    .padding(.top, Spacing.md)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, Spacing.md)
            .padding(.top, Spacing.md)
            .padding(.bottom, Spacing.lg)
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: Spacing.sm) {
            // Use different emojis for different themes
            Group {
                if themeManager.currentTheme.category == .clean {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(themeManager.currentTheme.primaryColor)
                } else {
                    Text(themeManager.currentTheme.emojis.currency)
                        .font(.system(size: 56))
                }
            }

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

                    HStack(spacing: Spacing.sm) {
                        TextField("Amount", text: $vm.dosageAmount)
                            .textFieldStyle(ElixirTextFieldStyle())
                            .keyboardType(.decimalPad)
                            .frame(maxWidth: .infinity)

                        Menu {
                            ForEach(AddMedicationViewModel.dosageUnits, id: \.self) { unit in
                                Button(unit) {
                                    vm.dosageUnit = unit
                                }
                            }
                        } label: {
                            HStack {
                                Text(vm.dosageUnit)
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

                    DatePicker("", selection: $vm.startDate, displayedComponents: .date)
                        .labelsHidden()
                        .datePickerStyle(.compact)
                        .tint(themeManager.currentTheme.primaryColor)
                }

                // End Date Toggle
                Toggle("Set End Date", isOn: $vm.hasEndDate)
                    .font(themeManager.currentTheme.font(for: .subheadline))
                    .foregroundColor(themeManager.currentTheme.textPrimary)
                    .tint(themeManager.currentTheme.primaryColor)

                if vm.hasEndDate {
                    DatePicker("", selection: $vm.endDate, in: vm.startDate..., displayedComponents: .date)
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
    
    // MARK: - Frequency Section
    @ViewBuilder
    private func frequencySection(viewModel: AddMedicationViewModel) -> some View {
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
    
    // MARK: - Every Other Day Section
    @ViewBuilder
    private func everyOtherDaySection(viewModel: AddMedicationViewModel) -> some View {
        @Bindable var vm = viewModel

        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Start Day")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            HStack(spacing: Spacing.sm) {
                Button(action: {
                    vm.startDayOffset = 0
                }) {
                    Text("Today")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(vm.startDayOffset == 0 ? .white : themeManager.currentTheme.textPrimary)
                        .padding(.vertical, Spacing.sm)
                        .padding(.horizontal, Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(vm.startDayOffset == 0 ?
                                      themeManager.currentTheme.primaryColor : Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(vm.startDayOffset == 0 ?
                                        Color.clear : Color.white.opacity(0.1), lineWidth: 1)
                        )
                }

                Button(action: {
                    vm.startDayOffset = 1
                }) {
                    Text("Tomorrow")
                        .font(themeManager.currentTheme.font(for: .subheadline))
                        .foregroundColor(vm.startDayOffset == 1 ? .white : themeManager.currentTheme.textPrimary)
                        .padding(.vertical, Spacing.sm)
                        .padding(.horizontal, Spacing.lg)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(vm.startDayOffset == 1 ?
                                      themeManager.currentTheme.primaryColor : Color.white.opacity(0.1))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(vm.startDayOffset == 1 ?
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

    // MARK: - Weekly Section
    @ViewBuilder
    private func weeklySection(viewModel: AddMedicationViewModel) -> some View {
        @Bindable var vm = viewModel

        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Day of Week")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: Spacing.sm) {
                ForEach(1...7, id: \.self) { weekday in
                    let dayName = weekdayName(for: weekday)
                    Button(action: {
                        vm.selectedWeekday = weekday
                    }) {
                        Text(dayName)
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(vm.selectedWeekday == weekday ? .white : themeManager.currentTheme.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(vm.selectedWeekday == weekday ?
                                          themeManager.currentTheme.primaryColor : Color.white.opacity(0.1))
                            )
                            .overlay(
                                Circle()
                                    .stroke(vm.selectedWeekday == weekday ?
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

    // MARK: - Specific Days Section
    @ViewBuilder
    private func specificDaysSection(viewModel: AddMedicationViewModel) -> some View {
        @Bindable var vm = viewModel

        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Select Days")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 44))], spacing: Spacing.sm) {
                ForEach(1...7, id: \.self) { weekday in
                    let dayName = weekdayName(for: weekday)
                    let isSelected = vm.selectedWeekdays.contains(weekday)
                    Button(action: {
                        if isSelected {
                            vm.selectedWeekdays.remove(weekday)
                        } else {
                            vm.selectedWeekdays.insert(weekday)
                        }
                    }) {
                        Text(dayName)
                            .font(themeManager.currentTheme.font(for: .caption))
                            .foregroundColor(isSelected ? .white : themeManager.currentTheme.textPrimary)
                            .frame(width: 44, height: 44)
                            .background(
                                Circle()
                                    .fill(isSelected ?
                                          themeManager.currentTheme.primaryColor : Color.white.opacity(0.1))
                            )
                            .overlay(
                                Circle()
                                    .stroke(isSelected ?
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

    // Helper to get weekday name
    private func weekdayName(for weekday: Int) -> String {
        let calendar = Calendar.current
        let symbols = calendar.shortWeekdaySymbols
        return symbols[weekday - 1]
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
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            } else {
                VStack(spacing: Spacing.sm) {
                    ForEach(Array(vm.scheduledTimes.enumerated()), id: \.offset) { index, time in
                        HStack(spacing: Spacing.md) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 20))
                                .foregroundColor(themeManager.currentTheme.primaryColor)

                            DatePicker(
                                "",
                                selection: Binding(
                                    get: { time },
                                    set: { vm.updateScheduledTime(at: index, to: $0) }
                                ),
                                displayedComponents: .hourAndMinute
                            )
                            .labelsHidden()
                            .datePickerStyle(.compact)
                            .tint(themeManager.currentTheme.primaryColor)

                            Spacer()
                            
                            if vm.scheduledTimes.count > 1 {
                                Button(action: {
                                    vm.removeScheduledTime(at: index)
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
    
    // MARK: - Save Button
    @ViewBuilder
    private func saveButton(viewModel: AddMedicationViewModel) -> some View {
        Button(action: {
            if viewModel.saveMedication() {
                // Haptic feedback
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)

                // Show success alert
                showSuccessAlert = true
            }
        }) {
            HStack(spacing: Spacing.sm) {
                Text(themeManager.currentTheme.emojis.check)
                    .font(.system(size: 22))
                Text("Save Ritual")
                    .fontWeight(.semibold)
            }
            .font(themeManager.currentTheme.font(for: .body))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
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
