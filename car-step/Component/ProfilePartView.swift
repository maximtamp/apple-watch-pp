//
//  ProfilePartView.swift
//  car-step
//
//  Created by Maxim Tampere on 31/01/2026.
//

import SwiftUI

struct ProfilePartView: View {
    var part: Part?
    
    var body: some View {
        ZStack {
            if ((part?.name) != nil) {
                Image("\(part?.name.lowercased().replacingOccurrences(of: " ", with: "-") ?? "")-icon")
                    .resizable()
                    .scaledToFit()
                    .padding(8)
            } else {
                Text("")
                    .foregroundStyle(Color.black)
            }
        }
        .frame(width: 80, height: 80)
        .background(part != nil ? part!.getRarityColor(neededRarity: part!.rarity) : Color.clear)
        .cornerRadius(8)
    }
}

#Preview {
    ProfilePartView()
}
