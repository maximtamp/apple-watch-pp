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
                VStack {
                    HomeShapeView(part: part)
                        .padding(.vertical)
                    VStack {
                        HStack {
                            BigIconTextButton(label: "Claim Steps", icon: "shoeprints.fill", disabled: today.totalSteps - today.claimedSteps == 0){
                                let stepsToClaim = today.totalSteps - today.claimedSteps
                                
                                fuel.value += stepsToClaim
                                today.claimedSteps += stepsToClaim
                                
                                try? context.save()
                                
                                Task{
                                    await SupabaseService.shared.updateDay(today)
                                    await SupabaseService.shared.updateFuel(fuel)
                                }
                                WatchConnectivitySync.shared.sendToday(today)
                                WatchConnectivitySync.shared.sendFuel(fuel)
                            }
                            
                            BigIconTextButton(label: "Use Fuel", icon: "bolt.fill", disabled: fuel.value == 0) {
                                showUseFuelPopover = true
                            }
                            .popover(isPresented: $showUseFuelPopover) {
                                UseFuel(
                                    fuel: fuel,
                                    part: part,
                                    today: today,
                                    onClose: closeUseFuelPopover
                                )
                            }
                            
                            BigIconTextButton(label: "Race", icon: "flag.pattern.checkered"){
                                showRacePopover = true
                            }
                            .popover(isPresented: $showRacePopover) {
                                RaceView(
                                    onClose: closeRacelPopover
                                )
                            }
                        }
                        .padding(.vertical, 20)
                        
                        VStack{
                            HomeValueDisplayCard(label: "Total Steps", icon: "shoeprints.fill", color: .blue, value: today.totalSteps)
                            HomeValueDisplayCard(label: "Claimable steps", icon: "hand.point.up.left.fill", color: .yellow, value: today.totalSteps - today.claimedSteps)
                            HomeValueDisplayCard(label: "Fuel", icon: "bolt.fill", color: .red, value: fuel.value)
                        }
                    }
                }
                
            }
            .padding()
            .background(Color("BackgroundAppColor"))
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
