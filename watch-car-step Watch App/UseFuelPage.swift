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
        if let part = appData.part, let fuel = appData.fuel {
            NavigationStack{
                VStack(spacing: 12) {
                    VStack {
                        Spacer()
                        part.getPartShape(neededPart: part.type, progress: partProgress, size: 100)
                        Spacer()
                    }
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 100, height: 100)
                    
                    NavigationLink("Use Fuel") {
                        UseFuel(fuel: fuel, part: part)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .onAppear {
                partProgress = Double(part.progressValue) / Double(part.maxValue)
            }
        } else {
            ProgressView("Loading Data")
        }
    }
}

#Preview {
    UseFuelPage()
}
