//
//  ProgressBar.swift
//  car-step
//
//  Created by Maxim Tampere on 07/01/2026.
//

import SwiftUI

struct ProgressBar: View {
    let progress: Double
    let valueText: String
    
    var body: some View {
        VStack {
            HStack {
                Text("Shape Progress")
                Spacer()
                Text(valueText)
            }
            ProgressView(value: progress)
                .progressViewStyle(.linear)
        }
    }
}

#Preview {
    ProgressBar(progress: 60.0, valueText: "6000 / 10000")
}
