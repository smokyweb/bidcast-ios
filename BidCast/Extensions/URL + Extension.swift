//
//  URL + Extension.swift
//  BidCast
//
//  Created by jam 1 TB on 20/01/25.
//

import Foundation


extension URL {
    var fileSize: Double {
        //func to know fileSize
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: self.path)
            if let fileSize = fileAttributes[.size] as? NSNumber {
                let sizeInBytes = fileSize
                return Double(sizeInBytes)
            }
            return 0.0
        }
        catch {
            debugLog("Error in Getting file")
            return 0.0
        }
    }

}

