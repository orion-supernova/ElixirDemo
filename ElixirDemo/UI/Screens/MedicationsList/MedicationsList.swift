//
//  MedicationsList.swift
//  Elixir: Daily Ritual
//
//  Created by Claude on 31.12.2025.
//

import SwiftUI
import SwiftData

struct MedicationsList: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.dismiss) private var dismiss

    @Query(sort: \Medication.createdAt, order: .reverse) private var medications: [Medication]

    var body: some View {
        ZStack {
            // Background
            themeManager.currentTheme.backgroundGradient
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: Spacing.lg) {
                    if medications.isEmpty {
                        MedicationsListEmptyStateView()
                    } else {
                        ForEach(medications) { medication in
                            MedicationSettingsCard(medication: medication)
                        }
                    }
                }
                .padding(.horizontal, Spacing.md)
                .padding(.top, Spacing.md)
                .padding(.bottom, Spacing.lg)
            }
        }
        .navigationTitle("All Rituals")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        MedicationsList()
            .modelContainer(DataController.preview)
            .environment(ThemeManager.shared)
    }
}
