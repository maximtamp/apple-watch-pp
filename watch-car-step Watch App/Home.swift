//
//  Home.swift
//  watch-car-step Watch App
//
//  Created by Maxim Tampere on 14/01/2026.
//

import SwiftUI

struct Home: View {
    
    let stats: [(icon: String, value: Int, color: Color)] = [
        (icon: "shoeprints.fill", value: 10000, color: Color.blue.opacity(0.5)),
        (icon: "hand.point.up.left.fill", value: 6000, color: Color.yellow.opacity(0.5)),
        (icon: "bolt.fill", value: 4000, color: Color.red.opacity(0.5)),
    ]
    
    var body: some View {
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
                // Function
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    Home()
}
