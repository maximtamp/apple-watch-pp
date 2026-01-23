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
    var userId: UUID
    var date: Date
    var title: String
    var type: QuestType
    var currentValue: Int
    var neededValue: Int
    var claimed: Bool
    var fuelReward: Int
    
    init(id: UUID = UUID(), userId: UUID, date: Date, title: String, type: QuestType, currentValue: Int, neededValue: Int, claimed: Bool, fuelReward: Int) {
        self.id = id
        self.userId = userId
        self.date = date
        self.title = title
        self.type = type
        self.currentValue = currentValue
        self.neededValue = neededValue
        self.claimed = claimed
        self.fuelReward = fuelReward
    }
    
    convenience init(dto: QuestDTO) {
        self.init(
            id: dto.id,
            userId: dto.userId,
            date: dto.date,
            title: dto.title,
            type: dto.type,
            currentValue: dto.currentValue,
            neededValue: dto.neededValue,
            claimed: dto.claimed,
            fuelReward: dto.fuelReward,
            
        )
    }
}

struct QuestDTO: Codable {
    var id: UUID
    var userId: UUID
    var date: Date
    var title: String
    var type: QuestType
    var currentValue: Int
    var neededValue: Int
    var claimed: Bool
    var fuelReward: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case title
        case type
        case currentValue = "current_value"
        case neededValue = "needed_value"
        case claimed
        case fuelReward = "fuel_reward"
    }
}

struct QuestInsert: Encodable {
    var id: String
    var user_id: String
    var date: String
    var title: String
    var type: String
    var current_value: Int
    var needed_value: Int
    var claimed: Bool
    var fuel_reward: Int
}

struct QuestUpdate: Encodable {
    var current_value: Int
    var claimed: Bool
}
