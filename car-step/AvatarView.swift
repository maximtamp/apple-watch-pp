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
    
    private var cache = NSCache<NSString, UIImage>()
    
    func image(forKey key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
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
            } else if isLoading {
                ProgressView()
            }
        }
        .frame(width: size, height: size)
        .background(Color.black.opacity(0.2))
        .clipShape(Circle())
        .task {
            await loadImage()
        }
    }
    
    private func loadImage() async {
        guard avatarImage == nil, let avatarURL, !avatarURL.isEmpty else { return }
        
        if let cached = ImageCache.shared.image(forKey: avatarURL) {
            avatarImage = AvatarImage(data: cached.pngData()!)
            return
        }
        
        let fileURL = getCachedFileURL(for: avatarURL)
            if let data = try? Data(contentsOf: fileURL) {
                avatarImage = AvatarImage(data: data)
                return
            }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let data = try await supabase.storage.from("avatars").download(path: avatarURL)
            let newAvatar = AvatarImage(data: data)
            avatarImage = newAvatar
            
            if let uiImage = newAvatar?.image.asUIImage() {
                ImageCache.shared.setImage(uiImage, forKey: avatarURL)
            }
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

extension Image {
    func asUIImage() -> UIImage? {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}

