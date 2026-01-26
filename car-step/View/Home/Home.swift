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
    
    @State private var showUseFuelPopover: Bool = false
    @State private var showRacePopover: Bool = false
    @Query var parts: [Part]
    
    func closeUseFuelPopover() {
        showUseFuelPopover = false
    }
    
    func closeRacelPopover() {
        showRacePopover = false
    }
            
    var body: some View {

        if let today = appData.today, let part = appData.part, let fuel = appData.fuel {
            ScrollView{
                HomeShapeView(part: part)
                VStack {
                    HStack {
                        Button("Claim Step") {
                            fuel.value += today.totalSteps - today.claimedSteps
                            today.claimedSteps += today.totalSteps - today.claimedSteps
                            
                            try? context.save()
                            
                            Task{
                                await SupabaseService.shared.updateDay(today)
                                await SupabaseService.shared.updateFuel(fuel)
                            }
                            WatchConnectivitySync.shared.sendToday(today)
                            WatchConnectivitySync.shared.sendFuel(fuel)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(today.totalSteps - today.claimedSteps == 0)
                        Button("Use Fuel") {
                            showUseFuelPopover = true
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(fuel.value == 0)
                        .popover(isPresented: $showUseFuelPopover) {
                            UseFuel(
                                fuel: fuel,
                                part: part,
                                today: today,
                                onClose: closeUseFuelPopover
                            )
                        }
                        
                        Button("Race") {
                            showRacePopover = true
                        }
                        .buttonStyle(.borderedProminent)
                        .popover(isPresented: $showRacePopover) {
                            RaceView(
                                onClose: closeRacelPopover
                            )
                        }
                    }
                    .padding(.vertical, 20)
                    
                    HStack{
                        Card(value: today.totalSteps, name: "Total Steps", image: Image(systemName: "figure.walk"), color: .blue)
                        Card(value: fuel.value, name: "Fuel", image: Image(systemName: "bolt.fill"), color: .red)
                    }
                    Card(value: today.totalSteps - today.claimedSteps, name: "Claimable steps", image: Image(systemName: "hand.point.up.left.fill"), color: .yellow)
                }
            }
            .padding()
            .onAppear {
                appData.updateTodaySteps(context: context, manager: manager, today: today)
                Task {
                    await manager.checkStepAuthorizationPermission()
                }
            }
            .onChange(of: manager.steps) {
                appData.updateTodaySteps(context: context, manager: manager, today: today)
            }
            .refreshable {
                appData.updateTodaySteps(context: context, manager: manager, today: today)
                await manager.checkStepAuthorizationPermission()
            }
            } else {
                ProgressView("Loading Today's Steps")
        }
    }
}


#Preview {
    Home()
        .environmentObject(HealthKitManager())
        .environment(AppData(currentUserId: UUID()))
        .modelContainer(for: Day.self, inMemory: true)
}
