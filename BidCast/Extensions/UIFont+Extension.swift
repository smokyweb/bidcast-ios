//
//  UIFont+Extension.swift
//  MentorPOS
//
//  Created by admin on 3/3/20.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import UIKit
public enum MentorPOSFont {
    
    case defaultLight(size: Float)
    case defaultMedium(size: Float)
    case defaultBold(size: Float)
    case defaultRegular(size: Float)
    case defaultMediumItalic(size: Float)
    case defaultBoldItalic(size: Float)
    case defaultLightItalic(size: Float)
    case defaultExtraLight(size: Float)
    case defaultSemiBold(size: Float)
    
}


extension MentorPOSFont {
    var value: UIFont? {
        switch self {
        case .defaultLight(let size):
            return UIFont(name: "Metropolis-Light", size: CGFloat(size))
        case .defaultMedium(let size):
            return UIFont(name: "Metropolis-Medium", size: CGFloat(size))
        case .defaultBold(let size):
            return UIFont(name: "Metropolis-Bold", size: CGFloat(size))
        case .defaultRegular(let size):
            return UIFont(name: "Metropolis-Regular", size: CGFloat(size))
        case .defaultMediumItalic(let size):
            return UIFont(name: "Metropolis-MediumItalic", size: CGFloat(size))
        case .defaultBoldItalic(let size):
            return UIFont(name: "Metropolis-BoldItalic", size: CGFloat(size))
        case .defaultLightItalic(let size):
            return UIFont(name: "Metropolis-LightItalic", size: CGFloat(size))
        case .defaultExtraLight(let size):
            return UIFont(name: "Metropolis-ExtraLight", size: CGFloat(size))
        case .defaultSemiBold(let size):
        return UIFont(name: "Metropolis-SemiBold", size: CGFloat(size))
        }
    }
}
