//
//  Leaderboard.swift
//  car-step
//
//  Created by Maxim Tampere on 29/01/2026.
//

import SwiftUI
import Supabase

struct Leaderboard: View {
    @State private var isLoading: Bool = false

    @State private var totalStepsData: [(name: String, value: Int)] = []
    @State private var madePartsData: [(name: String, value: Int)] = []
    @State private var completedQuestsData: [(name: String, value: Int)] = []
    
    @State private var selectedLeaderboard : Int = 0
    var leaderboards = ["Total Steps", "Made Parts", "Completed Quests"]
    
    var displayedData: [(name: String, value: Int)] {
        switch selectedLeaderboard {
        case 0: return totalStepsData
        case 1: return madePartsData
        case 2: return completedQuestsData
        default: return totalStepsData
        }
    }
    
    func getLeaderboards() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            let profiles = await SupabaseService.shared.fetchAllProfiles()
            let allLastSevenDays = await SupabaseService.shared.fetchAllLastSevenDays()
            let allLastSevenParts = await SupabaseService.shared.fetchAllLastSevenParts()
            let allLastSevenQuests = await SupabaseService.shared.fetchAllLastSevenQuests()
            
            totalStepsData = profiles.compactMap { profile -> (name: String, value: Int)? in
                let totalSteps = allLastSevenDays
                    .filter { $0.userId == profile.id }
                    .reduce(0) { $0 + $1.totalSteps }
                
                if totalSteps > 0 {
                    return (name: profile.username, value: totalSteps) as? (name: String, value: Int)
                } else {
                    return nil
                }
            }
            .sorted { $0.value > $1.value }
            
            madePartsData = profiles.compactMap { profile -> (name: String, value: Int)? in
                let madeParts = allLastSevenParts
                    .filter { $0.userId == profile.id && $0.partMade }
                    .count
                
                if madeParts > 0 {
                    return (name: profile.username, value: madeParts) as? (name: String, value: Int)
                } else {
                    return nil
                }
            }
            .sorted { $0.value > $1.value }

            completedQuestsData = profiles.compactMap { profile -> (name: String, value: Int)? in
                let completedQuests = allLastSevenQuests
                    .filter { $0.userId == profile.id && $0.claimed }
                    .count
                
                if completedQuests > 0 {
                    return (name: profile.username, value: completedQuests) as? (name: String, value: Int)
                } else {
                    return nil
                }
            }
            .sorted { $0.value > $1.value }
        }
    }
    
    var body: some View {
        VStack(spacing: 32){
            Picker("Select a leaderboard", selection: $selectedLeaderboard) {
                ForEach(leaderboards.indices, id: \.self) { index in
                    Text(leaderboards[index])
                }
            }
            if !isLoading {
                ScrollView {
                    ForEach(displayedData.indices, id: \.self) { index in
                        let user = displayedData[index]
                        let rank = index + 1
                        
                        let numberBg: Color = {
                            switch rank {
                            case 1: return Color.yellow.opacity(0.9)
                            case 2: return Color.gray.opacity(0.8)
                            case 3: return Color.brown.opacity(0.7)
                            default:
                                return Color.clear
                            }
                        }()
                        
                        HStack(spacing: 20) {
                            Text("\(rank)")
                                .bold()
                                .frame(width: 32, height: 32)
                                .background(numberBg)
                                .cornerRadius(6)
                                .foregroundStyle( rank < 4 ? Color.black : Color("SecondaryAppColor"))
                            Text(user.name)
                            Spacer()
                            Text("\(user.value)")
                                .font(.title3)
                                .bold()
                        }
                        .padding()
                        .background(Color("PrimaryAppColor"))
                        .cornerRadius(12)
                    }
                }
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .onAppear {
            getLeaderboards()
        }
        .refreshable {
            getLeaderboards()
        }
    }
}

#Preview {
    Leaderboard()
}
