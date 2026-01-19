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
    var todayQuests: [Quest]? = []
    
    private func getTodaysDate() -> Date {
        Calendar.current.startOfDay(for: .now)
    }
    
    func isTodaysDate (_ date: Date) -> Bool {
        let todayDate = getTodaysDate()
        return Calendar.current.isDate(date, inSameDayAs: todayDate)
    }
    
    func setup(
        context: ModelContext,
        manager: HealthKitManager,
        days: [Day],
        parts: [Part],
        fuels: [Fuel],
        cars: [Car],
    ) {
        setupDay(context: context, manager: manager, days: days)
        setupFuel(context: context, fuels: fuels)
        setupCar(context: context, cars: cars, parts: parts)
        setupPart(context: context, parts: parts)
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
            )
            context.insert(newCar)
            car = newCar
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
            let defaultBody = Part(name: "Shell Rover", type: "Body", rarity: "Common", partMade: true, progressValue: 3000, maxValue: 3000, creationDate: .now)
            context.insert(defaultBody)
            
            let defaultEngine = Part(name: "Engine V1", type: "Engine", rarity: "Common", partMade: true, progressValue: 2000, maxValue: 2000, creationDate: .now)
            context.insert(defaultEngine)
            
            let defaultWheel = Part(name: "Ring Hoops", type: "Wheel", rarity: "Common", partMade: true, progressValue: 1000, maxValue: 1000, creationDate: .now)
            context.insert(defaultWheel)
            
            placeDefaultPartsInCar(bodyId: defaultBody.id, engineId: defaultEngine.id, wheelId: defaultWheel.id)
            
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
    
    private func placeDefaultPartsInCar(bodyId: UUID, engineId: UUID, wheelId: UUID){
        self.car?.bodyId = bodyId
        self.car?.engineId = engineId
        self.car?.wheelId = wheelId
    }
    
    func setupQuests(context: ModelContext, quests: [Quest]){
        let todayDate = Calendar.current.startOfDay(for: .now)
        var todayQuests = quests.filter{
            Calendar.current.isDate($0.date, inSameDayAs: todayDate)
        }
        
        if todayQuests.count >= 3 {
            self.todayQuests = todayQuests
            return
        }
        
        let usedTypes = Set(todayQuests.map { $0.type })

        var availableTypes = QuestType.allCases.filter {
            !usedTypes.contains($0)
        }

        availableTypes.shuffle()

        let amountToCreate = min(3 - todayQuests.count, availableTypes.count)

        for type in availableTypes.prefix(amountToCreate) {
            let newQuest = questMaker(type: type, date: todayDate)
            context.insert(newQuest)
            todayQuests.append(newQuest)
        }
        
        self.todayQuests = todayQuests
    }
    
    private func questMaker(type: QuestType, date: Date) -> Quest {
        switch type {
        case .placeSteps:
            let possibleValues = [1000, 2500, 5000, 7500, 10000]
            let value = possibleValues.randomElement()!
            
            return Quest(
                date: date,
                title: "Place \(value) steps",
                type: .placeSteps,
                currentValue: 0,
                neededValue: value,
                claimed: false,
                fuelReward: value / 2
            )
            
        case .useFuel:
            let possibleValues = [1000, 2500, 5000, 7500, 10000, 12500, 15000]
            let value = possibleValues.randomElement()!
            
            return Quest(
                date: date,
                title: "Use \(value) fuel",
                type: .useFuel,
                currentValue: 0,
                neededValue: value,
                claimed: false,
                fuelReward: value / 2
            )
            
        case .makeParts:
            let possibleValues = [1, 2, 3]
            let value = possibleValues.randomElement()!
            
            return Quest(
                date: date,
                title: "Make \(value) parts",
                type: .makeParts,
                currentValue: 0,
                neededValue: value,
                claimed: false,
                fuelReward: value * 3000
            )
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
    
    func updateTodayUsedFuel(today: Day, context: ModelContext, newValue: Int) {
        today.usedFuel = newValue
        WatchConnectivitySync.shared.sendToday(today)
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
        let todayDate = getTodaysDate()
        
        if isTodaysDate(today.date) {
            today.totalSteps = manager.getTodaySteps()
        } else {
            let newDay = Day(
                date: todayDate,
                totalSteps: manager.getTodaySteps(),
                claimedSteps: 0,
                usedFuel: 0
            )
            context.insert(newDay)
            self.today = newDay
        }
    }
    
    func checkTodayQuestProgress(todayQuests: [Quest], today: Day, parts: [Part]) {
        guard let firstQuest = todayQuests.first, isTodaysDate(firstQuest.date) else { return }
        
        todayQuests.forEach{ quest in
            switch quest.type {
            case .placeSteps:
                quest.currentValue = today.totalSteps
            case .useFuel:
                quest.currentValue = today.usedFuel
            case .makeParts:
                quest.currentValue = parts.filter{ $0.partMade && isTodaysDate($0.creationDate) }.count
            }
        }
    }
    
    func claimQuestReward(quest: Quest, fuel: Fuel) {
        guard isTodaysDate(quest.date) else { return }
        
        quest.claimed = true
        fuel.value += quest.fuelReward
        WatchConnectivitySync.shared.sendFuel(fuel)
    }
    
    func checkTodayQuests(context: ModelContext, quests: [Quest]) {
        let todayQuests = quests.filter { isTodaysDate($0.date) }
        
        if todayQuests.count < 3 {
            setupQuests(context: context, quests: quests)
        } else {
            self.todayQuests = todayQuests
        }
    }
}
