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
    let container: ModelContainer = {
        try! ModelContainer(for: Day.self, Part.self, Fuel.self, Car.self)
    }()

    @State private var appData = AppData()
    @StateObject private var manager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appData)
                .environmentObject(manager)
                .environment(\.modelContext, container.mainContext)
                .onAppear {
                    WatchConnectivitySync.shared.setup(
                        context: container.mainContext,
                        appData: appData
                    )
                }
        }
    }
}
