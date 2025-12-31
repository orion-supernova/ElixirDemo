//
//  ElixirDemoApp.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI
import SwiftData

@main
struct ElixirDemoApp: App {
    @State private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .preferredColorScheme(.dark)
                .environment(themeManager)
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
        }
        .modelContainer(DataController.shared.container)
    }
}
