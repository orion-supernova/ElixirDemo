//
//  CurrentScreen.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

struct CurrentScreen: View {
    let selectedTab: AppTab

    var body: some View {
        switch selectedTab {
        case .dashboard:
            Dashboard()

        case .add:
            AddMedication()

        case .settings:
            Settings()
        }
    }
}

#Preview {
    CurrentScreen(selectedTab: .dashboard)
        .modelContainer(DataController.preview)
        .environment(ThemeManager.shared)
}
