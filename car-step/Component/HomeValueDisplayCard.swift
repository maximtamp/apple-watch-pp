//
//  HomeValueDisplayCard.swift
//  car-step
//
//  Created by Maxim Tampere on 28/01/2026.
//

import SwiftUI

struct HomeValueDisplayCard: View {
    var label: String
    var icon: String
    var color: Color
    var value: Int
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.5))
                .cornerRadius(90)
            Text(label)
            Spacer()
            Text("\(value)")
                .font(.title2)
                .bold()
                .padding(.trailing, 8)
        }
        .padding(8)
        .background(color.opacity(0.5))
        .cornerRadius(12)
    }
}

#Preview {
    HomeValueDisplayCard(label: "Total Steps", icon: "house", color: Color.yellow, value: 1000)
}
