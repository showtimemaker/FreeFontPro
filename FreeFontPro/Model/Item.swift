//
//  Item.swift
//  FreeFont Pro
//
//  Created by chiu on 2025/11/21.
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
