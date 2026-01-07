//
//  ProgressBar.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI

struct ProgressBar: View {
    let value: Int
    let maxValue: Int = 10000
    
    var progress: Double {
        Double(value) / Double(maxValue)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Shape Progress")
                Spacer()
                Text("\(value) / \(maxValue)")
            }
            ProgressView(value: progress)
                .progressViewStyle(.linear)
        }
    }
}

#Preview {
    ProgressBar(value: 300)
}
