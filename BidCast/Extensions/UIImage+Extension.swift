//
//  UIImage+Extension.swift
//  BidCast
//
//  Created by JamTech on 07/11/25.
//

import Foundation
import UIKit

extension UIImage {
    /// Returns the size of the image in bytes, kilobytes, or megabytes.
    func getImageSize(unit: Unit = .mb) -> Double {
        guard let imageData = self.jpegData(compressionQuality: 1.0) else { return 0 }
        let bytes = Double(imageData.count)
        
        switch unit {
        case .bytes:
            return bytes
        case .kb:
            return bytes / 1024.0
        case .mb:
            return bytes / (1024.0 * 1024.0)
        }
    }
    
    enum Unit {
        case bytes
        case kb
        case mb
    }
}

func findLargeImageIndex(in images: [UIImage], limitInMB: Double = 5.0) -> Int {
    for (index, image) in images.enumerated() {
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { continue }
        let imageSizeInMB = Double(imageData.count) / (1024.0 * 1024.0)
        
        if imageSizeInMB > limitInMB {
            return index  // 🔹 Return first image index exceeding 5 MB
        }
    }
    return -1 // 🔹 All images are within the limit
}
