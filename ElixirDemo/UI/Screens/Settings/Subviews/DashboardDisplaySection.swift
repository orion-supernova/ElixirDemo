//
//  DashboardDisplaySection.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct DashboardDisplaySection: View {
    @Environment(ThemeManager.self) private var themeManager
    @Environment(\.modelContext) private var modelContext

    @Query private var waterSettings: [WaterSettings]

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.md) {
            Text("Dashboard Rituals")
                .font(themeManager.currentTheme.font(for: .headline))
                .foregroundColor(themeManager.currentTheme.textPrimary)

            VStack(spacing: 0) {
                let settings = waterSettings.first ?? WaterSettings()

                ForEach(DashboardMode.allCases) { mode in
                    Button {
                        withAnimation {
                            settings.dashboardMode = mode
                            try? modelContext.save()
                        }
                    } label: {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(settings.activeDashboardMode == mode ? themeManager.currentTheme.primaryColor.opacity(0.2) : Color.white.opacity(0.05))
                                    .frame(width: 36, height: 36)

                                Image(systemName: mode.icon)
                                    .font(.system(size: 16))
                                    .foregroundColor(settings.activeDashboardMode == mode ? themeManager.currentTheme.primaryColor : themeManager.currentTheme.textSecondary)
                            }

                            Text(mode.rawValue)
                                .font(themeManager.currentTheme.font(for: .body))
                                .foregroundColor(settings.activeDashboardMode == mode ? themeManager.currentTheme.textPrimary : themeManager.currentTheme.textSecondary)

                            Spacer()

                            if settings.activeDashboardMode == mode {
                                Image(systemName: themeManager.currentTheme.symbols.check)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(themeManager.currentTheme.primaryColor)
                            }
                        }
                        .padding(Spacing.md)
                        .background(settings.activeDashboardMode == mode ? Color.white.opacity(0.03) : Color.clear)
                    }

                    if mode != DashboardMode.allCases.last {
                        Divider().background(Color.white.opacity(0.1))
                            .padding(.leading, 64)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius))
            .background(
                RoundedRectangle(cornerRadius: themeManager.currentTheme.cornerRadius)
                    .fill(themeManager.currentTheme.surfaceColor)
                    .stroke(themeManager.currentTheme.primaryColor.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

#Preview {
    DashboardDisplaySection()
        .modelContainer(DataController.preview)
        .environment(ThemeManager.shared)
        .padding()
        .background(Color.black)
}
