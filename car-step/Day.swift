//
//  Day.swift
//  car-step
//
//  Created by Maxim Tampere on 08/01/2026.
//

import Foundation
import SwiftData

@Model
class Day {
    var date: Date
    var totalSteps: Int
    var claimedSteps: Int
    var usedFuel: Int
    
    init(date: Date, totalSteps: Int, claimedSteps: Int, usedFuel: Int) {
        self.date = date
        self.totalSteps = totalSteps
        self.claimedSteps = claimedSteps
        self.usedFuel = usedFuel
    }
}
