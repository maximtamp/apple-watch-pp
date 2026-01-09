//
//  AppData.swift
//  car-step
//
//  Created by Maxim Tampere on 09/01/2026.
//

import SwiftUI
import SwiftData

@Observable
class AppData {
    var today: Day?
    var part: Part?
    var fuel: Fuel?
    
    func setup(
        context: ModelContext,
        manager: HealthKitManager,
        days: [Day],
        parts: [Part],
        fuels: [Fuel]
    ) {
        setupDay(context: context, manager: manager, days: days)
        setupPart(context: context, parts: parts)
        setupFuel(context: context, fuels: fuels)
    }
    
    private func setupDay(
        context: ModelContext,
        manager: HealthKitManager,
        days: [Day]
    )  {
        let todayDate = Calendar.current.startOfDay(for: .now)
        
        if let existing = days.first(where: { Calendar.current.isDate($0.date, inSameDayAs: todayDate) }) {
            today = existing
        } else {
            let newDay = Day(
                date: todayDate,
                totalSteps: 0,
                claimedSteps: 0,
                usedFuel: 0
            )
            context.insert(newDay)
            today = newDay
        }
    }
    
    private func setupPart(context: ModelContext, parts: [Part]) {
        if let unfinishedPart = parts.first(where: { !$0.partMade }) {
            part = unfinishedPart
        } else {
            let newPart = Part(
                name: "Flitser",
                type: "Wheel",
                partMade: false,
                progressValue: 0,
                maxValue: 10000
            )
            context.insert(newPart)
            part = newPart
        }
    }
    
    private func setupFuel(context: ModelContext, fuels: [Fuel]) {
        if let existingFuel = fuels.first {
            fuel = existingFuel
        } else {
            let newFuel = Fuel(value: 0)
            context.insert(newFuel)
            fuel = newFuel
        }
    }
}
