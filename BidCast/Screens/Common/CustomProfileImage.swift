//
//  CustomProfileImage.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 20/06/25.
//
import SwiftUI
import Foundation

struct CustomProfileImage: View {
    let url: String?
    var isCircular: Bool = true
    var cornerRadius: CGFloat = 8
    var size: CGFloat = 40
    var height: CGFloat = 0
    var defaultImage: String?
    
    var body: some View {
        if let url = url, !url.isEmpty, let imageURL = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "") {
            CachedAsyncImage(
                url: imageURL,
                placeholder: AnyView(
                    Color.gray.opacity(0.3)
                        .frame(width: size, height: height == 0 ? size : height)
                        .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)
                        .shimmer()
                ),
                width: size,
                height: height,
                cornerRadius: cornerRadius,
                isCircular: isCircular,
                defaultImage: defaultImage
            )
        } else {
            Image(defaultImage ?? "defaultUser")
                .resizable()
                .scaledToFill()
                .frame(width: size, height: height == 0 ? size : height)
                .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
        }
    }
}

struct CachedAsyncImage: View {
    let url: URL?
    let placeholder: AnyView
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let isCircular: Bool
    var defaultImage: String?

    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height == 0 ? width : height)
                    .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            } else {
                placeholder
                    .onAppear {
                        loadImage()
                    }
            }
        }
    }

    private func loadImage() {
        guard let url = url else {
            uiImage = UIImage(named: defaultImage ?? "defaultUser")
            return
        }

        let key = url.absoluteString

        // 🧠 Step 1: Check cache first
        if let cached = ImageCacheManager.shared.getImage(forKey: key) {
            self.uiImage = cached
            return
        }

        // 🕸️ Step 2: Fetch if not cached
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, let image = UIImage(data: data) else { return }

            // Save in cache
            ImageCacheManager.shared.setImage(image, forKey: key)

            // Update UI on main thread
            DispatchQueue.main.async {
                self.uiImage = image
            }
        }.resume()
    }
}


extension View {
    func applyClip(isCircular: Bool, cornerRadius: CGFloat) -> some View {
        Group {
            if isCircular {
                self.clipShape(Circle())
            } else {
                self.clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            }
        }
    }
}
