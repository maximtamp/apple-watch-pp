//
//  Friend.swift
//  car-step
//
//  Created by Maxim Tampere on 24/01/2026.
//

import Foundation

class Friend {
    var id: UUID
    var userId: UUID
    var friendId: UUID
    var isAccepted: Bool
    
    init(id: UUID = UUID(), userId: UUID, friendId: UUID, isAccepted: Bool) {
        self.id = id
        self.userId = userId
        self.friendId = friendId
        self.isAccepted = isAccepted
    }
    
    convenience init(dto: FriendDTO) {
        self.init(
            id: dto.id,
            userId: dto.userId,
            friendId: dto.friendId,
            isAccepted: dto.isAccepted
        )
    }
}

struct FriendDTO: Codable {
    var id: UUID
    var userId: UUID
    var friendId: UUID
    var isAccepted: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case friendId = "friend_id"
        case isAccepted = "is_accepted"
    }
}

struct FriendInsert: Encodable {
    var id: String
    var user_id: String
    var friend_id: String
    var is_accepted: Bool
}

struct FriendUpdate: Encodable {
    var is_accepted: Bool
}
