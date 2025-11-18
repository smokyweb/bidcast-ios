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

    var body: some View {
        ZStack {
            if isLoading {
                PulseShimmerView()
                    .frame(height: 70)
                    .cornerRadius(12)
            }

            if let image = loadedImage {
                image
                    .resizable()
                    .scaledToFill()
                    .transition(.opacity.animation(.easeIn(duration: 0.3)))
//                    .cornerRadius(12)
            }
        }
        .onAppear {
            loadImage()
        }
    }

    private func loadImage() {
        guard let imageURL = URL(string: url) else { return }

        // Cache check first
        // 🧠 Step 1: Check cache first
        if let cached = ImageCacheManager.shared.getImage(forKey: url) {
            self.loadedImage = Image(uiImage: cached)
            self.isLoading = false
            return
        }

        // Download if not cached
        URLSession.shared.dataTask(with: imageURL) { data, _, _ in
            guard let data = data,
                  let uiImage = UIImage(data: data) else { return }

            // Save in cache
            ImageCacheManager.shared.setImage(uiImage, forKey: url)

            DispatchQueue.main.async {
                self.loadedImage = Image(uiImage: uiImage)
                self.isLoading = false
            }
        }.resume()
    }
}
