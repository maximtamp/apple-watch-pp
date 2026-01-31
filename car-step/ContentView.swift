//
//  ContentView.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI
import SwiftData
import HealthKit

struct ContentView: View {
    @AppStorage("isAllowedReadingSteps") var isAllowedReadingSteps: Bool = false
    
    @EnvironmentObject var manager: HealthKitManager
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData
    
    @Query private var days: [Day]
    @Query private var parts: [Part]
    @Query private var fuels: [Fuel]
    @Query private var cars: [Car]
    @Query private var quests: [Quest]
    
    @State var isLoading = true
            
    var body: some View {
        if isAllowedReadingSteps {
            VStack {
                if !isLoading {
                    VStack{
                        HStack {
                            TopBarItem(icon: "shoeprints.fill", color: Color.blue, value: appData.today?.totalSteps ?? 0)
                            Spacer()
                            TopBarItem(icon: "hand.point.up.left.fill", color: Color.yellow, value: (appData.today?.totalSteps ?? 0) - (appData.today?.claimedSteps ?? 0))
                            Spacer()
                            TopBarItem(icon: "bolt.fill", color: Color.red, value: appData.fuel?.value ?? 0)
                        }
                        .padding(.horizontal)
                        TabView {
                            Tab("Home", systemImage: "house") {
                                Home()
                            }
                            Tab("Challenge", systemImage: "scroll.fill") {
                                Challenge()
                            }
                            Tab("Garage", systemImage: "door.garage.closed") {
                                Garage()
                            }
                            Tab("Friends", systemImage: "person.3.fill") {
                                Friends()
                            }
                            Tab("Profiel", systemImage: "person.crop.circle.fill") {
                                ProfileView()
                            }
                        }
                    }
                    .background(Color("SecondaryAppColor").opacity(0.025))
                } else {
                    ProgressView()
                }
            }
            .onAppear {
                Task {
                    isLoading = true
                    
                    if appData.didJustLogin {
                        let remote = await appData.loadFromSupabase(context: context, existingDays: days, existingParts: parts, existingFuels: fuels, existingCars: cars, existingQuests: quests)
                        print(remote)
                        
                        appData.didJustLogin = false
                    }
                                        
                    appData.setup(
                        context: context,
                        manager: manager,
                        days: days,
                        parts: parts,
                        fuels: fuels,
                        cars: cars,
                    )
                    appData.setupQuests(context: context, quests: quests)
                    manager.fetchTodaySteps()
                    
                    isLoading = false
                }
            }
        } else {
            Authorization()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitManager())
        .environment(AppData(currentUserId: UUID()))
        .modelContainer(for: Day.self, inMemory: true)
}
