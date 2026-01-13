//
//  URLImageView.swift
//  BidCast
//
//  Created by JamTech on 15/11/25.
//

import SwiftUI

struct URLImageView: View {
    let url: String
    @State private var loadedImage: Image?
    @State private var isLoading = true
    var cornerRadius: CGFloat = 12
    var height: CGFloat = 70
    @State private var loadTask: Task<Void, Never>?
    var body: some View {
        ZStack {
            if isLoading {
                PulseShimmerView()
                    .frame(height: height)
                    .cornerRadius(cornerRadius)
            }

            if let image = loadedImage {
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
                    .cornerRadius(cornerRadius)
            }
        }
        .onAppear {
            Task{
                await loadImage()
            }
        }
    }

    private func loadImage() async {
            guard let imageURL = URL(string: url) else { return }

            // 🧠 1. Memory cache (instant)
            if let cached = ImageCacheManager.shared.getImage(forKey: url) {
                self.loadedImage = Image(uiImage: cached)
                self.isLoading = false
                return
            }

            loadTask = Task {
                do {
                    let (data, response) = try await ImageDownloader.shared.downloadImage(from: imageURL)

                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode),
                          !Task.isCancelled else { return }

                    // ⚡ Decode off main thread
                    guard let image = await decodeImage(from: data) else { return }

                    // 💾 Cache
                    ImageCacheManager.shared.setImage(image, forKey: url)

                    await MainActor.run {
                        self.loadedImage = Image(uiImage: image)
                        self.isLoading = false
                    }

                } catch is CancellationError {
                    return
                } catch {
                    return
                }
            }
        }

        // ⚡ Force decode on background thread
        private func decodeImage(from data: Data) async -> UIImage? {
            await Task.detached(priority: .userInitiated) {
                guard let image = UIImage(data: data) else { return nil }

                let format = UIGraphicsImageRendererFormat()
                format.scale = 1
                format.opaque = true

                let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
                return renderer.image { _ in
                    image.draw(at: .zero)
                }
            }.value
        }
    
    
}
