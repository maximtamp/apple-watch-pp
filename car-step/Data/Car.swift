//
//  Car.swift
//  car-step
//
//  Created by Maxim Tampere on 10/01/2026.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Car {
    var userId: UUID
    var bodyId: UUID
    var engineId: UUID
    var wheelId: UUID
    
    init(userId: UUID, bodyId: UUID, engineId: UUID, wheelId: UUID) {
        self.userId = userId
        self.bodyId = bodyId
        self.engineId = engineId
        self.wheelId = wheelId
    }
    
    convenience init(dto: CarDTO) {
        self.init(
            userId: dto.userId,
            bodyId: dto.bodyId,
            engineId: dto.engineId,
            wheelId: dto.wheelId,
        )
    }
}

struct CarDTO: Codable {
    var userId: UUID
    var bodyId: UUID
    var engineId: UUID
    var wheelId: UUID
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case bodyId = "body_id"
        case engineId = "engine_id"
        case wheelId = "wheel_id"
    }
}

struct CarInsert: Encodable {
    var user_id: String
    var body_id: String
    var engine_id: String
    var wheel_id: String
}

struct CarUpdate: Encodable {
    var body_id: String
    var engine_id: String
    var wheel_id: String
}
