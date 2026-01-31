//
//  ProfileStatsItem.swift
//  car-step
//
//  Created by Maxim Tampere on 31/01/2026.
//

import SwiftUI

struct ProfileStatsItem: View {
    var label: String
    var value: Int
    
    var body: some View {
        VStack {
            Text("\(value)")
                .font(.largeTitle)
            Text(label)
                .font(.footnote)
        }
    }
}

#Preview {
    ProfileStatsItem(label: "apple", value: 4)
}
