//
//  Item.swift
//  ElixirDemo
//
//  Created by Murat Can Koc on 31.12.2025.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
