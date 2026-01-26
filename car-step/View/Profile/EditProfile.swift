//
//  EditProfile.swift
//  car-step
//
//  Created by Maxim Tampere on 21/01/2026.
//

import PhotosUI
import Storage
import Supabase
import SwiftUI

struct EditProfile: View {
    @Environment(\.dismiss) private var dismiss
    let onSave: () -> Void?
    let pageTitle: String
    let buttonLabel: String
    
    @State var username: String
    @State var avatarImage: AvatarImage?

    @State var isLoading = false
    @State var imageSelection: PhotosPickerItem?
    @State var errorMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text(pageTitle)
                .font(.largeTitle)
                .bold()
            
            ZStack(alignment: .bottomTrailing) {
                Group {
                    if let avatarImage {
                        avatarImage.image.resizable()
                    } else {
                        Color.black.opacity(0.2)
                    }
                }
                .scaledToFill()
                .frame(width: 160, height: 160)
                .cornerRadius(90)

                Spacer()

                PhotosPicker(selection: $imageSelection, matching: .images) {
                    Image(systemName: "pencil.circle.fill")
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 30))
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.top, 32)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Username*")
                    .opacity(0.75)
                TextField("...", text: $username)
                    .textContentType(.username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .background(Color.white)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(12)
                    .onChange(of: username) {
                        errorMessage = ""
                    }
                Text("- Your username needs 3-15 characters")
                    .font(.caption)
                    .opacity(0.5)
                    .padding(.leading)
                Text(errorMessage)
                    .foregroundStyle(Color.red)
            }
            .padding(.horizontal, 20)
            
            Spacer()
            
            Button {
                updateProfileButtonTapped()
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                    } else {
                        Text(buttonLabel)
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isLoading || !isUsernameValid() ? Color.gray.opacity(0.5) : Color.blue)
                .foregroundStyle(Color.white)
                .cornerRadius(12)
            }
            .disabled(isLoading || !isUsernameValid())
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 30)
        .background(Color.black.opacity(0.05))
        .onChange(of: imageSelection) { _, newValue in
            guard let newValue else { return }
            loadTransferable(from: newValue)
        }
    }
    
    func isUsernameUnique(_ username: String) async -> Bool {
        do {
            let currentUser = try await supabase.auth.session.user
            
            let response = try await supabase
                .from("profiles")
                .select()
                .eq("username", value: username)
                .neq("id", value: currentUser.id)
                .execute()
            
            let data = response.data
            let profiles = try JSONDecoder().decode([ProfileDTO].self, from: data)
            return profiles.isEmpty
            
        } catch {
            debugPrint("Error checking username uniqueness:", error)
            return false
        }
    }


    func updateProfileButtonTapped() {
        Task {
            errorMessage = ""
            isLoading = true
            defer { isLoading = false }
            
            if await !isUsernameUnique(username) {
                errorMessage = "Username already taken"
                return
            }
            
            do {
                let imageURL = try await uploadImage()

                let currentUser = try await supabase.auth.session.user

                let updatedProfile = ProfileUpdate(
                    username: username,
                    avatarURL: imageURL
                )

                try await supabase
                    .from("profiles")
                    .update(updatedProfile)
                    .eq("id", value: currentUser.id)
                    .execute()
                
                onSave()
                dismiss()
            } catch {
                debugPrint(error)
            }
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

    private func uploadImage() async throws -> String? {
        guard let data = avatarImage?.data else { return nil }

        let filePath = "\(UUID().uuidString).jpeg"

        try await supabase.storage
            .from("avatars")
            .upload(
                filePath,
                data: data,
                options: FileOptions(contentType: "image/jpeg")
            )

        return filePath
    }
    
    func isUsernameValid() -> Bool {
        return username.count >= 3 && username.count <= 15
    }
}

#Preview {
    EditProfile(onSave: {}, pageTitle: "edit", buttonLabel: "done", username: "")
}
