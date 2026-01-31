//
//  Quests.swift
//  car-step
//
//  Created by Maxim Tampere on 18/01/2026.
//

import SwiftUI
import SwiftData

struct Quests: View {
    @EnvironmentObject var manager: HealthKitManager
    @Environment(AppData.self) private var appData
    @Environment(\.modelContext) private var context
    
    @Query var parts: [Part]
    @Query var quests: [Quest]

    var body: some View {
        if let todayQuests = appData.todayQuests, let today = appData.today, let fuel = appData.fuel {
            VStack(spacing: 12) {
                ForEach(todayQuests.sorted{questA, questB in
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
                                        appData.checkTodayQuests(context: context, quests: quests)
                                    } label: {
                                        Text("Claim Fuel")
                                            .foregroundStyle(Color.black)
                                            .frame(maxWidth: .infinity, minHeight: 32)
                                            .background(Color.green)
                                            .cornerRadius(8)
                                    }
                                } else {
                                    ProgressView(value: min(1.0, Double(quest.currentValue) / Double(quest.neededValue)))
                                        .accentColor(quest.currentValue >= quest.neededValue ? Color.green : Color.blue)
                                    Text("\(quest.currentValue)/\(quest.neededValue)")
                                        .font(.caption)
                                }
                            }
                        }
                        
                        Spacer()
                        Rectangle()
                            .fill(Color("SecondaryAppColor").opacity(0.2))
                            .frame(width: 2, height: 72)
                            .padding(.horizontal, 12)
                        Spacer()
                        
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
                    .padding(.vertical)
                    .padding(.horizontal, 20)
                    .background(Color("PrimaryAppColor"))
                    .cornerRadius(12)
                }
                Spacer()
            }
            .onAppear{
                appData.checkTodayQuests(context: context, quests: quests)
                appData.checkTodayQuestProgress(todayQuests: todayQuests, today: today, parts: parts)
                Task {
                    await manager.checkStepAuthorizationPermission()
                }
            }
            .refreshable {
                appData.checkTodayQuests(context: context, quests: quests)
                appData.checkTodayQuestProgress(todayQuests: todayQuests, today: today, parts: parts)
                await manager.checkStepAuthorizationPermission()
            }
        } else {
            ProgressView()
        }
    }
}
