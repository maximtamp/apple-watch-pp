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
    
    var currentUserId: UUID
    var didJustLogin: Bool = false
    
    init(currentUserId: UUID){
        self.currentUserId = currentUserId
    }
    
    private func getTodaysDate() -> Date {
        Calendar.current.startOfDay(for: .now)
    }
    
    func isTodaysDate (_ date: Date) -> Bool {
        let todayDate = getTodaysDate()
        return Calendar.current.isDate(date, inSameDayAs: todayDate)
    }
    
    func loadFromSupabase(context: ModelContext, existingDays: [Day], existingParts: [Part], existingFuels: [Fuel], existingCars: [Car], existingQuests: [Quest]) async -> (days: [Day], parts: [Part], fuels: [Fuel], cars: [Car], quests: [Quest]) {
        let result = await SupabaseService.shared.fetchAll(userId: currentUserId)
        
        for day in result.days where !existingDays.contains(where: { $0.id == day.id }) {
            context.insert(day)
        }
        
        for part in result.parts where !existingParts.contains(where: { $0.id == part.id }) {
            context.insert(part)
        }
        
        for fuel in result.fuels where !existingFuels.contains(where: { $0.userId == fuel.userId }) {
            context.insert(fuel)
        }
        
        for car in result.cars where !existingCars.contains(where: { $0.userId == car.userId }) {
            context.insert(car)
        }
        
        for quest in result.quests where !existingQuests.contains(where: { $0.id == quest.id }) {
            context.insert(quest)
        }
        
        try? context.save()
        
        return result
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
    
    private func setupDay( context: ModelContext, manager: HealthKitManager, days: [Day])  {
        let todayDate = Calendar.current.startOfDay(for: .now)
        
        if let existing = days.first(where: { Calendar.current.isDate($0.date, inSameDayAs: todayDate) }) {
            today = existing
        } else {
            let newDay = Day(
                id: UUID(),
                userId: currentUserId,
                date: todayDate,
                totalSteps: 0,
                claimedSteps: 0,
                usedFuel: 0
            )
            context.insert(newDay)
            today = newDay
            
            Task {
                await SupabaseService.shared.insertDay(newDay)
            }
        }
    }
    
    
    private func setupFuel(context: ModelContext, fuels: [Fuel]) {
        if let existingFuel = fuels.first {
            fuel = existingFuel
        } else {
            let newFuel = Fuel(userId: currentUserId, value: 0)
            context.insert(newFuel)
            fuel = newFuel
            
            Task {
                await SupabaseService.shared.insertFuel(newFuel)
            }
        }
    }
    
    private func setupCar(context: ModelContext, cars: [Car], parts: [Part]) {
        if let existingCar = cars.first {
            car = existingCar
        } else {
            let newCar = Car(
                userId: currentUserId,
                bodyId: parts.first(where: { $0.partMade == true && $0.type == .body})?.id ?? UUID(),
                engineId: parts.first(where: { $0.partMade == true && $0.type == .engine})?.id ?? UUID(),
                wheelId: parts.first(where: { $0.partMade == true && $0.type == .wheel})?.id ?? UUID(),
            )
            context.insert(newCar)
            car = newCar
            
            Task{
                await SupabaseService.shared.insertCar(newCar)
            }
        }
    }
    
    private func setupPart(context: ModelContext, parts: [Part]) {
        
        if !parts.isEmpty {
            if let unfinishedPart = parts.first(where: { !$0.partMade }) {
                part = unfinishedPart
            } else {
                if let randomPart = Part.possibleParts.randomElement(){
                    let newPart = Part(
                        userId: currentUserId,
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
                    
                    Task{
                        await SupabaseService.shared.insertPart(newPart)
                    }
                }
            }
        } else {
            let defaultBody = Part(userId: currentUserId, name: "Shell Rover", type: .body, rarity: .common, partMade: true, progressValue: 3000, maxValue: 3000, creationDate: .now)
            let defaultEngine = Part(userId: currentUserId, name: "Engine V1", type: .engine, rarity: .common, partMade: true, progressValue: 2000, maxValue: 2000, creationDate: .now)
            let defaultWheel = Part(userId: currentUserId, name: "Ring Hoops", type: .wheel, rarity: .common, partMade: true, progressValue: 1000, maxValue: 1000, creationDate: .now)
            
            context.insert(defaultBody)
            context.insert(defaultEngine)
            context.insert(defaultWheel)
            
            Task{
                await SupabaseService.shared.insertPart(defaultBody)
                await SupabaseService.shared.insertPart(defaultEngine)
                await SupabaseService.shared.insertPart(defaultWheel)
            }
            
            placeDefaultPartsInCar(bodyId: defaultBody.id, engineId: defaultEngine.id, wheelId: defaultWheel.id)
            
            if let randomPart = Part.possibleParts.randomElement(){
                let newPart = Part(
                    userId: currentUserId,
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
                
                Task{
                    await SupabaseService.shared.insertPart(newPart)
                }
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
            Task {
                await SupabaseService.shared.insertQuest(newQuest)
            }
        }
        
        self.todayQuests = todayQuests
    }
    
    private func questMaker(type: QuestType, date: Date) -> Quest {
        switch type {
        case .placeSteps:
            let possibleValues = [1000, 2500, 5000, 7500, 10000]
            let value = possibleValues.randomElement()!
            
            return Quest(
                userId: currentUserId,
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
                userId: currentUserId,
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
                userId: currentUserId,
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
        
        Task {
            await SupabaseService.shared.updatePart(part)
        }
        
        if let randomPart = Part.possibleParts.randomElement(){
            let newPart = Part(
                userId: currentUserId,
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
            Task {
                await SupabaseService.shared.insertPart(newPart)
            }
        }
    }
    
    func updatePartProgrss(part: Part, context: ModelContext, newValue: Int) {
        part.progressValue = newValue
        WatchConnectivitySync.shared.sendPart(part)
        Task {
            await SupabaseService.shared.updatePart(part)
        }
    }
    
    func updateFuel(fuel: Fuel, context: ModelContext, newValue: Int) {
        fuel.value = newValue
        WatchConnectivitySync.shared.sendFuel(fuel)
        Task {
            await SupabaseService.shared.updateFuel(fuel)
        }
    }
    
    func updateTodayUsedFuel(today: Day, context: ModelContext, newValue: Int) {
        today.usedFuel = newValue
        WatchConnectivitySync.shared.sendToday(today)
        Task {
            await SupabaseService.shared.updateDay(today)
        }
    }
    
    func updateCarPartId(car: Car, context: ModelContext, partType: PartType, newID: UUID = UUID()) {
        switch partType {
        case .body:
            car.bodyId = newID
        case .engine:
            car.engineId = newID
        case .wheel:
            car.wheelId = newID
        }
        
        WatchConnectivitySync.shared.sendCar(car)
        Task {
            await SupabaseService.shared.updateCar(car)
        }
    }
    
    func updateTodaySteps(context: ModelContext, manager: HealthKitManager, today: Day) {
        let todayDate = getTodaysDate()
        
        if isTodaysDate(today.date) {
            today.totalSteps = manager.getTodaySteps()
            Task {
                await SupabaseService.shared.updateDay(today)
            }
        } else {
            let newDay = Day(
                id: UUID(),
                userId: currentUserId,
                date: todayDate,
                totalSteps: manager.getTodaySteps(),
                claimedSteps: 0,
                usedFuel: 0
            )
            context.insert(newDay)
            self.today = newDay
            
            Task {
                await SupabaseService.shared.insertDay(newDay)
            }
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
            
            Task {
                await SupabaseService.shared.updateQuest(quest)
            }
        }
    }
    
    func claimQuestReward(quest: Quest, fuel: Fuel) {
        guard isTodaysDate(quest.date) else { return }
        
        quest.claimed = true
        fuel.value += quest.fuelReward
        WatchConnectivitySync.shared.sendFuel(fuel)
        
        Task {
            await SupabaseService.shared.updateQuest(quest)
            await SupabaseService.shared.updateFuel(fuel)
        }
    }
    
    func checkTodayQuests(context: ModelContext, quests: [Quest]) {
        let todayQuests = quests.filter { isTodaysDate($0.date) }
        print(todayQuests)
        
        if todayQuests.count < 3 {
            setupQuests(context: context, quests: quests)
        } else {
            self.todayQuests = todayQuests
        }
    }
    
    func resetApp(context: ModelContext) async {
        
        func deleteAll<T: PersistentModel>(_ type: T.Type) {
            let descriptor = FetchDescriptor<T>()
            if let results = try? context.fetch(descriptor) {
                results.forEach { context.delete($0) }
            }
        }

        deleteAll(Day.self)
        deleteAll(Part.self)
        deleteAll(Fuel.self)
        deleteAll(Car.self)
        deleteAll(Quest.self)

        try? context.save()

        today = nil
        part = nil
        fuel = nil
        car = nil
        todayQuests = []

        currentUserId = UUID()
        didJustLogin = false
    }
    
    func setUserIdInStorage(_ userId: String){
        
    }
}
