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
    @StateObject var manager = HealthKitManager()
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                Onboarding()
                    .environmentObject(manager)
            } else {
                ContentView()
                    .modelContainer(for: [Day.self, Part.self, Fuel.self])
                    .environmentObject(manager)
                    .onAppear {
                        if manager.isAvailable() {
                            print("HealthKit is available!")
                            // Add code to use HealthKit here.
                        } else {
                            print("HealthKit not available")
                        }
                    }
            }
        }
    }
}
