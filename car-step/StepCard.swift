//
//  StepCard.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI

struct StepCard: View {
    let steps: Int
    var body: some View {
        VStack{
            HStack{
                VStack {
                    Text("Steps Today")
                }
                
                Spacer()
                
                Image(systemName: "figure.walk")
            }
            Text("\(steps)")
                .font(.title)
                .bold()
        }
        .padding()
        .background(Color.blue.opacity(0.5))
        .cornerRadius(10)
        .padding()
    }
}

#Preview {
    StepCard(steps: 300)
}
