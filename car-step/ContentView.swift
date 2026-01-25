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
            
    var body: some View {
        if isAllowedReadingSteps {
            VStack{
                HStack {
                    HStack{
                        ZStack {
                            Image(systemName: "shoeprints.fill")
                                .font(.system(size: 20))
                        }
                        .frame(width: 32, height: 32)
                        .background(Color.blue.opacity(0.5))
                        .cornerRadius(90)
                        Text("\(appData.today?.totalSteps ?? 0)")
                    }

                    Spacer()
                    
                    HStack{
                        ZStack {
                            Image(systemName: "hand.point.up.left.fill")
                                .font(.system(size: 20))
                        }
                        .frame(width: 32, height: 32)
                        .background(Color.yellow.opacity(0.5))
                        .cornerRadius(90)
                        Text("\((appData.today?.totalSteps ?? 0) - (appData.today?.claimedSteps ?? 0))")
                    }
                    
                    Spacer()
                    
                    HStack{
                        ZStack {
                            Image(systemName: "bolt.fill")
                                .font(.system(size: 20))
                        }
                        .frame(width: 32, height: 32)
                        .background(Color.red.opacity(0.5))
                        .cornerRadius(90)
                        Text("\(appData.fuel?.value ?? 0)")
                    }
                }
                .padding(.horizontal)
                TabView {
                    Tab("Home", systemImage: "house") {
                        Home()
                    }
                    Tab("Quests", systemImage: "scroll.fill") {
                        Quests()
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
            .onAppear {
                Task {
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
