//  Rise Shine Swing
//
//  Created by Abdul-JAM-E-157 on 31/08/24.

import Foundation
import UIKit

struct AppFont {
    static let Labeltitle = OutFitFont.defaultBold(size: 13).value
    static let LblTitleBold_15 = OutFitFont.defaultBold(size: 15).value
    static let LblTitle_15 = OutFitFont.defaultRegular(size: 15).value
    static let LblTitle_17 = OutFitFont.defaultRegular(size: 17).value
    static let LblTitleBold_17 = OutFitFont.defaultBold(size: 17).value
    static let Btntitle = OutFitFont.defaultExtraBold(size: 15).value
    static let placeHolder = JostFont.defaultRegular(size: 13).value
    static let mediumTitle = OutFitFont.defaultMedium(size: 13).value
}


public enum OutFitFont {
    case defaultBlack(size: Float)
    case defaultBold(size: Float)
    case defaultExtraBold(size: Float)
    case defaultExtraLight(size: Float)
    case defaultLight(size: Float)
    case defaultMedium(size: Float)
    case defaultRegular(size: Float)
    case defaultSemiBold(size: Float)
    case defaultThin(size: Float)
}

extension OutFitFont {
    var value: UIFont? {
        switch self {
        case .defaultBlack(size: let size):
            return UIFont(name: "Outfit-Black", size: CGFloat(size))
        case .defaultBold(size: let size):
            return UIFont(name: "Outfit-Bold", size: CGFloat(size))
        case .defaultExtraBold(size: let size):
            return UIFont(name: "Outfit-ExtraBold", size: CGFloat(size))
        case .defaultExtraLight(size: let size):
            return UIFont(name: "Outfit-ExtraLight", size: CGFloat(size))
        case .defaultLight(size: let size):
            return UIFont(name: "Outfit-Light", size: CGFloat(size))
        case .defaultMedium(size: let size):
            return UIFont(name: "Outfit-Medium", size: CGFloat(size))
        case .defaultRegular(size: let size):
            return UIFont(name: "Outfit-Regular", size: CGFloat(size))
        case .defaultSemiBold(size: let size):
            return UIFont(name: "Outfit-SemiBold", size: CGFloat(size))
        case .defaultThin(size: let size):
            return UIFont(name: "Outfit-Thin", size: CGFloat(size))
        }
    }
}


public enum JostFont {
    case defaultBlack(size: Float)
    case defaultBlackItalic(size: Float)
    case defaultBold(size: Float)
    case defaultBoldItalic(size: Float)
    case defaultExtraBold(size: Float)
    case defaultExtraBoldItalic(size: Float)
    case defaultExtraLight(size: Float)
    case defaultExtraLightItalic(size: Float)
    case defaultItalic(size: Float)
    case defaultLight(size: Float)
    case defaultLightItalic(size: Float)
    case defaultMedium(size: Float)
    case defaultMediumItalic(size: Float)
    case defaultRegular(size: Float)
    case defaultSemiBold(size: Float)
    case defaultSemiBoldItalic(size: Float)
    case defaultThin(size: Float)
    case defaultThinItalic(size: Float)
}

//Jost-Black.ttf
//Jost-BlackItalic.ttf
//Jost-Bold.ttf
//Jost-BoldItalic.ttf
//Jost-ExtraBold.ttf
//Jost-ExtraBoldItalic.ttf
//Jost-ExtraLight.ttf
//Jost-ExtraLightItalic.ttf
//Jost-Italic.ttf
//Jost-Light.ttf
//Jost-LightItalic.ttf
//Jost-Medium.ttf
//Jost-MediumItalic.ttf
//Jost-Regular.ttf
//Jost-SemiBold.ttf
//Jost-SemiBoldItalic.ttf
//Jost-Thin.ttf
//Jost-ThinItalic.ttf
extension JostFont {
    var value: UIFont? {
        switch self {
        case .defaultBlack(size: let size):
            return UIFont(name: "Jost-Black", size: CGFloat(size))
        case .defaultBlackItalic(size: let size):
            return UIFont(name: "Jost-BlackItalic", size: CGFloat(size))
        case .defaultBold(size: let size):
            return UIFont(name: "Jost-Bold", size: CGFloat(size))
        case .defaultBoldItalic(size: let size):
            return UIFont(name: "Jost-ExtraBold", size: CGFloat(size))
        case .defaultExtraBold(size: let size):
            return UIFont(name: "Jost-ExtraBoldItalic", size: CGFloat(size))
        case .defaultExtraBoldItalic(size: let size):
            return UIFont(name: "Jost-ExtraBoldItalic", size: CGFloat(size))
        case .defaultExtraLight(size: let size):
            return UIFont(name: "Jost-ExtraLight", size: CGFloat(size))
        case .defaultExtraLightItalic(size: let size):
            return UIFont(name: "Jost-ExtraLightItalic", size: CGFloat(size))
        case .defaultItalic(size: let size):
            return UIFont(name: "Jost-Italic", size: CGFloat(size))
        case .defaultLight(size: let size):
            return UIFont(name: "Jost-Light", size: CGFloat(size))
        case .defaultLightItalic(size: let size):
            return UIFont(name: "Jost-LightItalic", size: CGFloat(size))
        case .defaultMedium(size: let size):
            return UIFont(name: "Jost-Medium", size: CGFloat(size))
        case .defaultMediumItalic(size: let size):
            return UIFont(name: "Jost-MediumItalic", size: CGFloat(size))
        case .defaultRegular(size: let size):
            return UIFont(name: "Jost-Regular", size: CGFloat(size))
        case .defaultSemiBold(size: let size):
            return UIFont(name: "Jost-SemiBold", size: CGFloat(size))
        case .defaultSemiBoldItalic(size: let size):
            return UIFont(name: "Jost-SemiBoldItalic", size: CGFloat(size))
        case .defaultThin(size: let size):
            return UIFont(name: "Jost-Thin", size: CGFloat(size))
        case .defaultThinItalic(size: let size):
            return UIFont(name: "Jost-ThinItalic", size: CGFloat(size))
        }
    }
}

//public enum InterFont {
//    case defaultBlack(size: Float)
//    case defaultBlackItalic(size: Float)
//    case defaultBold(size: Float)
//    case defaultBoldItalic(size: Float)
//    case defaultRegular(size: Float)
//    case defaultMedium(size: Float)
//}

//extension InterFont {
//    var value: UIFont? {
//        switch self {
//        case .defaultBlack(let size):
//            return UIFont(name: "Inter_18pt-Black", size: CGFloat(size))
//        case .defaultBlackItalic(let size):
//            return UIFont(name: "Inter_18pt-BlackItalic", size: CGFloat(size))
//        case .defaultBold(let size):
//            return UIFont(name: "Inter_18pt-Bold", size: CGFloat(size))
//        case .defaultBoldItalic(let size):
//            return UIFont(name: "Inter_18pt-BoldItalic", size: CGFloat(size))
//        case .defaultRegular(let size):
//            return UIFont(name: "Inter_18pt-Regular", size: CGFloat(size))
//        case .defaultMedium(let size):
//            return UIFont(name: "Inter_18pt-Medium", size: CGFloat(size))
//            
//        }
//    }
//}
