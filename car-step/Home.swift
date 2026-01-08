//
//  Home.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI
import SwiftData

struct Home: View {
    @EnvironmentObject var manager: HealthKitManager
    
    @Query private var days: [Day]
    @Environment(\.modelContext) private var context
    
    @Query private var parts: [Part]
    @Query private var fuels: [Fuel]
    
    @State private var today: Day?
    @State private var part: Part?
    @State private var fuel: Fuel?
        
    func todayDate() -> Date {
        Calendar.current.startOfDay(for: .now)
    }
            
    var body: some View {

        VStack {
            if let today, let part, let fuel {
                ProgressBar(
                    progress: part.progressPrecent,
                    valueText: "\(part.progressValue) / \(part.maxValue)"
                )
                    .padding(.bottom, 40)
                
                Card(value: today.totalSteps, name: "Total Steps", image: Image(systemName: "figure.walk"), color: .blue)
                Card(value: today.totalSteps - today.claimedSteps, name: "Steps Left To Claim", image: Image(systemName: "hand.point.up.left.fill"), color: .yellow)
                Card(value: today.claimedSteps, name: "Claimed steps", image: Image(systemName: "basket"), color: .green)
                Card(value: fuel.value, name: "Fuel", image: Image(systemName: "bolt.fill"), color: .red)
                
                HStack {
                    Button("Claim Step") {
                        today.claimedSteps += today.totalSteps - today.claimedSteps
                        fuel.value += today.claimedSteps - today.usedFuel
                    }
                    .buttonStyle(.bordered)
                    .disabled(today.totalSteps - today.claimedSteps == 0)
                    Button("Use Fuel") {
                        part.progressValue += fuel.value
                        today.usedFuel += fuel.value
                        fuel.value = 0
                    }
                    .buttonStyle(.bordered)
                    .disabled(fuel.value == 0)
                }
                .padding(.vertical, 20)
                Button("Refresh Steps") {
                    manager.fetchTodaySteps()
                }
            } else {
                ProgressView("Loading Today's Steps")
            }
        }
        .padding()
        .onAppear {
            if let existing = days.first(where: { Calendar.current.isDate($0.date, inSameDayAs: todayDate()) }) { today = existing
            } else {
                let newDay = Day(
                    date: todayDate(),
                    totalSteps: manager.steps,
                    claimedSteps: 0,
                    usedFuel: 0
                )
                context.insert(newDay)
                today = newDay
            }
            
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
            
            if let existingFuel = fuels.first {
                fuel = existingFuel
            } else {
                let newFuel = Fuel(value: 0)
                context.insert(newFuel)
                fuel = newFuel
            }
        }
        .onChange(of: manager.steps) {
            today?.totalSteps = manager.steps
        }
    }
}

#Preview {
    Home()
}
