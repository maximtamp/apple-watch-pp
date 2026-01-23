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
            part.getPartShape(neededPart: part.type, progress: part.progressPrecent, size: 300)
            Spacer()
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(width: 300, height: 300)
    }
}

#Preview {
    let dummyPart = Part(name: "Sparky", type: .wheel, rarity: .rare, partMade: false, progressValue: 0, maxValue: 10000, creationDate: .now)
    HomeShapeView(part: dummyPart)
}
