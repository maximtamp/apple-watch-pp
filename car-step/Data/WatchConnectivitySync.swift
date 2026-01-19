//
//  WatchConnectivitySync.swift
//  car-step
//
//  Created by Maxim Tampere on 17/01/2026.
//

import WatchConnectivity
import SwiftData
import Foundation

final class WatchConnectivitySync: NSObject, WCSessionDelegate {

    static let shared = WatchConnectivitySync()

    private override init() {}

    private var context: ModelContext?
    var appData: AppData?

    func setup(context: ModelContext, appData: AppData) {
        self.context = context
        self.appData = appData

        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }
    
    func sendSetup(days: [Day], parts: [Part], fuel: Fuel, car: Car) {
        let daysData = days.map { day in
            [
                "date": day.date.timeIntervalSince1970,
                "totalSteps": day.totalSteps,
                "claimedSteps": day.claimedSteps,
                "usedFuel": day.usedFuel
            ]
        }
        let partsData = parts.map { part in
            [
                "id": part.id.uuidString,
                "name": part.name,
                "type": part.type,
                "rarity": part.rarity,
                "partMade": part.partMade,
                "progressValue": part.progressValue,
                "maxValue": part.maxValue,
                "creationDate": part.creationDate.timeIntervalSince1970
            ]
        }
        
        let data = [
            "dataType": "setup",
            "days": daysData,
            "parts": partsData,
            "fuel": [
                "value": fuel.value
            ],
            "car": [
                "bodyId": car.bodyId.uuidString,
                "engineId": car.engineId.uuidString,
                "wheelId": car.wheelId.uuidString,
            ]
        ] as [String : Any]

        send(data)
    }

    func send(_ data: [String: Any]) {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(data, replyHandler: nil)
        }

        WCSession.default.transferUserInfo(data)
    }
    
    func sendDays(_ days: [Day]) {
        let daysData = days.map { day in
            [
                "date": day.date.timeIntervalSince1970,
                "totalSteps": day.totalSteps,
                "claimedSteps": day.claimedSteps,
                "usedFuel": day.usedFuel
            ]
        }
        
        send([
            "dataType": "days",
            "days": daysData
        ])
    }
    
    func sendToday(_ today: Day) {
        let todayData = [
            "date": today.date.timeIntervalSince1970,
            "totalSteps": today.totalSteps,
            "claimedSteps": today.claimedSteps,
            "usedFuel": today.usedFuel
        ] as [String : Any]
        
        send([
            "dataType": "today",
            "today": todayData
        ])
    }
    
    func sendParts(_ parts: [Part]) {
        let partsData = parts.map { part in
            [
                "id": part.id.uuidString,
                "name": part.name,
                "type": part.type,
                "rarity": part.rarity,
                "partMade": part.partMade,
                "progressValue": part.progressValue,
                "maxValue": part.maxValue,
                "creationDate": part.creationDate.timeIntervalSince1970
            ]
        }
        
        send([
            "dataType": "parts",
            "parts": partsData
        ])
    }
    
    func sendPart(_ part: Part) {
        let partData = [
            "id": part.id.uuidString,
            "name": part.name,
            "type": part.type,
            "rarity": part.rarity,
            "partMade": part.partMade,
            "progressValue": part.progressValue,
            "maxValue": part.maxValue,
            "creationDate": part.creationDate.timeIntervalSince1970
        ] as [String : Any]
        
        send([
            "dataType": "part",
            "part": partData
        ])
    }
    
    func sendFuel(_ fuel: Fuel) {
        let fuelData = [
            "value": fuel.value
        ] as [String : Any]
        
        send([
            "dataType": "fuel",
            "fuel": fuelData
        ])
    }
    
    func sendCar(_ car: Car) {
        let carData = [
            "bodyId": car.bodyId.uuidString,
            "engineId": car.engineId.uuidString,
            "wheelId": car.wheelId.uuidString,
        ] as [String : Any]
        
        send([
            "dataType": "car",
            "car": carData
        ])
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        handleData(message)
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any]) {
        handleData(userInfo)
    }
    
    private func handleData(_ data: [String: Any]) {
        guard let type = data["dataType"] as? String else { return }

        DispatchQueue.main.async {
            switch type {
            case "setup":
                self.handleSetup(data)
            case "days":
                self.handleDays(data)
            case "today":
                self.handleToday(data)
            case "parts":
                self.handleParts(data)
            case "part":
                self.handlePart(data)
            case "fuel":
                self.handleFuel(data)
            case "car":
                self.handleCar(data)
            default:
                break
            }
        }
    }
    
    private func handleSetup(_ data: [String: Any]) {
        handleDays(data)
        handleParts(data)
        handleFuel(data)
        handleCar(data)
        
        UserDefaults.standard.set(true, forKey: "isSetup")
    }
    
    private func handleDays(_ data: [String: Any]) {
        guard let days = data["days"] as? [[String: Any]],
              let context else { return }
        
        let fetch = FetchDescriptor<Day>()
        let existingDays = (try? context.fetch(fetch)) ?? []
        
        existingDays.forEach{ context.delete($0) }
        
        appData?.today = nil
        let today = Calendar.current.startOfDay(for: Date())
        
        for day in days {
            guard let date = day["date"] as? TimeInterval,
                  let totalSteps = day["totalSteps"] as? Int,
                  let claimedSteps = day["claimedSteps"] as? Int,
                  let usedFuel = day["usedFuel"] as? Int else { continue }
            
            let newDay = Day(
                date: Date(timeIntervalSince1970: date),
                totalSteps: totalSteps,
                claimedSteps: claimedSteps,
                usedFuel: usedFuel,
            )
            
            context.insert(newDay)
            
            if Calendar.current.isDate(Date(timeIntervalSince1970: date), inSameDayAs: today) {
                appData?.today = newDay
            }
        }
        
        try? context.save()
    }
    
    private func handleToday(_ data: [String: Any]) {
        guard let today = data["today"] as? [String: Any],
              let date = today["date"] as? TimeInterval,
              let totalSteps = today["totalSteps"] as? Int,
              let claimedSteps = today["claimedSteps"] as? Int,
              let usedFuel = today["usedFuel"] as? Int else { return }
        
        if let existing = appData?.today {
            existing.date = Date(timeIntervalSince1970: date)
            existing.totalSteps = totalSteps
            existing.claimedSteps = claimedSteps
            existing.usedFuel = usedFuel
        } else if let context {
            let newDay = Day(
                date: Date(timeIntervalSince1970: date),
                totalSteps: totalSteps,
                claimedSteps: claimedSteps,
                usedFuel: usedFuel,
            )
            context.insert(newDay)
            appData?.today = newDay
        }
    }
    
    private func handleParts(_ data: [String: Any]) {
        guard let partsArray = data["parts"] as? [[String: Any]],
              let context else { return }

        let fetch = FetchDescriptor<Part>()
        let existing = (try? context.fetch(fetch)) ?? []

        existing.forEach { context.delete($0)}

        appData?.part = nil

        for dict in partsArray {
            guard
                let idStr = dict["id"] as? String,
                let id = UUID(uuidString: idStr),
                let name = dict["name"] as? String,
                let type = dict["type"] as? String,
                let rarity = dict["rarity"] as? String,
                let partMade = dict["partMade"] as? Bool,
                let progressValue = dict["progressValue"] as? Int,
                let maxValue = dict["maxValue"] as? Int,
                let creationDate = dict["creationDate"] as? TimeInterval else { continue }

            let newPart = Part(
                id: id,
                name: name,
                type: type,
                rarity: rarity,
                partMade: partMade,
                progressValue: progressValue,
                maxValue: maxValue,
                creationDate: Date(timeIntervalSince1970: creationDate)
            )

            context.insert(newPart)

            if appData?.part == nil && !partMade {
                appData?.part = newPart
            }
        }

        try? context.save()
    }

    
    private func handlePart(_ data: [String: Any]) {
        guard let part = data["part"] as? [String: Any],
              let idStr = part["id"] as? String,
              let id = UUID(uuidString: idStr),
              let partMade = part["partMade"] as? Bool,
              let progressValue = part["progressValue"] as? Int else { return }
        
        if let existing = appData?.part, existing.id == id {
            existing.partMade = partMade
            existing.progressValue = progressValue
        }
    }
    
    private func handleFuel(_ data: [String: Any]) {
        guard let fuel = data["fuel"] as? [String: Any],
              let value = fuel["value"] as? Int else { return }
        
        if let existing = appData?.fuel {
            existing.value = value
        } else if let context {
            let newFuel = Fuel(value: value)
            context.insert(newFuel)
            appData?.fuel = newFuel
        }
    }
    
    private func handleCar(_ data: [String: Any]) {
        guard let car = data["car"] as? [String: Any],
              let bodyIdStr = car["bodyId"] as? String,
              let bodyId = UUID(uuidString: bodyIdStr),
              let engineIdStr = car["engineId"] as? String,
              let engineId = UUID(uuidString: engineIdStr),
              let wheelIdStr = car["wheelId"] as? String,
              let wheelId = UUID(uuidString: wheelIdStr) else { return }
        
        if let existing = appData?.car {
            existing.bodyId = bodyId
            existing.engineId = engineId
            existing.wheelId = wheelId
        } else if let context {
            let newCar = Car(
                bodyId: bodyId,
                engineId: engineId,
                wheelId: wheelId,
            )
            context.insert(newCar)
            appData?.car = newCar
        }
    }

    func session(_ session: WCSession,
                 activationDidCompleteWith activationState: WCSessionActivationState,
                 error: Error?) {}

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) {}
    func sessionDidDeactivate(_ session: WCSession) { session.activate() }
    #endif
}
