//
//  CustomProfileImage.swift
//  BidCast - OPTIMIZED VERSION
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
    
    var profileIconTapped: (() -> Void) = { }
    
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
            .id(imageURL.absoluteString)
            .onTapGesture {
                profileIconTapped()
            }
        } else {
            Image(defaultImage ?? "defaultUser")
                .resizable()
                .scaledToFill()
                .frame(width: size, height: height == 0 ? size : height)
                .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)
                .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                .onTapGesture {
                    profileIconTapped()
                }
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
    @State private var loadingTask: Task<Void, Never>?

    var body: some View {
        Group {
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height == 0 ? width : height)
                    .applyClip(isCircular: isCircular, cornerRadius: cornerRadius)
                    .drawingGroup() // ✨ Renders shadow once, huge performance boost
                    .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
            } else {
                placeholder
            }
        }
        .task(id: url?.absoluteString) {
            // ✅ Automatic cancellation when URL changes or view disappears
            await loadImage()
        }
        .onDisappear {
            // ✅ Cancel loading when scrolled away
            loadingTask?.cancel()
        }
    }

    private func loadImage() async {
        guard let url = url else {
            uiImage = UIImage(named: defaultImage ?? "defaultUser")
            return
        }

        let key = url.absoluteString

        // 🧠 Check cache first (synchronous, instant)
        if let cached = ImageCacheManager.shared.getImage(forKey: key) {
            self.uiImage = cached
            return
        }

        // 🕸️ Fetch from network with proper cancellation
        do {
            let (data, response) = try await ImageDownloader.shared.downloadImage(from: url)
            
            // Validate response
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                uiImage = UIImage(named: defaultImage ?? "defaultUser")
                return
            }
            
            // ⚡ Decode image OFF main thread
            guard let image = await decodeImage(from: data) else {
                uiImage = UIImage(named: defaultImage ?? "defaultUser")
                return
            }

            // ✅ Downscale if needed (HUGE memory saver)
            let scaledImage = await scaleImage(image, toFit: CGSize(width: width * 2, height: (height == 0 ? width : height) * 2))
            
            // Save in cache
            ImageCacheManager.shared.setImage(scaledImage, forKey: key)

            // Update UI
            self.uiImage = scaledImage
            
        } catch is CancellationError {
            // Task was cancelled, do nothing
            return
        } catch {
            // Load default on error
            uiImage = UIImage(named: defaultImage ?? "defaultUser")
        }
    }
    
    // ⚡ Decode image on background thread
    private func decodeImage(from data: Data) async -> UIImage? {
        await Task.detached(priority: .userInitiated) {
            guard let image = UIImage(data: data) else { return nil }
            
            // Force decode to prevent UI thread decoding later
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            format.opaque = true
            
            let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
            return renderer.image { context in
                image.draw(at: .zero)
            }
        }.value
    }
    
    // 🎯 Scale down large images (critical for memory)
    private func scaleImage(_ image: UIImage, toFit targetSize: CGSize) async -> UIImage {
        await Task.detached(priority: .userInitiated) {
            let size = image.size
            
            // Don't upscale
            guard size.width > targetSize.width || size.height > targetSize.height else {
                return image
            }
            
            let widthRatio = targetSize.width / size.width
            let heightRatio = targetSize.height / size.height
            let scaleFactor = min(widthRatio, heightRatio)
            
            let scaledSize = CGSize(
                width: size.width * scaleFactor,
                height: size.height * scaleFactor
            )
            
            let format = UIGraphicsImageRendererFormat()
            format.scale = 1
            
            let renderer = UIGraphicsImageRenderer(size: scaledSize, format: format)
            return renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: scaledSize))
            }
        }.value
    }
}

// ⚡ Shared URLSession with optimized configuration
class ImageDownloader {
    static let shared = ImageDownloader()
    
    private let session: URLSession
    
    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15 // 15 second timeout
        config.timeoutIntervalForResource = 30
        config.httpMaximumConnectionsPerHost = 4 // Limit concurrent downloads
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = URLCache(
            memoryCapacity: 50 * 1024 * 1024, // 50 MB memory
            diskCapacity: 100 * 1024 * 1024 // 100 MB disk
        )
        
        self.session = URLSession(configuration: config)
    }
    
    func downloadImage(from url: URL) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        return try await session.data(for: request)
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
