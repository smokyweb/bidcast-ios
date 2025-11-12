//
//  DoownloadManager.swift
//  BidCast
//
//  Created by JamTech on 11/11/25.
//

import Foundation
import UIKit

final class DownloadManager {
    
    // MARK: - Singleton Instance
    static let shared = DownloadManager()
    private init() {}
    
    // MARK: - In-Memory Cache
    private let cache = NSCache<NSString, UIImage>()
    
    // MARK: - Download Image Function
    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // 1️⃣ Validate URL
        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL: \(urlString)")
            completion(nil)
            return
        }
        
        // 2️⃣ Check if image is already cached
        if let cachedImage = cache.object(forKey: urlString as NSString) {
            print("✅ Loaded from cache: \(urlString)")
            completion(cachedImage)
            return
        }
        
        // 3️⃣ Download from network
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Image download error:", error.localizedDescription)
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            guard
                let data = data,
                let image = UIImage(data: data)
            else {
                print("❌ Invalid image data for URL:", urlString)
                DispatchQueue.main.async { completion(nil) }
                return
            }
            
            // 4️⃣ Cache it
            self.cache.setObject(image, forKey: urlString as NSString)
            
            // 5️⃣ Return image on main thread
            DispatchQueue.main.async {
                print("⬇️ Downloaded from network: \(urlString)")
                completion(image)
            }
        }
        
        task.resume()
    }
}
