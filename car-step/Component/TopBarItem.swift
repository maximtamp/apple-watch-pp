//
//  TopBarItem.swift
//  car-step
//
//  Created by Maxim Tampere on 31/01/2026.
//

import SwiftUI

struct TopBarItem: View {
    var icon: String
    var color: Color
    var value: Int
    
    var body: some View {
        HStack{
            ZStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
            }
            .frame(width: 32, height: 32)
            .background(color.opacity(0.5))
            .cornerRadius(90)
            Text("\(value)")
        }
    }
}

#Preview {
    TopBarItem(icon: "house", color: Color.red, value: 200)
}
