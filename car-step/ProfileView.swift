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

    @Query private var days: [Day]
    @Query private var parts: [Part]
    
    @State var username = ""

    @State var isLoading = false
    @State private var isEditing = false

    @State var imageSelection: PhotosPickerItem?
    @State var avatarImage: AvatarImage?

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading){
                HStack(spacing: 20) {
                    Group {
                        if let avatarImage {
                            avatarImage.image.resizable()
                        } else {
                            Color.black.opacity(0.2)
                        }
                    }
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    Text("@\(username)")
                        .font(.headline)
                    Spacer()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(20)
                .padding(20)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.05))
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
                                await appData.resetApp(context: context)
                            }
                        }
                        .foregroundStyle(Color.red)
                    }
                }
            })
            .onChange(of: imageSelection) { _, newValue in
                guard let newValue else { return }
                loadTransferable(from: newValue)
            }
        }
        .task {
            await getInitialProfile()
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
                avatarImage: avatarImage,
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
            
            username = profile.username ?? ""

            if let avatarURL = profile.avatarURL, !avatarURL.isEmpty {
                try await downloadImage(path: avatarURL)
            }

        } catch {
            debugPrint(error)
        }
    }

    private func loadTransferable(from imageSelection: PhotosPickerItem) {
        Task {
            do {
                avatarImage = try await imageSelection.loadTransferable(type: AvatarImage.self)
            } catch {
                debugPrint(error)
            }
        }
    }

    private func downloadImage(path: String) async throws {
        let data = try await supabase.storage.from("avatars").download(path: path)
        avatarImage = AvatarImage(data: data)
    }
}
