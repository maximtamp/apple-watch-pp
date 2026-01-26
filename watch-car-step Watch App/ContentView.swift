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
                TabView {
                    Home()
                    UseFuelPage()
                    Garage()
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
            } else {
                VStack(spacing: 8){
                    Text("Not Setup")
                        .font(.title3 .bold())
                    Text("On your phone, go to Profile -> 3 dots -> Setup Watch")
                        .multilineTextAlignment(.center)
                }
            }
        }
        .onAppear {
            
        }
    }
}

#Preview {
    ContentView()
}
