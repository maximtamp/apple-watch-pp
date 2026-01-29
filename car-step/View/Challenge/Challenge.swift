//
//  Challenge.swift
//  car-step
//
//  Created by Maxim Tampere on 29/01/2026.
//

import SwiftUI

struct Challenge: View {
    @State private var selectedTab: Int = 0
    var tabs = ["Challanges", "Leaderboards"]
    
    var body: some View {
        VStack{
            
            Picker("Select a rab", selection: $selectedTab) {
                ForEach(tabs.indices, id: \.self) { index in
                    Text(tabs[index])
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            if selectedTab == 0 {
                VStack{
                    Text("Daily Challenges")
                        .font(.title)
                        .bold()
                    Quests()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(spacing: 20){
                    Text("Weekly Leaderboard")
                        .font(.title)
                        .bold()
                    Leaderboard()
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundAppColor"))
    }
}

#Preview {
    Challenge()
}
