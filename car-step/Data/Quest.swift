//
//  Quest.swift
//  car-step
//
//  Created by Maxim Tampere on 18/01/2026.
//

import Foundation
import SwiftData

enum QuestType: String, Codable, CaseIterable {
    case placeSteps
    case useFuel
    case makeParts
}

@Model
class Quest {
    var id: UUID
    var date: Date
    var title: String
    var type: QuestType
    var currentValue: Int
    var neededValue: Int
    var claimed: Bool
    var fuelReward: Int
    
    init(id: UUID = UUID(), date: Date, title: String, type: QuestType, currentValue: Int, neededValue: Int, claimed: Bool, fuelReward: Int) {
        self.id = id
        self.date = date
        self.title = title
        self.type = type
        self.currentValue = currentValue
        self.neededValue = neededValue
        self.claimed = claimed
        self.fuelReward = fuelReward
    }
}
