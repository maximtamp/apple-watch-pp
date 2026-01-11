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
    var bodyId = UUID()
    var engineId = UUID()
    var wheelId = UUID()
    var carColor: String
    
    init(bodyId: UUID = UUID(), engineId: UUID = UUID(), wheelId: UUID = UUID(), carColor: String) {
        self.bodyId = bodyId
        self.engineId = engineId
        self.wheelId = wheelId
        self.carColor = carColor
    }
    
    var getCarColor: Color {
        switch carColor {
        case "red":
            return Color.red
        case "blue":
            return Color.blue
        case "yellow":
            return Color.yellow
        default:
            return Color.red
        }
    }
}
