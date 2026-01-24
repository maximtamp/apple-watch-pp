//
//  Friends.swift
//  car-step
//
//  Created by Maxim Tampere on 24/01/2026.
//

import SwiftUI

struct Friends: View {
    @Environment(AppData.self) private var appData
    
    @State var isLoading = false

    @State private var profiles: [Profile] = []
    @State private var friendsData: [Friend] = []
    
    @State private var friends: [Profile] = []
    @State private var friendRequests: [Profile] = []
    @State private var friendSearch: String = ""
    
    func prepFriends(userId: UUID) async {
        profiles = await SupabaseService.shared.fetchOthersProfiles(userId: appData.currentUserId)
        friendsData = await SupabaseService.shared.fetchOFriends(userId: appData.currentUserId)
        
        friends = friendsData
            .filter { $0.isAccepted }
            .compactMap { relation in
                let otherId = relation.userId == userId ? relation.friendId : relation.userId
                return profiles.first { $0.id == otherId }
            }
        
        friendRequests = friendsData
            .filter { !$0.isAccepted }
            .compactMap { relation in
                profiles.first { $0.id == relation.userId }
            }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack{
                    if !friendRequests.isEmpty {
                        VStack{
                            Text("Friend requests")
                            ForEach(friendRequests, id: \.id) { profile in
                                HStack{
                                    Text(profile.username ?? "")
                                    Spacer()
                                    Button {
                                        Task{
                                            if let relation = friendsData.first(where: { $0.userId == profile.id && $0.friendId == appData.currentUserId }) {
                                                
                                                relation.isAccepted = true
                                                await SupabaseService.shared.updateFriend(relation)
                                                
                                                await prepFriends(userId: appData.currentUserId)
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.green)
                                            .font(.title)
                                    }
                                    Button {
                                        Task{
                                            if let relation = friendsData.first(where: { $0.userId == profile.id && $0.friendId == appData.currentUserId }) {
                                                
                                                await SupabaseService.shared.deleteFriend(relation)
                                                await prepFriends(userId: appData.currentUserId)
                                            }
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(Color.red)
                                            .font(.title)
                                    }
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .padding()
                            }
                        }
                        Divider()
                    }
                    
                    VStack {
                        TextField("Search friends", text: $friendSearch)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .background(Color.white)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                        
                        if friendSearch.count > 0 {
                            VStack{
                                ForEach(
                                    profiles
                                        .filter { $0.username?.localizedCaseInsensitiveContains(friendSearch) == true }
                                        , id: \.id)
                                { profile in
                                    HStack {
                                        Text(profile.username ?? "")
                                        Spacer()
                                        if !friends.contains( where: { $0.id == profile.id } ) {
                                            if !friendsData.contains( where: { $0.friendId == profile.id || $0.userId == profile.id } ) {
                                                Button {
                                                    Task{
                                                        isLoading = true
                                                        defer { isLoading = false }
                                                        
                                                        let newFriend = Friend(
                                                            id: UUID(),
                                                            userId: appData.currentUserId,
                                                            friendId: profile.id,
                                                            isAccepted: false
                                                        )
                                                        await SupabaseService.shared.insertFriend(newFriend)
                                                        
                                                        await prepFriends(userId: appData.currentUserId)
                                                    }
                                                } label: {
                                                    HStack {
                                                        if isLoading {
                                                            ProgressView()
                                                        } else {
                                                            Text("Add")
                                                        }
                                                    }
                                                    .frame(width: 32, height: 8)
                                                    .padding()
                                                    .background(isLoading ? Color.gray.opacity(0.5) : Color.blue)
                                                    .foregroundStyle(Color.white)
                                                    .cornerRadius(12)
                                                }
                                                .disabled(isLoading)
                                                
                                            } else {
                                                Text("Requested")
                                                    .foregroundStyle(Color.black.opacity(0.5))
                                            }
                                        } else {
                                            Text("Friend")
                                                .foregroundStyle(Color.black.opacity(0.5))
                                        }
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                        } else {
                            if !friends.isEmpty {
                                ForEach(friends, id: \.id) { profile in
                                    NavigationLink {
                                        ProfileInfo(userId: profile.id, username: profile.username, avatarURL: profile.avatarURL)
                                    } label: {
                                        HStack{
                                            Text(profile.username ?? "")
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .padding()
                                    }
                                }
                            } else {
                                Text("No friends yet, search friends to add")
                            }
                        }
                    }
                    Spacer()
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 30)
            .background(Color.black.opacity(0.05))
            .onAppear {
                Task{
                    await prepFriends(userId: appData.currentUserId)
                    friendSearch = ""
                }
            }
            .refreshable {
                Task{
                    await prepFriends(userId: appData.currentUserId)
                }
            }
        }
    }
}

#Preview {
    Friends()
}
