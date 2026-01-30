//
//  AvatarView.swift
//  car-step
//
//  Created by Maxim Tampere on 28/01/2026.
//

import SwiftUI
import Supabase

class ImageCache {
    static let shared = ImageCache()
    private init() {}

    private var cache = NSCache<NSString, NSData>()

    func data(forKey key: String) -> Data? {
        cache.object(forKey: key as NSString) as Data?
    }

    func setData(_ data: Data, forKey key: String) {
        cache.setObject(data as NSData, forKey: key as NSString)
    }
}


struct AvatarView: View {
    let avatarURL: String?
    var size: CGFloat = 80
    
    @State private var avatarImage: AvatarImage?
    @State private var isLoading: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
            
            if let avatarImage {
                avatarImage.image
                    .resizable()
                    .scaledToFill()
                    .frame(width: size, height: size)
                    .clipped()
            } else if isLoading {
                ProgressView()
            }
        }
        .frame(width: size, height: size)
        .background(Color.black.opacity(0.2))
        .clipShape(Circle())
        .task(id: avatarURL) {
            await loadImage()
        }


    }
    
    @MainActor
    private func loadImage() async {
        guard avatarImage == nil, let avatarURL, !avatarURL.isEmpty else { return }

        if let cachedData = ImageCache.shared.data(forKey: avatarURL) {
            avatarImage = AvatarImage(data: cachedData)
            return
        }

        let fileURL = getCachedFileURL(for: avatarURL)
        if let data = try? Data(contentsOf: fileURL) {
            avatarImage = AvatarImage(data: data)
            ImageCache.shared.setData(data, forKey: avatarURL)
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let data = try await supabase.storage
                .from("avatars")
                .download(path: avatarURL)

            avatarImage = AvatarImage(data: data)
            ImageCache.shared.setData(data, forKey: avatarURL)
        } catch {
            print("Avatar fail:", error)
        }
    }
    
    private func getCachedFileURL(for key: String) -> URL {
        let cachesDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        let fileName = key.replacingOccurrences(of: "/", with: "_")
        return cachesDirectory.appendingPathComponent(fileName)
    }
}

