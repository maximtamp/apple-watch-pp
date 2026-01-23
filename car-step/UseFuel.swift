//
//  UseFuel.swift
//  car-step
//
//  Created by Maxim Tampere on 09/01/2026.
//

import SwiftUI
import SwiftData

struct UseFuel: View {
    var fuel: Fuel
    var part: Part
    var today: Day
    var onClose: () -> Void
    
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData
    
    @Query private var parts: [Part]
    
    @State private var amountOfFuelUse: Int = 0
    @State private var useFuelState: String = "AmountPicking"
    
    @State private var partProgress: Double = 0
    
    @State private var createdPartName: String = ""
    @State private var createdPartType: String = ""
    @State private var createdPartRarity: String = ""
    
    var body: some View {
        if useFuelState == "AmountPicking" {
            VStack {
                HStack{
                    ZStack {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 20))
                    }
                    .frame(width: 32, height: 32)
                    .background(Color.red.opacity(0.5))
                    .cornerRadius(90)
                    Text("\(fuel.value)")
                }
                Text("How mutch Fuel do you wanne use?")
                Text("\(amountOfFuelUse)")
                .multilineTextAlignment(.center)
                .font(.title)
                
                let minValue = 0
                let maxValue = part.maxValue - part.progressValue
                
                HStack {
                    Button("-1%") {
                        amountOfFuelUse = max(minValue, amountOfFuelUse - fuel.value / 100)
                    }
                    .disabled(amountOfFuelUse - fuel.value / 100 < 0)
                    .buttonStyle(.bordered)
                    Button("-10%") {
                        amountOfFuelUse = max(minValue, amountOfFuelUse - fuel.value / 10)
                    }
                    .disabled(amountOfFuelUse - fuel.value / 10 < 0)
                    .buttonStyle(.bordered)
                    Button("+10%") {
                        amountOfFuelUse = min(maxValue, amountOfFuelUse + fuel.value / 10)
                    }
                    .buttonStyle(.bordered)
                    .disabled(amountOfFuelUse >= min(fuel.value, part.maxValue - part.progressValue))
                    Button("+1%") {
                        amountOfFuelUse = min(maxValue, amountOfFuelUse + fuel.value / 100)
                    }
                    .buttonStyle(.bordered)
                    .disabled(amountOfFuelUse >= min(fuel.value, part.maxValue - part.progressValue))
                }
                HStack {
                    Button("Min") {
                        amountOfFuelUse = 1
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(amountOfFuelUse <= 1)
                    Button("Max") {
                        amountOfFuelUse = min(fuel.value, part.maxValue - part.progressValue)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(amountOfFuelUse == part.maxValue - part.progressValue)
                }
                Button("Start") {
                    useFuelState = "Running"
                    
                    let newPartProgress = Double(part.progressValue + amountOfFuelUse) / Double(part.maxValue)
                    withAnimation(.linear(duration: max(3.0, Double(amountOfFuelUse) / 500.0))) {
                        partProgress = newPartProgress
                    } completion: {
                        appData.updateFuel(fuel: fuel, context: context, newValue: fuel.value - amountOfFuelUse)
                        appData.updateTodayUsedFuel(today: today, context: context, newValue: today.usedFuel + amountOfFuelUse)
                        if partProgress == 1.0 {
                            createdPartName = part.name
                            createdPartType = part.type.displayName
                            createdPartRarity = part.rarity.displayName
                            
                            useFuelState = "ShapeDone"
                            appData.finishedPart(part: part, context: context)
                            WatchConnectivitySync.shared.sendParts(parts)
                        } else {
                            useFuelState = "ShapeNotDone"
                            appData.updatePartProgrss(part: part, context: context, newValue: part.progressValue + amountOfFuelUse)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
                .disabled(amountOfFuelUse == 0)
            }
            .onAppear {
                partProgress = Double(part.progressValue) / Double(part.maxValue)
            }
        } else if useFuelState == "Running" {
            VStack {
                Spacer()
                part.getPartShape(neededPart: part.type, progress: partProgress, size: 300)
                Spacer()
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 300, height: 300)
        }
        if useFuelState == "ShapeDone" {
            Text("You have completed a part!")
                .font(.title)
            Text("\(part.name) has been added to you collection")
            VStack {
                Text("Name: \(createdPartName)")
                Text("Type: \(createdPartType)")
                Text("Rarity: \(createdPartRarity)")
            }
            Button("Back to Home"){
                onClose()
            }
        } else if useFuelState == "ShapeNotDone" {
            Text("Not Done")
            Button("Back to Home"){
                onClose()
            }
        }
    }
}

#Preview {
    let mockPart = Part(name: "Sparky", type: .wheel, rarity: .rare, partMade: false, progressValue: 0, maxValue: 10000, creationDate: .now)
    let mockFuel = Fuel(userId: UUID(), value: 8000)
    let mockToday = Day(id: UUID(), userId: UUID(), date: .now, totalSteps: 0, claimedSteps: 0, usedFuel: 0)
    UseFuel(fuel: mockFuel, part: mockPart, today: mockToday, onClose: {})
}
