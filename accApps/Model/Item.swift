//
//  Item.swift
//  accApps
//
//  Created by Rana on 01/06/1447 AH.
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

enum Category: Hashable {
    case noun, name, verb
}

enum Route: Hashable {
    case noun, name, verb, summary
}
