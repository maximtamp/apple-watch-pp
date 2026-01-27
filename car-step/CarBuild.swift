//
//  CarBuild.swift
//  car-step
//
//  Created by Maxim Tampere on 27/01/2026.
//

import SwiftUI

struct CarBuild: View {
    let wheelName: String
    let bodyName: String
    
    var body: some View {
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
}
