//
//  ContentView.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject var manager: HealthKitManager
    @State var timesClicked: Int = 0
        
    var body: some View {
        VStack {
            StepCard(steps: manager.steps)
            Button("Refresh Steps") {
                manager.fetchTodaySteps()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ContentView()
        .environmentObject(HealthKitManager(preview: true))
}
