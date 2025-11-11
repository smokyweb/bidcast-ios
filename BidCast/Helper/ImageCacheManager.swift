//
//  ImageCacheManager.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 28/10/25.
//

import Foundation
import SwiftUI

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSString, UIImage>()
    private init() {}

    func getImage(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
