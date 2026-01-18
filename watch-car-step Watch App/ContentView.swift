//
//  ContentView.swift
//  watch-car-step Watch App
//
//  Created by Maxim Tampere on 14/01/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @AppStorage("isSetup") var isSetup: Bool = false
    
    @EnvironmentObject var manager: HealthKitManager
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData
    
    @Query private var days: [Day]
    @Query private var parts: [Part]
    @Query private var fuels: [Fuel]
    @Query private var cars: [Car]
    
    var body: some View {
        VStack{
            if isSetup {
                NavigationStack{
                    TabView {
                        Home()
                        UseFuelPage()
                        Garage()
                    }
                }
            } else {
                VStack(spacing: 12){
                    Text("Not Setup")
                        .font(.title3 .bold())
                    Text("On your phone, go to Settings -> Setup Watch")
                        .multilineTextAlignment(.center)
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
                cars: cars,
            )
            manager.fetchTodaySteps()
        }
    }
}

#Preview {
    ContentView()
}
