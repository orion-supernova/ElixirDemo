//
//  WaveShape.swift
//  Elixir: Daily Ritual
//
//  Created by Murat Can Koc on 31.12.2025.
//

import SwiftUI

struct WaveShape: Shape {
    var offset: Angle
    var percent: Double

    var animatableData: Double {
        get { offset.degrees }
        set { offset = Angle(degrees: newValue) }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let lowThreshold = 0.01
        let highThreshold = 0.99

        let waveHeight = 0.015 * rect.height
        let yOffset = CGFloat(1 - percent) * rect.height

        path.move(to: CGPoint(x: 0, y: rect.height))
        path.addLine(to: CGPoint(x: 0, y: yOffset))

        if percent < lowThreshold {
            path.addLine(to: CGPoint(x: rect.width, y: yOffset))
        } else if percent > highThreshold {
            path.addLine(to: CGPoint(x: rect.width, y: yOffset))
        } else {
            for x in stride(from: 0, through: rect.width, by: 1) {
                let relativeX = x / rect.width
                let sine = sin(relativeX * .pi * 2 + offset.radians)
                let y = yOffset + sine * waveHeight
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        path.closeSubpath()
        return path
    }
}
