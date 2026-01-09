//
//  Card.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI

struct Card: View {
    let value: Int
    let name: String
    let image: Image
    let color: Color
    
    var body: some View {
        VStack{
            HStack{
                VStack {
                    Text(name)
                }
                
                Spacer()
                
                ZStack {
                    image
                }
                .frame(width: 32, height: 32)
                .background(color.opacity(0.5))
                .cornerRadius(90)
            }
            Text("\(value)")
                .font(.title)
                .bold()
        }
        .padding()
        .background(color.opacity(0.5))
        .cornerRadius(10)
    }
}

#Preview {
    Card(value: 300, name: "Max", image: Image(systemName: "car"), color: .blue)
}
