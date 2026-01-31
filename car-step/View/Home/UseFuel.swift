//
//  UseFuel.swift
//  car-step
//
//  Created by Maxim Tampere on 09/01/2026.
//

import SwiftUI
import SwiftData

enum UseFuelState: String, Codable, CaseIterable {
    case amountPicking
    case running
    case shapeDone
    case shapeNotDone
}

struct UseFuel: View {
    var fuel: Fuel
    var part: Part
    var today: Day
    var onClose: () -> Void
    
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData
    
    @Query private var parts: [Part]
    
    @State private var amountOfFuelUse: Int = 0
    @State private var useFuelState: UseFuelState = .amountPicking
    @State private var partProgress: Double = 0
    @State private var createdPart: Part? = nil
    
    @State private var runRunning: Bool = false
    @State private var runEnd: Bool = false
    @State private var animatedFuelRemaining: Int = 0
    
    func handleStart() {
        runRunning = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            animatedFuelRemaining = amountOfFuelUse
            useFuelState = .running
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let newPartProgress = Double(part.progressValue + amountOfFuelUse) / Double(part.maxValue)
                let duration = max(3.0, Double(amountOfFuelUse) / 500.0)
                
                withAnimation(.linear(duration: duration)) {
                    partProgress = newPartProgress
                    animateFuelDown(duration: duration)
                } completion: {
                    runRunning = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        appData.updateFuel(fuel: fuel, newValue: fuel.value - amountOfFuelUse)
                        appData.updateTodayUsedFuel(today: today, newValue: today.usedFuel + amountOfFuelUse)
                        if partProgress == 1.0 {
                            createdPart = part
                            
                            useFuelState = .shapeDone
                            appData.finishedPart(part: part, context: context)
                            WatchConnectivitySync.shared.sendParts(parts)
                        } else {
                            useFuelState = .shapeNotDone
                            appData.updatePartProgrss(part: part, newValue: part.progressValue + amountOfFuelUse)
                        }
                    }
                }
            }
        }
    }
    
    func animateFuelDown(duration: Double) {
        guard amountOfFuelUse > 0 else { return }

        let steps = amountOfFuelUse
        let interval = duration / Double(steps)

        for i in 0...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * interval) {
                animatedFuelRemaining = max(0, amountOfFuelUse - i)
            }
        }
    }
    
    var body: some View {

        VStack{
            if useFuelState == .amountPicking {
                HStack {
                    HStack{
                        Button {
                            onClose()
                        } label: {
                            Image(systemName: "xmark")
                        }
                        .font(.title)
                        .foregroundStyle(Color("SecondaryAppColor").opacity(0.5))
                        Spacer()
                    }
                    Spacer()
                    ZStack {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 20))
                    }
                    .frame(width: 32, height: 32)
                    .background(Color.red.opacity(0.5))
                    .cornerRadius(90)
                    Text("\(fuel.value)")
                }
                .opacity(runRunning ? 0.0 : 1.0)
                .animation(.snappy(duration: 1.0), value: runRunning)
            }
        }
        .padding(24)
        .frame(height: 80)
        
        VStack {
            Spacer()
            if useFuelState == .shapeDone && (createdPart != nil){
                ZStack{
                    part.getPartShape(color: Color.black, neededPart: createdPart!.name, progress: partProgress, size: 225, lineWidth: 5)
                        .opacity(runEnd ? 0.0 : 1.0)
                        .animation(.snappy(duration: 1.5), value: runEnd)
                    Image("\(createdPart!.name.lowercased().replacingOccurrences(of: " ", with: "-"))-icon")
                        .resizable()
                        .scaledToFit()
                        .opacity(runEnd ? 1.0 : 0.0)
                        .animation(.snappy(duration: 3.0), value: runEnd)
                }
            } else {
                part.getPartShape(color: Color.black, neededPart: part.name, progress: useFuelState == .amountPicking ? part.progressPrecent : partProgress, size: 225, lineWidth: 5)
            }
            Spacer()
        }
        .frame(width: 250, height: 250)
        .padding(24)
        .background( useFuelState == .shapeDone && (createdPart != nil) ? createdPart!.getRarityColor(neededRarity: createdPart!.rarity) : part.getRarityColor(neededRarity: part.rarity))
        .cornerRadius(32)
        
        Spacer()
        switch useFuelState {
        case .amountPicking:
            VStack {
                VStack{
                    VStack(spacing: 12){
                        Text("How mutch Fuel do you wanne use?")
                            .bold()
                        Text("\(amountOfFuelUse)")
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .bold()
                    }
                    
                    let minValue = 0
                    let maxValue = min(fuel.value, part.maxValue - part.progressValue)
                    
                    VStack{
                        HStack {
                            TextButton(label: "-1%", disabled: amountOfFuelUse - fuel.value / 100 < 0){
                                amountOfFuelUse = max(minValue, amountOfFuelUse - fuel.value / 100)
                            }
                            
                            TextButton(label: "-10%", disabled: amountOfFuelUse - fuel.value / 10 < 0){
                                amountOfFuelUse = max(minValue, amountOfFuelUse - fuel.value / 10)
                            }
                            
                            TextButton(label: "+10%", disabled: amountOfFuelUse + fuel.value / 10 > maxValue){
                                amountOfFuelUse = min(maxValue, amountOfFuelUse + fuel.value / 10)
                            }
                            
                            TextButton(label: "+1%", disabled: amountOfFuelUse + fuel.value / 100 > maxValue){
                                amountOfFuelUse = min(maxValue, amountOfFuelUse + fuel.value / 100)
                            }
                        }
                        HStack {
                            TextButton(label: "Min", disabled: amountOfFuelUse <= 1){
                                amountOfFuelUse = 1
                            }
                            
                            TextButton(label: "Max", disabled: amountOfFuelUse == maxValue){
                                amountOfFuelUse = maxValue
                            }
                        }
                        
                        TextButton(label: "Start", disabled: amountOfFuelUse == 0){
                            handleStart()
                        }
                        .padding(.top, 20)
                    }
                    .padding()
                }
                .offset(
                    x: runRunning ? -600 : 0,
                    y: 0
                )
                .animation(.snappy(duration: 1.0), value: runRunning)
            }
            .onAppear {
                partProgress = Double(part.progressValue) / Double(part.maxValue)
            }
        case .running:
            HStack(spacing: 12) {
                ZStack {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 28))
                }
                .frame(width: 52, height: 52)
                .background(Color.red.opacity(0.5))
                .cornerRadius(90)
                
                Text("\(animatedFuelRemaining)")
                    .font(.largeTitle)
                    .bold()
            }
            .padding(.bottom, 160)
            .offset(
                x: 0,
                y: runRunning ? 300 : 0
            )
            .animation(.snappy(duration: 1.0), value: runRunning)
            .onAppear {
                runRunning = false
            }
        case .shapeDone:
            VStack(spacing: 80) {
                VStack {
                    Text("You have completed a part!")
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .bold()
                    Text("\(createdPart!.name) has been added to you collection")
                        .multilineTextAlignment(.center)
                }

                TextButton(label: "Close", disabled: false){
                    onClose()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
            .offset(
                x: runEnd ? 0 : 600,
                y: 0
            )
            .animation(.snappy(duration: 1.0), value: runEnd)
            .onAppear {
                runEnd = true
            }
        case .shapeNotDone:
            VStack(spacing: 120) {
                Text("Part not complete")
                    .font(.title)
                    .bold()
                TextButton(label: "Close", disabled: false){
                    onClose()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
            .offset(
                x: runEnd ? 0 : 600,
                y: 0
            )
            .animation(.snappy(duration: 1.0), value: runEnd)
            .onAppear {
                runEnd = true
            }
        }
    }
    
    @Animatable
    struct FuelText: View {
        var value: Double

        var body: some View {
            Text("\(Int(value))")
                .font(.largeTitle)
        }
    }

}

#Preview {
    let mockPart = Part(name: "Sparky", type: .wheel, rarity: .rare, partMade: false, progressValue: 0, maxValue: 10000, speedPoints: 10, creationDate: .now)
    let mockFuel = Fuel(userId: UUID(), value: 8000)
    let mockToday = Day(id: UUID(), userId: UUID(), date: .now, totalSteps: 0, claimedSteps: 0, usedFuel: 0)
    UseFuel(fuel: mockFuel, part: mockPart, today: mockToday, onClose: {})
}
