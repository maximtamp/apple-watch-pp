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
            
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                Home()
            }
            Tab("History", systemImage: "calendar") {
                History()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitManager(preview: true))
        .modelContainer(for: Day.self, inMemory: true)
}
