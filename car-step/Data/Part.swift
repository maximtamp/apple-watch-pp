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
    var rarity: String
    var partMade : Bool
    var progressValue: Int
    var maxValue: Int
    var creationDate: Date

    init(id: UUID = UUID(), name: String, type: String, rarity: String, partMade: Bool, progressValue: Int, maxValue: Int, creationDate: Date) {
        self.id = id
        self.name = name
        self.type = type
        self.rarity = rarity
        self.partMade = partMade
        self.progressValue = progressValue
        self.maxValue = maxValue
        self.creationDate = creationDate
    }
    
    var progressPrecent: Double {
        return Double(progressValue) / Double(maxValue)
    }
    
    static let possibleParts: [Part] = [
        Part(name: "Sparky", type: "Wheel", rarity: "Rare", partMade: false, progressValue: 0, maxValue: 10000, creationDate: .now),
        Part(name: "Cardboard", type: "Wheel", rarity: "Uncommon", partMade: false, progressValue: 0, maxValue: 2000, creationDate: .now),
        Part(name: "Jef", type: "Wheel", rarity: "Common", partMade: false, progressValue: 0, maxValue: 7000, creationDate: .now)
    ]
}
