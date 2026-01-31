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
                            HStack {
                                Text("Friend requests")
                                Spacer()
                            }
                            .padding(.leading)
                            ForEach(friendRequests, id: \.id) { profile in
                                NavigationLink {
                                    FriendDetail(userId: profile.id, username: profile.username, avatarURL: profile.avatarURL, friendsData: friendsData)
                                } label: {
                                    HStack{
                                        HStack (alignment: .center, spacing: 12){
                                            AvatarView(avatarURL: profile.avatarURL, size: 40)
                                            Text(profile.username ?? "")
                                                .foregroundStyle(Color("SecondaryAppColor"))
                                        }
                                        Spacer()
                                        
                                        Button {
                                            Task{
                                                isLoading = true
                                                defer { isLoading = false }
                                                
                                                if let relation = friendsData.first(where: { $0.userId == profile.id && $0.friendId == appData.currentUserId }) {
                                                    
                                                    await SupabaseService.shared.deleteFriend(relation)
                                                    await prepFriends(userId: appData.currentUserId)
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                if isLoading {
                                                    ProgressView()
                                                } else {
                                                    Image(systemName: "xmark")
                                                }
                                            }
                                            .foregroundStyle(Color.white)
                                            .font(.title2)
                                            .frame(width: 40, height: 40)
                                            .background(isLoading ? Color.gray.opacity(0.5) : Color.red)
                                            .cornerRadius(8)
                                        }
                                        Button {
                                            Task{
                                                isLoading = true
                                                defer { isLoading = false }
                                                
                                                if let relation = friendsData.first(where: { $0.userId == profile.id && $0.friendId == appData.currentUserId }) {
                                                    
                                                    relation.isAccepted = true
                                                    await SupabaseService.shared.updateFriend(relation)
                                                    
                                                    await prepFriends(userId: appData.currentUserId)
                                                }
                                            }
                                        } label: {
                                            HStack {
                                                if isLoading {
                                                    ProgressView()
                                                } else {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                            .foregroundStyle(Color.white)
                                            .font(.title2)
                                            .frame(width: 40, height: 40)
                                            .background(isLoading ? Color.gray.opacity(0.5) : Color.green)
                                            .cornerRadius(8)
                                        }
                                    }
                                    .padding()
                                    .background(Color("PrimaryAppColor"))
                                    .foregroundStyle(Color("SecondaryAppColor"))
                                    .cornerRadius(12)
                                    .padding(.horizontal, 16)
                                }
                            }
                        }
                        Divider()
                            .padding()
                    }
                    
                    VStack {
                        TextField("Search friends", text: $friendSearch)
                            .textContentType(.username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(12)
                            .background(Color("PrimaryAppColor"))
                            .cornerRadius(12)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        
                        if friendSearch.count > 0 {
                            VStack{
                                ForEach(
                                    profiles
                                        .filter { $0.username?.localizedCaseInsensitiveContains(friendSearch) == true }
                                        , id: \.id)
                                { profile in
                                    NavigationLink {
                                        FriendDetail(userId: profile.id, username: profile.username, avatarURL: profile.avatarURL, friendsData: friendsData)
                                    } label: {
                                        HStack {
                                            HStack (alignment: .center, spacing: 12){
                                                AvatarView(avatarURL: profile.avatarURL, size: 40)
                                                Text(profile.username ?? "")
                                                    .foregroundStyle(Color("SecondaryAppColor"))
                                            }
                                            Spacer()
                                            if !friends.contains( where: { $0.id == profile.id } ) {
                                                if !friendsData.contains( where: { $0.friendId == profile.id || $0.userId == profile.id } ) {
                                                    Button {
                                                        Task{
                                                            isLoading = true
                                                            defer { isLoading = false }
                                                            
                                                            if let requestedFriend = await SupabaseService.shared.hasFriendRequestFrom(userId: profile.id, currentUserId: appData.currentUserId) {
                                                                requestedFriend.isAccepted = true
                                                                await SupabaseService.shared.updateFriend(requestedFriend)
                                                            } else {
                                                                let newFriend = Friend(
                                                                    id: UUID(),
                                                                    userId: appData.currentUserId,
                                                                    friendId: profile.id,
                                                                    isAccepted: false
                                                                )
                                                                await SupabaseService.shared.insertFriend(newFriend)
                                                            }
                                                            
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
                                                        .foregroundStyle(Color("PrimaryAppColor"))
                                                        .cornerRadius(12)
                                                    }
                                                    .disabled(isLoading)
                                                    
                                                } else {
                                                    Text("Requested")
                                                        .foregroundStyle(Color("SecondaryAppColor").opacity(0.5))
                                                }
                                            } else {
                                                Text("Friend")
                                                    .foregroundStyle(Color("SecondaryAppColor").opacity(0.5))
                                            }
                                        }
                                        .padding()
                                        .background(Color("PrimaryAppColor"))
                                        .cornerRadius(12)
                                    }
                                    
                                }
                            }
                            .padding(.horizontal, 16)
                        } else {
                            if !friends.isEmpty {
                                HStack {
                                    Text("Friends")
                                    Spacer()
                                }
                                .padding(.leading)
                                    
                                ForEach(friends, id: \.id) { profile in
                                    NavigationLink {
                                        FriendDetail(userId: profile.id, username: profile.username, avatarURL: profile.avatarURL, friendsData: friendsData)
                                    } label: {
                                        HStack (alignment: .center, spacing: 12){
                                            AvatarView(avatarURL: profile.avatarURL, size: 40)
                                            Text(profile.username ?? "")
                                                .foregroundStyle(Color("SecondaryAppColor"))
                                            Spacer()
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color("PrimaryAppColor"))
                                        .cornerRadius(12)
                                        .padding(.horizontal, 16)
                                    }
                                    
                                }
                            } else {
                                Text("No friends yet, search friends to add")
                                    .foregroundStyle(Color("SecondaryAppColor").opacity(0.5))
                            }
                        }
                    }
                    Spacer()
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical, 30)
            .background(Color("BackgroundAppColor"))
            .onAppear {
                Task{
                    await prepFriends(userId: appData.currentUserId)
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
