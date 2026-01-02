//
//  DoseListSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct DoseListSection: View {
    @Environment(ThemeManager.self) private var themeManager

    let viewModel: DashboardViewModel
    @Binding var doseLogToDelete: DoseLog?
    @Binding var showDeleteConfirmation: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            HStack {
                Text("Today's Rituals")
                    .font(themeManager.currentTheme.font(for: .title3))
                    .foregroundColor(themeManager.currentTheme.textPrimary)

                Spacer()

                NavigationLink(destination: MedicationsList()) {
                    HStack(spacing: Spacing.xs) {
                        Text("View All")
                            .font(themeManager.currentTheme.font(for: .caption))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(themeManager.currentTheme.primaryColor)
                }
            }

            if viewModel.doseLogs.isEmpty {
                DashboardEmptyStateView()
            } else {
                ForEach(viewModel.doseLogs, id: \.id) { doseLog in
                    if let medication = doseLog.medication {
                        SwipeActionView(cornerRadius: 20, onDelete: {
                            doseLogToDelete = doseLog
                            showDeleteConfirmation = true
                        }) {
                            ElixirCard(
                                medication: medication,
                                doseLog: doseLog,
                                onCheckmarkTapped: {
                                    viewModel.toggleDoseStatus(for: doseLog)
                                },
                                onMarkMissed: {
                                    viewModel.markDoseAsMissed(doseLog)
                                },
                                onMarkSkipped: {
                                    viewModel.markDoseAsSkipped(doseLog)
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var viewModel = DashboardViewModel(modelContext: DataController.preview.mainContext)
    @Previewable @State var doseLogToDelete: DoseLog? = nil
    @Previewable @State var showDeleteConfirmation = false

    DoseListSection(
        viewModel: viewModel,
        doseLogToDelete: $doseLogToDelete,
        showDeleteConfirmation: $showDeleteConfirmation
    )
    .environment(ThemeManager.shared)
    .padding()
    .background(Color.black)
}
