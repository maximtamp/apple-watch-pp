//
//  UseFuelPage.swift
//  watch-car-step Watch App
//
//  Created by Maxim Tampere on 16/01/2026.
//

import SwiftUI

struct UseFuelPage: View {
    @Environment(AppData.self) private var appData
    
    @State private var partProgress: Double = 0
    
    var body: some View {
        if let part = appData.part, let fuel = appData.fuel, let today = appData.today {
            NavigationStack{
                VStack(spacing: 12) {
                    VStack {
                        Spacer()
                        part.getPartShape(color: Color.white, neededPart: part.name, progress: part.progressPrecent, size: 100, lineWidth: 3)
                        Spacer()
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 100, height: 100)
                    
                    NavigationLink("Use Fuel") {
                        UseFuel(fuel: fuel, part: part, today: today)
                    }
                    .disabled(fuel.value <= 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            ProgressView("Loading Data")
        }
    }
}

#Preview {
    UseFuelPage()
}
