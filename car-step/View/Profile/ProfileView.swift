//
//  ProfileView.swift
//  car-step
//
//  Created by Maxim Tampere on 21/01/2026.
//

import PhotosUI
import Storage
import Supabase
import SwiftUI
import _SwiftData_SwiftUI

struct ProfileView: View {
    @Environment(AppData.self) private var appData
    @Environment(\.modelContext) private var context
    
    @AppStorage("storedUsername") var storedUsername: String = ""
    @AppStorage("storedAvatarURL") var storedAvatarURL: String = ""

    @Query private var days: [Day]
    @Query private var parts: [Part]
    @Query private var quests: [Quest]
    
    @State var username: String = ""
    @State var questCompleted: Int = 0
    @State var totalParts: Int = 0
    @State var lastSevenDays: [Day] = []

    @State var isLoading = false
    @State private var isEditing = false

    var body: some View {
        NavigationStack {
            VStack {
                if !isLoading {
                    ScrollView{
                        VStack(spacing: 20) {
                            Group {
                                AvatarView(
                                    avatarURL: storedAvatarURL,
                                    size: 160
                                )
                            }
                            .scaledToFill()
                            .frame(width: 160, height: 160)
                            .clipShape(Circle())
                            Text(storedUsername)
                                .font(.headline)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                        
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
                        
                        SevenDaysGraphic(days: days)
                        
                        Spacer()
                    }
                    .toolbar(content: {
                        ToolbarItem {
                            Menu("Actions", systemImage: "ellipsis") {
                                Button("Edit Profile", systemImage: "pencil") {
                                    isEditing = true
                                }
                                Button("Sync Watch", systemImage: "applewatch.radiowaves.left.and.right") {
                                    if let car = appData.car, let fuel = appData.fuel {
                                        WatchConnectivitySync.shared.sendSetup(days: days, parts: parts, fuel: fuel, car: car)
                                    }
                                }
                                Button("Sign out", systemImage: "iphone.and.arrow.right.outward", role: .destructive) {
                                    Task {
                                        try? await supabase.auth.signOut()
                                        storedUsername = ""
                                        storedAvatarURL = ""
                                        await appData.resetApp(context: context)
                                        WatchConnectivitySync.shared.sendLogOut()
                                    }
                                }
                                .foregroundStyle(Color.red)
                            }
                        }
                    })
                } else {
                    ProgressView()
                }
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("BackgroundAppColor"))
        }
        .refreshable {
            Task {
                await getInitialProfile()
            }
        }
        .onAppear {
            questCompleted = quests.filter { $0.claimed }.count
            totalParts = parts.filter { $0.partMade }.count
        }
        .popover(isPresented: $isEditing) {
            EditProfile(
                onSave: {
                    Task {
                        await getInitialProfile()
                    }
                },
                pageTitle: "Edit Profile",
                buttonLabel: "Save Changes",
                username: username,
            )
        }
    }

    func getInitialProfile() async {
        do {
            let currentUser = try await supabase.auth.session.user

            let profileDTO: ProfileDTO =
            try await supabase
                .from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            let profile = Profile(dto: profileDTO)
            
            storedUsername = profile.username ?? ""
            storedAvatarURL = profile.avatarURL ?? ""

        } catch {
            debugPrint(error)
        }
    }
}
