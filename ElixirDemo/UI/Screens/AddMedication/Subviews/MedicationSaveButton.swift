//
//  MedicationSaveButton.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct MedicationSaveButton: View {
    @Environment(ThemeManager.self) private var themeManager
    @Bindable var viewModel: AddMedicationViewModel
    @Binding var showSuccessAlert: Bool

    var body: some View {
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
                Image(systemName: themeManager.currentTheme.symbols.check)
                    .font(.system(size: 20))
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

#Preview {
    @Previewable @State var viewModel = AddMedicationViewModel(modelContext: DataController.preview.mainContext)
    @Previewable @State var showSuccessAlert = false

    MedicationSaveButton(viewModel: viewModel, showSuccessAlert: $showSuccessAlert)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
