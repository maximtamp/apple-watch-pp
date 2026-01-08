//
//  Part.swift
//  car-step
//
//  Created by Maxim Tampere on 08/01/2026.
//

import Foundation
import SwiftData

@Model
class Part {
    var id = UUID()
    var name: String
    var type: String
    var partMade : Bool
    var progressValue: Int
    var maxValue: Int

    init(id: UUID = UUID(), name: String, type: String, partMade: Bool, progressValue: Int, maxValue: Int) {
        self.id = id
        self.name = name
        self.type = type
        self.partMade = partMade
        self.progressValue = progressValue
        self.maxValue = maxValue
    }
    
    var progressPrecent: Double {
        return Double(progressValue) / Double(maxValue)
    }
}
