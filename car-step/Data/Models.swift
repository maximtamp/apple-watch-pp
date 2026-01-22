//
//  Models.swift
//  car-step
//
//  Created by Maxim Tampere on 21/01/2026.
//

import Foundation

struct Profile: Codable {
    let id: UUID
    let username: String?
    let avatarURL: String?

    enum CodingKeys: String, CodingKey {
        case id
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
