//
//  watch_car_stepApp.swift
//  watch-car-step Watch App
//
//  Created by Maxim Tampere on 14/01/2026.
//

import SwiftUI
import SwiftData

@main
struct watch_car_step_Watch_AppApp: App {
    @State private var appData = AppData()
    @StateObject private var manager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Day.self, Part.self, Fuel.self, Car.self])
                .environmentObject(manager)
                .environment(appData)
        }
    }
}
