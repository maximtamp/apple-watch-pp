//
//  FriendDetail.swift
//  car-step
//
//  Created by Maxim Tampere on 24/01/2026.
//

import SwiftUI
import Supabase

struct FriendDetail: View {
    @Environment(AppData.self) private var appData

    var userId: UUID
    var username: String?
    var avatarURL: String?
    var friendsData: [Friend]
    
    var onRemoveFriend: (() async -> Void)? = nil
    
    @State private var friendState: String = "remove"
    @State private var localfriendsData: [Friend] = []
    
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
    
    @State private var racesWon: Int = 0
    
    @State var isLoadingPage = false
    @State var isLoading = false
    @State var showAlert = false
    @State private var avatarImage: AvatarImage?
    
    func prepData() async {
        isLoadingPage = true
        defer { isLoadingPage = false }
        
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
        racesWon = await SupabaseService.shared.fetchWonRacesCount(userId: userId)
        
        localfriendsData = friendsData
    }
    
    func checkFriendState() {
        if localfriendsData.contains( where: { $0.userId == userId || $0.friendId == userId }){
            if let friend = localfriendsData.first( where: { $0.userId == userId }) {
                if friend.isAccepted {
                    friendState = "remove"
                } else {
                    friendState = "request"
                }
            }
            if let friend = localfriendsData.first( where: { $0.friendId == userId }) {
                if friend.isAccepted {
                    friendState = "remove"
                } else {
                    friendState = "pending"
                }
            }
        } else {
            friendState = "add"
        }
    }
    
    var body: some View {
        ScrollView{
            if !isLoadingPage {
                VStack {
                    VStack(spacing: 24) {
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
                        
                        VStack {
                            FriendButton(state: friendState, isLoading: isLoading,
                                         insert: {
                                Task{
                                    isLoading = true
                                    defer { isLoading = false }
                                    
                                    let newFriend = Friend(
                                        id: UUID(),
                                        userId: appData.currentUserId,
                                        friendId: userId,
                                        isAccepted: false
                                    )
                                    await SupabaseService.shared.insertFriend(newFriend)
                                    friendState = "pending"
                                }
                            },
                                         delete: {
                                showAlert = true
                            },
                                         accept: {
                                Task {
                                    isLoading = true
                                    defer { isLoading = false }
                                    
                                    if let relation = friendsData.first(where: { $0.userId == userId && $0.friendId == appData.currentUserId }) {
                                        
                                        relation.isAccepted = true
                                        await SupabaseService.shared.updateFriend(relation)
                                        friendState = "remove"
                                    }
                                }
                            },
                                         deny: {
                                Task {
                                    isLoading = true
                                    defer { isLoading = false }
                                    
                                    if let relation = friendsData.first(where: { $0.userId == userId && $0.friendId == appData.currentUserId }) {
                                        
                                        await SupabaseService.shared.deleteFriend(relation)
                                        friendState = "add"
                                    }
                                }
                            })
                        }
                        .frame(height: 24)
                        .padding(.vertical)
                        .alert("Watch out!", isPresented: $showAlert) {
                            Button("Yes, Remove", role: .destructive){
                                Task {
                                    isLoading = true
                                    defer { isLoading = false }
                                    
                                    if let relation = friendsData.first(where: { ($0.userId == userId && $0.friendId == appData.currentUserId) || ($0.userId == appData.currentUserId && $0.friendId == userId) }) {
                                        
                                        await SupabaseService.shared.deleteFriend(relation)
                                        friendState = "add"
                                    }
                                }
                            }
                            Button("Cancel", role: .cancel){}
                        } message: {
                            Text("Are you sure you want to remove \(username ?? "this friend")")
                        }
                    }
                    .padding()
                    .background(Color("PrimaryAppColor"))
                    .cornerRadius(12)
                    
                    
                    HStack {
                        Spacer()
                        VStack {
                            Text("\(totalParts)")
                                .font(.largeTitle)
                            Text("Total Parts")
                                .font(.footnote)
                        }
                        Spacer()
                        VStack {
                            Text("\(questCompleted)")
                                .font(.largeTitle)
                            Text("Quest Completed")
                                .font(.footnote)
                        }
                        Spacer()
                        VStack {
                            Text("\(racesWon)")
                                .font(.largeTitle)
                            Text("Races Won")
                                .font(.footnote)
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
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(Color("BackgroundAppColor"))
                                .cornerRadius(12)
                            
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
                .padding(.top, 8)
                .padding(.horizontal)
                .padding(.bottom)
            } else {
                ProgressView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("BackgroundAppColor"))
        .onAppear {
            Task{
                await prepData()
                checkFriendState()
            }
        }
        .refreshable {
            Task{
                await prepData()
                localfriendsData = await SupabaseService.shared.fetchOFriends(userId: appData.currentUserId)
                checkFriendState()
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
        .cornerRadius(8)
    }
}
