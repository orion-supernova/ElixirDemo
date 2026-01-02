//
//  StatsSummary.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct DashboardStatsSummary: View {
    @Environment(ThemeManager.self) private var themeManager
    let viewModel: DashboardViewModel

    var body: some View {
        HStack(spacing: Spacing.md) {
            StatCard(
                title: "Completed",
                value: "\(viewModel.takenDoses)",
                iconName: themeManager.currentTheme.symbols.check,
                color: themeManager.currentTheme.successColor
            )

            StatCard(
                title: "Pending",
                value: "\(viewModel.pendingDoses)",
                iconName: themeManager.currentTheme.symbols.uncheck,
                color: themeManager.currentTheme.accentColor
            )

            StatCard(
                title: "Missed",
                value: "\(viewModel.missedDoses)",
                iconName: "exclamationmark.triangle.fill",
                color: themeManager.currentTheme.errorColor
            )
        }
    }
}

#Preview {
    @Previewable @State var viewModel = DashboardViewModel(modelContext: DataController.preview.mainContext)

    DashboardStatsSummary(viewModel: viewModel)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
