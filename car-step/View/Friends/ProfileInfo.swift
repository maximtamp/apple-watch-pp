//
//  ProfileInfo.swift
//  car-step
//
//  Created by Maxim Tampere on 24/01/2026.
//

import SwiftUI
import Supabase

struct ProfileInfo: View {
    var userId: UUID
    var username: String?
    var avatarURL: String?
    
    var onRemoveFriend: (() async -> Void)? = nil
    
    @State private var fuel: Int = 0
    @State private var totalParts: Int = 0
    @State private var questCompleted: Int = 0
    
    @State private var car: Car?
    @State private var bodyPart: Part?
    @State private var enginePart: Part?
    @State private var wheelPart: Part?
    
    @State private var lastSevenDays: [Day] = []
    @State private var lastSevenDaysTotalSteps: Int = 0
    @State private var lastSevenDaysTotalFuelUsed: Int = 0
    
    @State var isLoading = false
    @State private var avatarImage: AvatarImage?
    
    func prepData() async {
        isLoading = true
        defer { isLoading = false }
        
        fuel = await SupabaseService.shared.fetchFuels(userId: userId).first!.value
        questCompleted = await SupabaseService.shared.fetchQuests(userId: userId).filter { $0.claimed }.count
        
        let parts = await SupabaseService.shared.fetchParts(userId: userId)
        totalParts = parts.filter { $0.partMade }.count
        
        if let fetchedCar = await SupabaseService.shared.fetchCars(userId: userId).first {
            car = fetchedCar
            bodyPart = parts.first { $0.id == car?.bodyId }
            enginePart = parts.first { $0.id == car?.engineId }
            wheelPart = parts.first { $0.id == car?.wheelId }
        } else {
            car = nil
            bodyPart = nil
            enginePart = nil
            wheelPart = nil
        }
        
        lastSevenDays = await SupabaseService.shared.fetchLastSevenDays(userId: userId)
    }
    
    var body: some View {
        ScrollView{
            if !isLoading {
                VStack {
                    HStack {
                        HStack {
                            AvatarView(avatarURL: avatarURL, size: 64)
                            
                            Text(username ?? "Unknown")
                            Spacer()
                        }
                                        
                        HStack{
                            ZStack {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 20))
                            }
                            .frame(width: 32, height: 32)
                            .background(Color.red.opacity(0.5))
                            .cornerRadius(90)
                            Text("\(fuel)")
                        }
                    }
                    .frame(height: 64)
                    .padding()
                    .background(Color("PrimaryAppColor"))
                    .cornerRadius(12)
                    
                    HStack {
                        Spacer()
                        VStack {
                            Text("\(totalParts)")
                                .font(.largeTitle)
                            Text("Total Parts")
                        }
                        Spacer()
                        VStack {
                            Text("\(questCompleted)")
                                .font(.largeTitle)
                            Text("Quest Completed")
                        }
                        Spacer()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color("PrimaryAppColor"))
                    .cornerRadius(12)
                    
                    if (car != nil) {
                        HStack{
                            CarBuild(wheelName: wheelPart?.name ?? "", bodyName: bodyPart?.name ?? "")
                            .frame(maxWidth: .infinity)
                            .padding(.trailing, 20)
                            
                            VStack {
                                partView(bodyPart)
                                partView(enginePart)
                                partView(wheelPart)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color("PrimaryAppColor"))
                        .cornerRadius(12)
                    }
                    
                    SevenDaysGraphic(days: lastSevenDays)
                    
                    Spacer()
                }
                .padding(.top, 12)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundAppColor"))
        .onAppear {
            Task{
                await prepData()
            }
        }
        .refreshable {
            Task{
                await prepData()
            }
        }
    }
    
    func partView(_ part: Part?) -> some View {
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
        .background(part != nil
                    ? part!.getRarityColor(neededRarity: part!.rarity)
                    : Color.clear)
        .cornerRadius(12)
    }
}
