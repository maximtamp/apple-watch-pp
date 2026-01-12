//
//  CanvasTests.swift
//  car-step
//
//  Created by Maxim Tampere on 09/01/2026.
//

import SwiftUI

struct CanvasTests: View {
    let progress: Double
    var lineWidth = 6.0
    
    var body: some View {
        ZStack {
            Group {
                Circle()
                    .foregroundColor(.white)
                    .shadow(radius: 0.5)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: .init(lineWidth: lineWidth))

                Circle() // 👈🏻
                    .trim(from: progress, to: progress + 0.0002) // 👈🏻
                    .stroke(Color.blue,
                            style: StrokeStyle(lineWidth: lineWidth * 2, lineCap: .round),
                            antialiased: true)
            }
            .rotationEffect(.degrees(-90)) // 👈🏻
        }
        .frame(width: 250, height: 250)
        .padding()
    }
}

#Preview {
    CanvasTests(progress: 0.6)
}
