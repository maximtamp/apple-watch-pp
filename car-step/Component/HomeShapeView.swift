//
//  HomeShapeView.swift
//  car-step
//
//  Created by Maxim Tampere on 09/01/2026.
//

import SwiftUI

struct HomeShapeView: View {
    let part: Part
    var body: some View {
        VStack {
            Spacer()
            part.getPartShape(color: Color.black, neededPart: part.name, progress: part.progressPrecent, size: 225, lineWidth: 5)
            Spacer()
        }
        .frame(width: 225, height: 225)
        .aspectRatio(1, contentMode: .fit)
        .padding(24)
        .background(part.getRarityColor(neededRarity: part.rarity))
        .cornerRadius(32)
    }
}

#Preview {
    let dummyPart = Part(name: "Sparky", type: .wheel, rarity: .rare, partMade: false, progressValue: 10000, maxValue: 10000, speedPoints: 10, creationDate: .now)
    HomeShapeView(part: dummyPart)
}
