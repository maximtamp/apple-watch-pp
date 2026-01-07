//
//  car_stepApp.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI
import HealthKit

@main
struct car_stepApp: App {
    @StateObject var manager = HealthKitManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
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
