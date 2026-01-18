//
//  Home.swift
//  watch-car-step Watch App
//
//  Created by Maxim Tampere on 14/01/2026.
//

import SwiftUI
import SwiftData

struct Home: View {
    @EnvironmentObject var manager: HealthKitManager
    @Environment(\.modelContext) private var context
    @Environment(AppData.self) private var appData
    
    
    var body: some View {
        if let today = appData.today, let fuel = appData.fuel {
            
            let stats = [
                (icon: "shoeprints.fill", value: today.totalSteps, color: Color.blue.opacity(0.5)),
                (icon: "hand.point.up.left.fill", value: today.totalSteps - today.claimedSteps, color: Color.yellow.opacity(0.5)),
                (icon: "bolt.fill", value: fuel.value, color: Color.red.opacity(0.5)),
            ]
            VStack(alignment: .leading, spacing: 2) {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(stats, id: \.icon) { stat in
                        HStack(spacing: 8){
                            ZStack {
                                Image(systemName: stat.icon)
                                    .font(.system(size: 20))
                            }
                            .frame(width: 32, height: 32)
                            .background(stat.color)
                            .cornerRadius(90)
                            Text("\(stat.value)")
                                .font(.system(size: 28))
                        }
                    }
                }
                Spacer()
                
                Button("Claim Steps") {
                    fuel.value += today.totalSteps - today.claimedSteps
                    today.claimedSteps += today.totalSteps - today.claimedSteps
                    
                    try? context.save()
                    
                    WatchConnectivitySync.shared.sendToday(today)
                    WatchConnectivitySync.shared.sendFuel(fuel)
                }
                .disabled(today.totalSteps - today.claimedSteps == 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear {
                appData.updateTodaySteps(context: context, manager: manager, today: today)
            }
            .onChange(of: manager.steps) {
                appData.updateTodaySteps(context: context, manager: manager, today: today)
            }
        } else {
            ProgressView("Loading Data")
        }
    }
}

#Preview {
    Home()
}
