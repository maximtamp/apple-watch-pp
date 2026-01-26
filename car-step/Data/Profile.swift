//
//  Models.swift
//  car-step
//
//  Created by Maxim Tampere on 21/01/2026.
//

import Foundation

class Profile {
    let id: UUID
    let username: String?
    let avatarURL: String?
    
    init(id: UUID, username: String, avatarURL: String) {
        self.id = id
        self.username = username
        self.avatarURL = avatarURL
    }
    
    convenience init(dto: ProfileDTO) {
        self.init(
            id: dto.id,
            username: dto.username ?? "",
            avatarURL: dto.avatarURL ?? ""
        )
    }
}

struct ProfileDTO: Codable {
    var id: UUID
    var username: String?
    var avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case username
        case avatarURL = "avatar_url"
    }
}

struct ProfileUpdate: Codable {
    let username: String
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case username
        case avatarURL = "avatar_url"
    }
}
