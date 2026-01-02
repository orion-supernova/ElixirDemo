//
//  TodayProgressSection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct TodayProgressSection: View {
    @Environment(ThemeManager.self) private var themeManager
    let viewModel: DashboardViewModel

    var body: some View {
        VStack(spacing: Spacing.sm) {
            HStack {
                HStack(spacing: Spacing.xs) {
                    Image(systemName: themeManager.currentTheme.symbols.check)
                        .font(.system(size: 16))
                        .foregroundColor(themeManager.currentTheme.primaryColor)
                    Text("Today's Progress")
                        .font(themeManager.currentTheme.font(for: .headline))
                        .foregroundColor(themeManager.currentTheme.textPrimary)
                }

                Spacer()

                Text("\(viewModel.takenDoses) / \(viewModel.totalDoses)")
                    .font(themeManager.currentTheme.font(for: .caption))
                    .foregroundColor(themeManager.currentTheme.textSecondary)
            }

            // Today's Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.currentTheme.primaryColor,
                                    themeManager.currentTheme.successColor
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * viewModel.todayProgress, height: 12)
                }
            }
            .frame(height: 12)
        }
        .padding(Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(themeManager.currentTheme.primaryColor.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    @Previewable @State var viewModel = DashboardViewModel(modelContext: DataController.preview.mainContext)

    TodayProgressSection(viewModel: viewModel)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
