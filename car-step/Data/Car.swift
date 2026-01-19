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
    
    init(bodyId: UUID = UUID(), engineId: UUID = UUID(), wheelId: UUID = UUID()) {
        self.bodyId = bodyId
        self.engineId = engineId
        self.wheelId = wheelId
    }
}
