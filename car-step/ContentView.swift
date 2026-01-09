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
    @EnvironmentObject var manager: HealthKitManager
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData
    
    @Query private var days: [Day]
    @Query private var parts: [Part]
    @Query private var fuels: [Fuel]
            
    var body: some View {
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
                Tab("History", systemImage: "calendar") {
                    History()
                }
            }
        }
        .onAppear {
            appData.setup(
                context: context,
                manager: manager,
                days: days,
                parts: parts,
                fuels: fuels,
            )
            manager.fetchTodaySteps()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitManager(preview: true))
        .environment(AppData())
        .modelContainer(for: Day.self, inMemory: true)
}
