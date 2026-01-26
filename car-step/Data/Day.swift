//
//  Day.swift
//  car-step
//
//  Created by Maxim Tampere on 08/01/2026.
//

import Foundation
import SwiftData

@Model
class Day {
    var id: UUID
    var userId: UUID
    var date: Date
    var totalSteps: Int
    var claimedSteps: Int
    var usedFuel: Int
    
    init(id: UUID, userId: UUID, date: Date, totalSteps: Int, claimedSteps: Int, usedFuel: Int) {
        self.id = id
        self.userId = userId
        self.date = date
        self.totalSteps = totalSteps
        self.claimedSteps = claimedSteps
        self.usedFuel = usedFuel
    }
    
    convenience init(dto: DayDTO) {
        self.init(
            id: dto.id,
            userId: dto.userId,
            date: dto.date,
            totalSteps: dto.totalSteps,
            claimedSteps: dto.claimedSteps,
            usedFuel: dto.usedFuel
        )
    }
}

struct DayDTO: Codable {
    var id: UUID
    var userId: UUID
    var date: Date
    var totalSteps: Int
    var claimedSteps: Int
    var usedFuel: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case totalSteps = "total_steps"
        case claimedSteps = "claimed_steps"
        case usedFuel = "used_fuel"
    }
}

struct DayInsert: Encodable {
    let id: String
    let user_id: String
    let date: String
    let total_steps: Int
    let claimed_steps: Int
    let used_fuel: Int
}

struct DayUpdate: Encodable {
    let total_steps: Int
    let claimed_steps: Int
    let used_fuel: Int
}
