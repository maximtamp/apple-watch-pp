//
//  iconTest.swift
//  car-step
//
//  Created by Maxim Tampere on 27/01/2026.
//

import SwiftUI

struct iconTest: View {
    
    let wheelName = "Vortex Rollers"
    let bodyName = "Phoenix Carapace"
    
    var body: some View {
        VStack {
            ZStack {
                Image("\(bodyName.lowercased().replacingOccurrences(of: " ", with: "-"))-build")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                Image("\(wheelName.lowercased().replacingOccurrences(of: " ", with: "-"))-build")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            }
        }
        .frame(width: 400, height: 300)
    }
}

#Preview {
    iconTest()
}
