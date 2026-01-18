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
    var car: Car?
    
    func setup(
        context: ModelContext,
        manager: HealthKitManager,
        days: [Day],
        parts: [Part],
        fuels: [Fuel],
        cars: [Car],
    ) {
        setupDay(context: context, manager: manager, days: days)
        setupPart(context: context, parts: parts)
        setupFuel(context: context, fuels: fuels)
        setupCar(context: context, cars: cars, parts: parts)
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
        
        if !parts.isEmpty {
            if let unfinishedPart = parts.first(where: { !$0.partMade }) {
                part = unfinishedPart
            } else {
                if let randomPart = Part.possibleParts.randomElement(){
                    let newPart = Part(
                        name: randomPart.name,
                        type: randomPart.type,
                        rarity: randomPart.rarity,
                        partMade: false,
                        progressValue: 0,
                        maxValue: randomPart.maxValue,
                        creationDate: .now
                    )
                    context.insert(newPart)
                    self.part = newPart
                }
            }
        } else {
            context.insert(Part(name: "Shell Rover", type: "Body", rarity: "Common", partMade: true, progressValue: 3000, maxValue: 3000, creationDate: .now))
            context.insert(Part(name: "Engine V1", type: "Engine", rarity: "Common", partMade: true, progressValue: 2000, maxValue: 2000, creationDate: .now))
            context.insert(Part(name: "Ring Hoops", type: "Wheel", rarity: "Common", partMade: true, progressValue: 1000, maxValue: 1000, creationDate: .now))
            
            if let randomPart = Part.possibleParts.randomElement(){
                let newPart = Part(
                    name: randomPart.name,
                    type: randomPart.type,
                    rarity: randomPart.rarity,
                    partMade: false,
                    progressValue: 0,
                    maxValue: randomPart.maxValue,
                    creationDate: .now
                )
                context.insert(newPart)
                self.part = newPart
            }
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
    
    private func setupCar(context: ModelContext, cars: [Car], parts: [Part]) {
        if let existingCar = cars.first {
            car = existingCar
        } else {
            let newCar = Car(
                bodyId: parts.first(where: { $0.partMade == true && $0.type == "Body"})?.id ?? UUID(),
                engineId: parts.first(where: { $0.partMade == true && $0.type == "Engine"})?.id ?? UUID(),
                wheelId: parts.first(where: { $0.partMade == true && $0.type == "Wheel"})?.id ?? UUID(),
                carColor: "blue"
            )
            context.insert(newCar)
            car = newCar
        }
    }
    
    func finishedPart(part: Part, context: ModelContext) {
        part.progressValue = part.maxValue
        part.partMade = true
        part.creationDate = .now
        
        if let randomPart = Part.possibleParts.randomElement(){
            let newPart = Part(
                name: randomPart.name,
                type: randomPart.type,
                rarity: randomPart.rarity,
                partMade: false,
                progressValue: 0,
                maxValue: randomPart.maxValue,
                creationDate: .now
            )
            context.insert(newPart)
            self.part = newPart
            WatchConnectivitySync.shared.sendPart(part)
        }
    }
    
    func updatePartProgrss(part: Part, context: ModelContext, newValue: Int) {
        part.progressValue = newValue
        WatchConnectivitySync.shared.sendPart(part)
    }
    
    func updateFuel(fuel: Fuel, context: ModelContext, newValue: Int) {
        fuel.value = newValue
        WatchConnectivitySync.shared.sendFuel(fuel)
    }
    
    func updateCarPartId(car: Car, context: ModelContext, partType: String, newID: UUID = UUID()) {
        switch partType {
        case "Body":
            car.bodyId = newID
        case "Engine":
            car.engineId = newID
        case "Wheel":
            car.wheelId = newID
        default:
            print("No type found")
        }
        
        WatchConnectivitySync.shared.sendCar(car)
    }
    
    func updateTodaySteps(context: ModelContext, manager: HealthKitManager, today: Day) {
        let todayDate = Calendar.current.startOfDay(for: .now)
        
        if Calendar.current.isDate(today.date, inSameDayAs: todayDate) {
            today.totalSteps = manager.getTodaySteps()
        } else {
            let newDay = Day(
                date: todayDate,
                totalSteps: 0,
                claimedSteps: 0,
                usedFuel: 0
            )
            context.insert(newDay)
            self.today = newDay
            today.totalSteps = manager.getTodaySteps()
        }
    }
}
