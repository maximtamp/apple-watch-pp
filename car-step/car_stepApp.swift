//
//  car_stepApp.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI
import SwiftData
import HealthKit

@main
struct car_stepApp: App {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    
    @State private var appData = AppData()
    @StateObject private var manager = HealthKitManager()
    
    
    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                Onboarding()
                    .environmentObject(manager)
            } else {
                ContentView()
                    .modelContainer(for: [Day.self, Part.self, Fuel.self, Car.self])
                    .environmentObject(manager)
                    .environment(appData)
            }
        }
    }
}
