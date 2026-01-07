//
//  Home.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI

struct Home: View {
    @EnvironmentObject var manager: HealthKitManager
    
    @State var claimedSteps: Int = 0
    @State var fuel: Int = 0
    @State var usedFuel: Int = 0
    @State var shapeProgress: Int = 0
            
    var body: some View {

        VStack {
            ProgressBar(value: shapeProgress)
                .padding(.bottom, 40)
            
            Card(value: manager.steps, name: "Total Steps", image: Image(systemName: "figure.walk"), color: .blue)
            Card(value: manager.steps - claimedSteps, name: "Steps Left To Claim", image: Image(systemName: "hand.point.up.left.fill"), color: .yellow)
            Card(value: claimedSteps, name: "Claimed steps", image: Image(systemName: "basket"), color: .green)
            Card(value: fuel, name: "Fuel", image: Image(systemName: "bolt.fill"), color: .red)
            
            HStack {
                Button("Claim Step") {
                    claimedSteps += manager.steps - claimedSteps
                    fuel += claimedSteps - usedFuel
                }
                .buttonStyle(.bordered)
                .disabled(manager.steps - claimedSteps == 0)
                Button("Use Fuel") {
                    shapeProgress += fuel
                    usedFuel += fuel
                    fuel = 0
                }
                .buttonStyle(.bordered)
                .disabled(fuel == 0)
            }
            .padding(.vertical, 20)
            Button("Refresh Steps") {
                manager.fetchTodaySteps()
            }
        }
        .padding()
    }
}

#Preview {
    Home()
}
