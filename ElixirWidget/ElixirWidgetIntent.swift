//
//  ElixirWidgetIntent.swift
//  ElixirWidget
//
//  App Intent for configuring which data the widget displays.
//

import AppIntents
import WidgetKit

enum WidgetDisplayTypeOption: String, AppEnum {
    case medication
    case water
    case both

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        "Display Type"
    }

    static var caseDisplayRepresentations: [WidgetDisplayTypeOption: DisplayRepresentation] {
        [
            .medication: DisplayRepresentation(
                title: "Medication",
                image: .init(systemName: "pills.fill")
            ),
            .water: DisplayRepresentation(
                title: "Water",
                image: .init(systemName: "drop.fill")
            ),
            .both: DisplayRepresentation(
                title: "Both",
                image: .init(systemName: "circle.grid.2x1.fill")
            )
        ]
    }
}

struct ElixirWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configure Elixir Widget"
    static var description: IntentDescription = "Choose what to display on your widget."

    @Parameter(title: "Display Type", default: .medication)
    var displayType: WidgetDisplayTypeOption
}
