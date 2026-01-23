//
//  Part.swift
//  car-step
//
//  Created by Maxim Tampere on 08/01/2026.
//

import Foundation
import SwiftData
import SwiftUI

enum PartType: String, Codable, CaseIterable {
    case body
    case engine
    case wheel
    
    var displayName: String {
        switch self {
        case .body: return "Body"
        case .engine: return "Engine"
        case .wheel: return "Wheel"
        }
    }
}

enum PartRarity: String, Codable, CaseIterable {
    case common
    case uncommon
    case rare
    case epic
    case legendary
    
    var displayName: String {
        rawValue.capitalized
    }
}

@Model
class Part {
    var id = UUID()
    var userId: UUID
    var name: String
    var type: PartType
    var rarity: PartRarity
    var partMade : Bool
    var progressValue: Int
    var maxValue: Int
    var creationDate: Date

    init(id: UUID = UUID(), userId: UUID = UUID(), name: String, type: PartType, rarity: PartRarity, partMade: Bool, progressValue: Int, maxValue: Int, creationDate: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.type = type
        self.rarity = rarity
        self.partMade = partMade
        self.progressValue = progressValue
        self.maxValue = maxValue
        self.creationDate = creationDate
    }
    
    convenience init(dto: PartDTO) {
        self.init(
            id: dto.id,
            userId: dto.userId,
            name: dto.name,
            type: dto.type,
            rarity: dto.rarity,
            partMade: dto.partMade,
            progressValue: dto.progressValue,
            maxValue: dto.maxValue,
            creationDate: dto.creationDate
            
        )
    }
    
    var progressPrecent: Double {
        return Double(progressValue) / Double(maxValue)
    }
    
    static let possibleParts: [Part] = [
        // BODY
        Part(name: "Shell Rover", type: .body, rarity: .common, partMade: false, progressValue: 0, maxValue: 3000, creationDate: .now),
        Part(name: "Wing Chassis", type: .body, rarity: .uncommon, partMade: false, progressValue: 0, maxValue: 6000, creationDate: .now),
        Part(name: "Crest Shell", type: .body, rarity: .rare, partMade: false, progressValue: 0, maxValue: 10000, creationDate: .now),
        Part(name: "Phoenix Carapace", type: .body, rarity: .epic, partMade: false, progressValue: 0, maxValue: 15000, creationDate: .now),
        Part(name: "Aura Frame", type: .body, rarity: .legendary, partMade: false, progressValue: 0, maxValue: 20000, creationDate: .now),
        
        // ENGINE
        Part(name: "Engine V1", type: .engine, rarity: .common, partMade: false, progressValue: 0, maxValue: 2000, creationDate: .now),
        Part(name: "Bolt Core", type: .engine, rarity: .uncommon, partMade: false, progressValue: 0, maxValue: 4500, creationDate: .now),
        Part(name: "Gear V8", type: .engine, rarity: .rare, partMade: false, progressValue: 0, maxValue: 8000, creationDate: .now),
        Part(name: "Flare Pulse Unit", type: .engine, rarity: .epic, partMade: false, progressValue: 0, maxValue: 12000, creationDate: .now),
        Part(name: "Reactor", type: .engine, rarity: .legendary, partMade: false, progressValue: 0, maxValue: 16000, creationDate: .now),
            
        // WHEEL
        Part(name: "Ring Hoops", type: .wheel, rarity: .common, partMade: false, progressValue: 0, maxValue: 1000, creationDate: .now),
        Part(name: "Spoke Treads", type: .wheel, rarity: .uncommon, partMade: false, progressValue: 0, maxValue: 2500, creationDate: .now),
        Part(name: "Bolt Spinners", type: .wheel, rarity: .rare, partMade: false, progressValue: 0, maxValue: 5000, creationDate: .now),
        Part(name: "Vortex Rollers", type: .wheel, rarity: .epic, partMade: false, progressValue: 0, maxValue: 8000, creationDate: .now),
        Part(name: "Nebula Glidewheels", type: .wheel, rarity: .legendary, partMade: false, progressValue: 0, maxValue: 12000, creationDate: .now),
    ]
    
    func getRarityColor(neededRarity: PartRarity) -> Color {
        switch neededRarity {
        case .common:
            return Color(red: 0.85, green: 0.85, blue: 0.85)
        case .uncommon:
            return Color(red: 0.65, green: 0.90, blue: 0.65)
        case .rare:
            return Color(red: 0.42, green: 0.69, blue: 1.0)
        case .epic:
            return Color(red: 0.77, green: 0.42, blue: 1.0)
        case .legendary:
            return Color(red: 1.0, green: 0.84, blue: 0.0)
        }
    }
    
    @ViewBuilder
    func getPartShape(neededPart: PartType, progress: Double, size: Int) -> some View {
        let sizeDivider = 300 / size
        
        switch neededPart {
        case .body:
             BodyShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: 4)
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(143 / sizeDivider))
        case .engine:
             EngineShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: 4)
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(202 / sizeDivider))
        case .wheel:
             WheelShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: 4)
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(300 / sizeDivider))
        }
    }
}

struct PartDTO: Codable {
    var id: UUID
    var userId: UUID
    var name: String
    var type: PartType
    var rarity: PartRarity
    var partMade : Bool
    var progressValue: Int
    var maxValue: Int
    var creationDate: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case type
        case rarity
        case partMade = "part_made"
        case progressValue = "progress_value"
        case maxValue = "max_value"
        case creationDate = "creation_date"
    }
}

struct PartInsert: Encodable {
    var id: String
    var user_id: String
    var name: String
    var type: String
    var rarity: String
    var part_made: Bool
    var progress_value: Int
    var max_value: Int
    var creation_date: String
}

struct PartUpdate: Encodable {
    var part_made: Bool
    var progress_value: Int
    var creation_date: String
}
