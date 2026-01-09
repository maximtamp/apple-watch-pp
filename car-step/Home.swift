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
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData
    
   
        
    func todayDate() -> Date {
        Calendar.current.startOfDay(for: .now)
    }
            
    var body: some View {
        ScrollView{
        VStack {
            if let today = appData.today, let part = appData.part, let fuel = appData.fuel {
                CanvasTests(progress: part.progressPrecent)
                
                VStack {
                    HStack {
                        Button("Claim Step") {
                            today.claimedSteps += today.totalSteps - today.claimedSteps
                            fuel.value += today.claimedSteps - today.usedFuel
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(today.totalSteps - today.claimedSteps == 0)
                        Button("Use Fuel") {
                            part.progressValue += fuel.value
                            today.usedFuel += fuel.value
                            fuel.value = 0
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(fuel.value == 0)
                    }
                    .padding(.vertical, 20)
                    
                    HStack{
                        Card(value: today.totalSteps, name: "Total Steps", image: Image(systemName: "figure.walk"), color: .blue)
                        Card(value: fuel.value, name: "Fuel", image: Image(systemName: "bolt.fill"), color: .red)
                    }
                    Card(value: today.totalSteps - today.claimedSteps, name: "Claimable steps", image: Image(systemName: "hand.point.up.left.fill"), color: .yellow)
                }
                
            } else {
                ProgressView("Loading Today's Steps")
            }
        }
        .padding()
        .onChange(of: manager.steps) {
            appData.today?.totalSteps = manager.steps
        }
    }
    .refreshable {
        manager.fetchTodaySteps()
    }
    }
    
}

#Preview {
    Home()
        .environmentObject(HealthKitManager(preview: true))
        .environment(AppData())
        .modelContainer(for: Day.self, inMemory: true)
}
