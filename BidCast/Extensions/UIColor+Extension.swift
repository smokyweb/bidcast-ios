//
//  UIColor+Extension.swift
//  MentorPOS
//
//  Created by admin on 3/3/20.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

extension UIColor{
    convenience init(r:CGFloat, g:CGFloat, b:CGFloat, alpha:CGFloat){
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
        //MARK:- Green
    
    static var seaWeedGreen:UIColor {
        return UIColor(r: 51, g: 169, b: 110, alpha: 1)
            //f15927
    }
    
    static var greenTealColor:UIColor {
        return UIColor(r: 60, g: 203, b: 132, alpha: 1)
            //f15927
    }
    
    
        //MARK:- ORANGE
    
    static var defaultOrangeColor:UIColor {
        return UIColor(r: 241, g: 89, b: 39, alpha: 1)
            //f15927
    }
    
    static var redColor:UIColor {
        return UIColor(r: 234, g: 57, b: 57, alpha: 1)
    }
    
    
    static var secondOrangeColor:UIColor {
        return UIColor(r: 255, g: 148, b: 57, alpha: 1)
            //f15927
    }
    
        //MARK:- WHITE
    
    static var defaultWhiteTextColor:UIColor {
        return UIColor(r: 255, g: 255, b: 255, alpha: 1)
    }
    
    static var mildWhiteColor:UIColor {
        return UIColor(r: 252, g: 252, b: 252, alpha: 1)
    }
    
    static var mildWhiteColor2:UIColor {
        return UIColor(r: 240, g: 244, b: 255, alpha: 1)
    }
    
    static var mildWhiteColor3:UIColor {
        return UIColor(r: 249, g: 252, b: 255, alpha: 1)
    }
    
    static var mildWhiteColor4:UIColor {
        return UIColor(r: 249, g: 249, b: 252, alpha: 1)
    }
    
    
        //MARK:- DARK
    
    static var defaultDarkBgColor:UIColor {
        return UIColor(r: 27, g: 34, b: 54, alpha: 1)
            //1B2236
    }
    static var defaultDarkSelectedBgColor:UIColor {
        return UIColor(r: 37, g: 45, b: 68, alpha: 1)
            //1B2236
    }
    
    static var twilightColor:UIColor {
        return UIColor(r: 79, g: 96, b: 144, alpha: 1)
            //1B2236
    }
    
    static var defaultDarkBlueBgColor:UIColor {
        return UIColor(r: 34, g: 43, b: 68, alpha: 1)
            //1B2236
    }
    
    
        //MARK:- GREY
    
    static var defaultPaleGreyColor:UIColor {
        return UIColor(r: 243, g: 244, b: 248, alpha: 1)
            //f3f4f8
    }
    
    static var warmGreyColor:UIColor {
        return UIColor(r: 151, g: 151, b: 151, alpha: 0.10)
            //f3f4f8
    }
    
    
    static var greyishColor:UIColor{
        return UIColor(r: 168, g: 168, b: 168, alpha: 1)
            //6F6F6F
    }
    
    static var greyishColor2:UIColor{
        return UIColor(r: 226, g: 226, b: 226, alpha: 1)
    }
    
    static var greyishColor3:UIColor{
        return UIColor(r: 111, g: 111, b: 111, alpha: 1)
            //6F6F6F
    }
    
    static var greyishColor4:UIColor{
        return UIColor(r: 183, g: 183, b: 183, alpha: 1)
    }
    
    static var greyishColor5:UIColor{
        return UIColor(r: 216, g: 216, b: 216, alpha: 1)
    }
    
    static var greyishColor6:UIColor{
        return UIColor(r: 112, g: 111, b: 111, alpha: 1)
    }
    
    static var greyishColor7:UIColor{
        return UIColor(r: 221, g: 221, b: 221, alpha: 1)
    }
    
    static var greyishColor8:UIColor{
        return UIColor(r: 244, g: 246, b: 250, alpha: 1)
    }
    
    static var greyishColor9:UIColor{
        return UIColor(r: 245, g: 247, b: 254, alpha: 1)
    }
    
        //MARK:- BLACK
    static var defaultBlackColor:UIColor {
        return UIColor(r: 58, g: 58, b: 58, alpha: 1)
            //3a3a3a
    }
    
        //MARK:- BLUE
    
    static var defaultDuskColor:UIColor {
        return UIColor(r: 63, g: 74, b: 104, alpha: 1)
            //3f4a68
    }
    static var defaultCadetBlueColor:UIColor {
        return UIColor(r: 87, g: 107, b: 160, alpha: 1)
            //576ba0
    }
    
    static var defaultTextBlueColor:UIColor {
        return UIColor(r: 31, g: 38, b: 57, alpha: 1)
    }
    static var lavendarColor:UIColor {
        return UIColor(r: 219, g: 223, b: 248, alpha: 1)
            //576ba0
            //DBDFF8
    }
    
    static var veryLightBlue:UIColor{
        return UIColor(r: 213, g: 220, b: 238, alpha: 1)
            //D5DCEE
    }
    
    static var lightGreyish:UIColor{
        return UIColor(r: 187, g: 193, b: 207, alpha: 1)
    }
    
    static var lightGPeriwinkle:UIColor{
        return UIColor(r: 224, g: 231, b: 250, alpha: 1)
    }
    
    
    static var defaultTwilightBlue:UIColor{
        return UIColor(r: 76, g: 96, b: 144, alpha: 1)
    }
    
    static var defaultTwilightBlue2:UIColor{
        return UIColor(r: 79, g: 96, b: 144, alpha: 1)
    }
    
    static var cloudyBlue:UIColor{
        return UIColor(r: 187, g: 193, b: 207, alpha: 1)
    }
    
    static var textColor: UIColor {
        return UIColor(r: 7, g: 27, b: 60, alpha: 1)
    }
    
}

extension UIColor {
	convenience init(red: Int, green: Int, blue: Int) {
		assert(red >= 0 && red <= 255, "Invalid red component")
		assert(green >= 0 && green <= 255, "Invalid green component")
		assert(blue >= 0 && blue <= 255, "Invalid blue component")
		
		self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
	}
	
	convenience init(rgb: Int) {
		self.init(
			red: (rgb >> 16) & 0xFF,
			green: (rgb >> 8) & 0xFF,
			blue: rgb & 0xFF
		)
	}
}
