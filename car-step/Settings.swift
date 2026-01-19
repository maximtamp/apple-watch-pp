//
//  Settings.swift
//  car-step
//
//  Created by Maxim Tampere on 18/01/2026.
//

import SwiftUI
import _SwiftData_SwiftUI

struct Settings: View {
    
    @Environment(AppData.self) private var appData

    @Query private var days: [Day]
    @Query private var parts: [Part]
    
    var body: some View {
        Button("setup watch") {
            if let car = appData.car, let fuel = appData.fuel {
                WatchConnectivitySync.shared.sendSetup(days: days, parts: parts, fuel: fuel, car: car)
            }
        }
    }
}

#Preview {
    Settings()
}
