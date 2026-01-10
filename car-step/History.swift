//
//  History.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI
import SwiftData

struct History: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    @EnvironmentObject var manager: HealthKitManager

    @Query private var days: [Day]
    @Query private var parts: [Part]
    
    var body: some View {
        List(days, id: \.date) { day in
            VStack {
                Text(day.date.formatted(date: .abbreviated, time: .omitted))
                HStack {
                    VStack {
                        Text("Total Steps")
                        Text("\(day.totalSteps)")
                    }
                    VStack {
                        Text("Claimed Steps")
                        Text("\(day.claimedSteps)")
                    }
                    VStack {
                        Text("Used Fuel")
                        Text("\(day.usedFuel)")
                    }
                }
            }
        }
        .refreshable {
            manager.fetchTodaySteps()
        }
        List(parts) { part in
            VStack {
                Text("Name: \(part.name)")
                Text("Type: \(part.type)")
                Text("Rarity: \(part.rarity)")
                Text("Part Made: \(part.partMade ? "Yes" : "No")")
                Text("Progress: \(part.progressValue) / \(part.maxValue)")
                Text("Created at: \(part.creationDate)")
            }
        }
        Button("Onboarding") {
            isOnboarding = true
        }
    }
}

#Preview {
    History()
}
