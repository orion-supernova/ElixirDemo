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
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                DashboardView()
            }
            .preferredColorScheme(.dark)
        }
        .modelContainer(DataController.shared.container)
    }
}
