//
//  UseFuel.swift
//  watch-car-step Watch App
//
//  Created by Maxim Tampere on 14/01/2026.
//

import SwiftUI
import SwiftData

struct UseFuel: View {
    var fuel: Fuel
    var part: Part
    var today: Day
    
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData
    @Environment(\.dismiss) private var dismiss
    
    @Query private var parts: [Part]
    
    @State private var amountOfFuelUse: Int = 0
    @State private var useFuelState: String = "AmountPicking"
    
    @State private var partProgress: Double = 0
    
    @State private var createdPartRarity: PartRarity = .common
    @State private var createdPartName: String = ""

    @State private var valuesToPickFrom: [Int] = []

    var body: some View {
        if useFuelState == "AmountPicking" {
            VStack {
                
                Picker("Amount Fuel Using", selection: $amountOfFuelUse) {
                    ForEach(valuesToPickFrom, id: \.self) { value in
                        Text("\(value)")
                    }
                }
                .pickerStyle(.wheel)
                .focusable(true)
                
                Button("Start") {
                    useFuelState = "Running"
                    
                    let newPartProgress = Double(part.progressValue + amountOfFuelUse) / Double(part.maxValue)
                    withAnimation(.linear(duration: max(3.0, Double(amountOfFuelUse) / 500.0))) {
                        partProgress = newPartProgress
                    } completion: {
                        appData.updateFuel(fuel: fuel, newValue: fuel.value - amountOfFuelUse)
                        appData.updateTodayUsedFuel(today: today, newValue: today.usedFuel + amountOfFuelUse)
                        if partProgress == 1.0 {
                            createdPartRarity = part.rarity
                            createdPartName = part.name
                            
                            useFuelState = "ShapeDone"
                            appData.finishedPart(part: part, context: context)
                            WatchConnectivitySync.shared.sendParts(parts)
                        } else {
                            useFuelState = "ShapeNotDone"
                            appData.updatePartProgrss(part: part, newValue: part.progressValue + amountOfFuelUse)
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 20)
                .disabled(amountOfFuelUse == 0)
            }
            .onAppear {
                valuesToPickFrom.removeAll()
                
                partProgress = Double(part.progressValue) / Double(part.maxValue)
                
                let maxUseableFuel = min(fuel.value, part.maxValue - part.progressValue)
                let steps = maxUseableFuel < 10 ? maxUseableFuel : 10
                
                for i in 0...steps {
                    valuesToPickFrom.append(Int(Double(i) / Double(steps) * Double(maxUseableFuel)))
                }
            }
        } else if useFuelState == "Running" {
            VStack {
                Spacer()
                part.getPartShape(color: Color.white, neededPart: part.name, progress: partProgress, size: 150, lineWidth: 3)
                Spacer()
            }
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 150, height: 150)
        }
        if useFuelState == "ShapeDone" {
            VStack(spacing: 12){
                VStack(spacing: 4){
                    Text("Part completed!")
                        .font(.title3)
                    VStack {
                        Image("\(createdPartName.lowercased().replacingOccurrences(of: " ", with: "-"))-icon")
                            .resizable()
                            .scaledToFit()
                            .padding(8)
                    }
                    .frame(width: 64, height: 64)
                    .background(part.getRarityColor(neededRarity: createdPartRarity))
                    .cornerRadius(8)
                }
                Button("Close"){
                    dismiss()
                }
            }
            
        } else if useFuelState == "ShapeNotDone" {
            Text("Part not done")
                .font(.title3)
            Button("Close"){
                dismiss()
            }
        }
    }
}

#Preview {
    let mockPart = Part(name: "Sparky", type: .wheel, rarity: .rare, partMade: false, progressValue: 0, maxValue: 10000, speedPoints: 10, creationDate: .now)
    let mockFuel = Fuel(userId: UUID(), value: 8000)
    let mockToday = Day(id: UUID(), userId: UUID(), date: .now, totalSteps: 0, claimedSteps: 0, usedFuel: 0)
    UseFuel(fuel: mockFuel, part: mockPart, today: mockToday)
}
