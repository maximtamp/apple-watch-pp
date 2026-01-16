//
//  Part.swift
//  car-step
//
//  Created by Maxim Tampere on 08/01/2026.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Part {
    var id = UUID()
    var name: String
    var type: String
    var rarity: String
    var partMade : Bool
    var progressValue: Int
    var maxValue: Int
    var creationDate: Date

    init(id: UUID = UUID(), name: String, type: String, rarity: String, partMade: Bool, progressValue: Int, maxValue: Int, creationDate: Date) {
        self.id = id
        self.name = name
        self.type = type
        self.rarity = rarity
        self.partMade = partMade
        self.progressValue = progressValue
        self.maxValue = maxValue
        self.creationDate = creationDate
    }
    
    var progressPrecent: Double {
        return Double(progressValue) / Double(maxValue)
    }
    
    static let possibleParts: [Part] = [
        // BODY
        Part(name: "Shell Rover", type: "Body", rarity: "Common", partMade: false, progressValue: 0, maxValue: 3000, creationDate: .now),
        Part(name: "Wing Chassis", type: "Body", rarity: "Uncommon", partMade: false, progressValue: 0, maxValue: 6000, creationDate: .now),
        Part(name: "Crest Shell", type: "Body", rarity: "Rare", partMade: false, progressValue: 0, maxValue: 10000, creationDate: .now),
        Part(name: "Phoenix Carapace", type: "Body", rarity: "Epic", partMade: false, progressValue: 0, maxValue: 15000, creationDate: .now),
        Part(name: "Aura Frame", type: "Body", rarity: "Legendary", partMade: false, progressValue: 0, maxValue: 20000, creationDate: .now),
        
        // ENGINE
        Part(name: "Engine V1", type: "Engine", rarity: "Common", partMade: false, progressValue: 0, maxValue: 2000, creationDate: .now),
        Part(name: "Bolt Core", type: "Engine", rarity: "Uncommon", partMade: false, progressValue: 0, maxValue: 4500, creationDate: .now),
        Part(name: "Gear V8", type: "Engine", rarity: "Rare", partMade: false, progressValue: 0, maxValue: 8000, creationDate: .now),
        Part(name: "Flare Pulse Unit", type: "Engine", rarity: "Epic", partMade: false, progressValue: 0, maxValue: 12000, creationDate: .now),
        Part(name: "Reactor", type: "Engine", rarity: "Legendary", partMade: false, progressValue: 0, maxValue: 16000, creationDate: .now),
            
        // WHEEL
        Part(name: "Ring Hoops", type: "Wheel", rarity: "Common", partMade: false, progressValue: 0, maxValue: 1000, creationDate: .now),
        Part(name: "Spoke Treads", type: "Wheel", rarity: "Uncommon", partMade: false, progressValue: 0, maxValue: 2500, creationDate: .now),
        Part(name: "Bolt Spinners", type: "Wheel", rarity: "Rare", partMade: false, progressValue: 0, maxValue: 5000, creationDate: .now),
        Part(name: "Vortex Rollers", type: "Wheel", rarity: "Epic", partMade: false, progressValue: 0, maxValue: 8000, creationDate: .now),
        Part(name: "Nebula Glidewheels", type: "Wheel", rarity: "Legendary", partMade: false, progressValue: 0, maxValue: 12000, creationDate: .now),
    ]
    
    func getRarityColor(neededRarity: String) -> Color {
        switch neededRarity {
        case "Common":
            return Color(red: 0.85, green: 0.85, blue: 0.85)
        case "Uncommon":
            return Color(red: 0.65, green: 0.90, blue: 0.65)
        case "Rare":
            return Color(red: 0.42, green: 0.69, blue: 1.0)
        case "Epic":
            return Color(red: 0.77, green: 0.42, blue: 1.0)
        case "Legendary":
            return Color(red: 1.0, green: 0.84, blue: 0.0)
        default:
            return Color(red: 0.85, green: 0.85, blue: 0.85)
        }
    }
    
    @ViewBuilder
    func getPartShape(neededPart: String, progress: Double, size: Int) -> some View {
        let sizeDivider = 300 / size
        
        switch neededPart {
        case "Body":
             BodyShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: 4)
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(143 / sizeDivider))
        case "Engine":
             EngineShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: 4)
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(202 / sizeDivider))
        case "Wheel":
             WheelShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: 4)
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(300 / sizeDivider))
        default:
             BodyShape()
                .trim(from: 0.0, to: progress)
                .stroke(.primary, lineWidth: 4)
                .frame(maxWidth: CGFloat(300 / sizeDivider), maxHeight: CGFloat(143 / sizeDivider))
        }
    }
}
