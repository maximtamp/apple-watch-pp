//
//  Race.swift
//  car-step
//
//  Created by Maxim Tampere on 26/01/2026.
//

import Foundation

class Race {
    var id: UUID
    var userId: UUID
    var opponentId: UUID
    var won: Bool
    var date: Date
    
    init(id: UUID = UUID(), userId: UUID, opponentId: UUID, won: Bool, date: Date) {
        self.id = id
        self.userId = userId
        self.opponentId = opponentId
        self.won = won
        self.date = date
    }
    
    convenience init(dto: RaceDTO) {
        self.init(
            id: dto.id,
            userId: dto.userId,
            opponentId: dto.opponentId,
            won: dto.won,
            date: dto.date
        )
    }
}

struct RaceDTO: Codable {
    var id: UUID
    var userId: UUID
    var opponentId: UUID
    var won: Bool
    var date: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case opponentId = "opponent_id"
        case won
        case date
    }
}

struct RaceInsert: Encodable {
    var id: String
    var user_id: String
    var opponent_id: String
    var won: Bool
    var date: String
}
