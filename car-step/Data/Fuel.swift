//
//  Fuel.swift
//  car-step
//
//  Created by Maxim Tampere on 08/01/2026.
//

import Foundation
import SwiftData

@Model
class Fuel {
    var userId: UUID
    var value: Int
    
    init(userId: UUID, value: Int) {
        self.userId = userId
        self.value = value
    }
    
    convenience init(dto: FuelDTO) {
        self.init(
            userId: dto.userId,
            value: dto.value,
        )
    }
}

struct FuelDTO: Codable {
    var userId: UUID
    var value: Int
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case value
    }
}

struct FuelInsert: Encodable {
    var user_id: String
    var value: Int
}

struct FuelUpdate: Encodable {
    var value: Int
}
