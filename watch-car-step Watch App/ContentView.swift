//
//  ContentView.swift
//  watch-car-step Watch App
//
//  Created by Maxim Tampere on 14/01/2026.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject var manager: HealthKitManager
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData
    
    @Query private var days: [Day]
    @Query private var parts: [Part]
    @Query private var fuels: [Fuel]
    @Query private var cars: [Car]
    
    var body: some View {
        NavigationStack{
            TabView {
                Home()
                UseFuelPage()
                Garage()
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
