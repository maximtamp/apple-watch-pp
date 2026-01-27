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
    var speedPoints: Int
    var creationDate: Date

    init(id: UUID = UUID(), userId: UUID = UUID(), name: String, type: PartType, rarity: PartRarity, partMade: Bool, progressValue: Int, maxValue: Int, speedPoints: Int, creationDate: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.type = type
        self.rarity = rarity
        self.partMade = partMade
        self.progressValue = progressValue
        self.maxValue = maxValue
        self.speedPoints = speedPoints
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
            speedPoints: dto.speedPoints,
            creationDate: dto.creationDate
            
        )
    }
    
    var progressPrecent: Double {
        return Double(progressValue) / Double(maxValue)
    }
    
    static let possibleParts: [Part] = [
        // BODY
        Part(name: "Shell Rover", type: .body, rarity: .common, partMade: false, progressValue: 0, maxValue: 3000, speedPoints: 5, creationDate: .now),
        Part(name: "Wing Chassis", type: .body, rarity: .uncommon, partMade: false, progressValue: 0, maxValue: 6000, speedPoints: 7, creationDate: .now),
        Part(name: "Crest Shell", type: .body, rarity: .rare, partMade: false, progressValue: 0, maxValue: 10000, speedPoints: 9, creationDate: .now),
        Part(name: "Phoenix Carapace", type: .body, rarity: .epic, partMade: false, progressValue: 0, maxValue: 15000, speedPoints: 11, creationDate: .now),
        Part(name: "Aura Frame", type: .body, rarity: .legendary, partMade: false, progressValue: 0, maxValue: 20000, speedPoints: 15, creationDate: .now),
        
        // ENGINE
        Part(name: "Engine V1", type: .engine, rarity: .common, partMade: false, progressValue: 0, maxValue: 2000, speedPoints: 10, creationDate: .now),
        Part(name: "Bolt Core", type: .engine, rarity: .uncommon, partMade: false, progressValue: 0, maxValue: 4500, speedPoints: 13, creationDate: .now),
        Part(name: "Gear V8", type: .engine, rarity: .rare, partMade: false, progressValue: 0, maxValue: 8000, speedPoints: 17, creationDate: .now),
        Part(name: "Flare Pulse Unit", type: .engine, rarity: .epic, partMade: false, progressValue: 0, maxValue: 12000, speedPoints: 22, creationDate: .now),
        Part(name: "Reactor", type: .engine, rarity: .legendary, partMade: false, progressValue: 0, maxValue: 16000, speedPoints: 30, creationDate: .now),
            
        // WHEEL
        Part(name: "Ring Hoops", type: .wheel, rarity: .common, partMade: false, progressValue: 0, maxValue: 1000, speedPoints: 7, creationDate: .now),
        Part(name: "Spoke Treads", type: .wheel, rarity: .uncommon, partMade: false, progressValue: 0, maxValue: 2500, speedPoints: 9, creationDate: .now),
        Part(name: "Bolt Spinners", type: .wheel, rarity: .rare, partMade: false, progressValue: 0, maxValue: 5000, speedPoints: 12, creationDate: .now),
        Part(name: "Vortex Rollers", type: .wheel, rarity: .epic, partMade: false, progressValue: 0, maxValue: 8000, speedPoints: 15, creationDate: .now),
        Part(name: "Nebula Glidewheels", type: .wheel, rarity: .legendary, partMade: false, progressValue: 0, maxValue: 12000, speedPoints: 21, creationDate: .now),
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
    func getPartShape(neededPart: String, progress: Double, size: Int, lineWidth: Int) -> some View {
        let sizeDivider = 300 / size
        
        switch neededPart {

        // BODY
        case "Shell Rover":
            ShellRoverShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(182 / sizeDivider))

        case "Wing Chassis":
            WingChassisShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(149 / sizeDivider))

        case "Crest Shell":
            CrestShellShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(189 / sizeDivider))

        case "Phoenix Carapace":
            PhoenixCarapaceShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(154 / sizeDivider))

        case "Aura Frame":
            AuraFrameShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(151 / sizeDivider))

        // ENGINE
        case "Engine V1":
            EngineV1Shape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(206 / sizeDivider))

        case "Bolt Core":
            BoltCoreShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(242 / sizeDivider))

        case "Gear V8":
            GearV8Shape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(204 / sizeDivider))

        case "Flare Pulse Unit":
            FlarePulseUnitShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(156 / sizeDivider))

        case "Reactor":
            ReactorShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(152 / sizeDivider))

        // WHEEL
        case "Ring Hoops":
            RingHoopsShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(300 / sizeDivider))

        case "Spoke Treads":
            SpokeTreadsShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(300 / sizeDivider))

        case "Bolt Spinners":
            BoltSpinnersShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(300 / sizeDivider))

        case "Vortex Rollers":
            VortexRollersShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(300 / sizeDivider))

        case "Nebula Glidewheels":
            NebulaGlidewheelsShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(300 / sizeDivider))

        default:
            PhoenixCarapaceShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: CGFloat(lineWidth))
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(154 / sizeDivider))
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
    var speedPoints: Int
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
        case speedPoints = "speed_points"
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
    var speed_points: Int
    var creation_date: String
}

struct PartUpdate: Encodable {
    var part_made: Bool
    var progress_value: Int
    var creation_date: String
}
