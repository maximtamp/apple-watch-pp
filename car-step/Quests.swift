//
//  Quests.swift
//  car-step
//
//  Created by Maxim Tampere on 18/01/2026.
//

import SwiftUI
import SwiftData

struct Quests: View {
    @Environment(AppData.self) private var appData
    
    @Query var parts: [Part]

    var body: some View {
        if let quests = appData.todayQuests, let today = appData.today, let fuel = appData.fuel {
            List(quests.sorted{questA, questB in
                let fuelRewardA = questA.fuelReward
                let fuelRewardB = questB.fuelReward
                return fuelRewardA < fuelRewardB
            }, id: \.id) { quest in
                HStack{
                    VStack(alignment: .leading) {
                        Text(quest.title)
                            .bold()
                        VStack{
                            if (quest.currentValue >= quest.neededValue) && !quest.claimed {
                                Button{
                                    appData.claimQuestReward(quest: quest, fuel: fuel)
                                } label: {
                                    Text("Claim Fuel")
                                        .foregroundStyle(Color.black)
                                        .frame(maxWidth: .infinity, minHeight: 32)
                                        .background(Color.green)
                                        .cornerRadius(90)
                                }
                            } else {
                                ProgressView(value: Double(quest.currentValue) / Double(quest.neededValue))
                                    .accentColor(quest.currentValue >= quest.neededValue ? Color.green : Color.blue)
                                Text("\(quest.currentValue)/\(quest.neededValue)")
                                    .font(.caption)
                            }
                        }
                    }
                    
                    
                    Divider()
                        .frame(width: 3)
                        .padding(.horizontal, 8)
                    
                    VStack{
                        if quest.claimed {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.green)
                            
                        } else {
                            ZStack {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 20))
                            }
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.5))
                            .cornerRadius(90)
                            Text("\(quest.fuelReward)")
                                .font(.system(size: 20))
                        }
                    }
                }
            }
            .onAppear{
                appData.checkTodayQuestProgress(today: today, parts: parts)
            }
            .refreshable {
                appData.checkTodayQuestProgress(today: today, parts: parts)
            }
        } else {
            ProgressView("Loading Quests")
        }
    }
}
/*
#Preview {
    Quests()
}*/
