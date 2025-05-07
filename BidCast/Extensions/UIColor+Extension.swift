//
//  UIColor+Extension.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//
import Foundation
import UIKit

struct AppColor{
    
    static let primary = UIColor(named: "primary") ?? UIColor(hex: "#2B537F") //#2B537F
    static let secondary = UIColor(named: "secondary") ?? UIColor(hex: "#689CFF") //#689CFF
    static let black = UIColor(named: "black") ?? UIColor(hex: "#000000") //#000000
    static let white = UIColor(named: "white") ?? UIColor(hex: "#FFFFFF") //#FFFFFF
    static let ultraLightGray = UIColor(named: "ultraLightGray") ?? UIColor(hex: "#F5F8FC") //#F5F8FC
    static let lightGray = UIColor(named: "lightGray") ?? UIColor(hex: "#F3F4F6") //#EBF1F9
    static let mediumLightGray = UIColor(named: "mediumLightGray") ?? UIColor(hex: "#C1C9D6") //#C1C9D6
    static let mediumGray = UIColor(named: "mediumGray") ?? UIColor(hex: "#D9D9D9") //#747D8B
    static let mediumDarkGray = UIColor(named: "mediumDarkGray") ?? UIColor(hex: "#505761") //#505761
    static let darkGray = UIColor(named: "darkGray") ?? UIColor(hex: "#2D3035") //#2D3035
    static let success = UIColor(named: "success") ?? UIColor(hex: "#13B761") //#13B761
    static let warning = UIColor(named: "warning") ?? UIColor(hex: "#ED852F") //#ED852F
    static let danger = UIColor(named: "danger") ?? UIColor(hex: "#D62B4D") //#D62B4D
    static let lightBlue = UIColor(named: "lightBlue") ?? UIColor(hex: "#F1F6FF") //#F1F6FF
    static let clear = UIColor(named: "clear") ?? UIColor(hex: "#FFFFFF") //#FFFFFF
    static let bgColor = UIColor(named: "bgColor") ?? UIColor(hex: "#E5E7EB") //#E5E7EB
    

    
    //NEW
    struct Label{
         static let beige = UIColor(named: "beige") ?? UIColor(hex: "#FCDFDF") //#FCDFDF
         static let red = UIColor(named: "beige") ?? UIColor(hex: "#F21617") //#F21617
        static let brown = UIColor(named: "brown") ?? UIColor(hex: "#475569") //#475569
        
        
        static let darkGray = UIColor(named: "darkGray") ?? UIColor(hex: "#797A7B") //#797A7B
        static let dangerRed = Common.dangerRed
        static let lightBlack = UIColor(named: "lightBlack") ?? UIColor(hex: "#2D3035") //#2D3035
        static let slategray = UIColor(named: "slategray") ?? UIColor(hex: "#6B737F") //#6B737F
        static let Black = UIColor(named: "Black") ?? UIColor(hex: "#101C23") //#101C23
        static let SquirrelGrey = UIColor(named: "SquirrelGrey") ?? UIColor(hex: "#747D8B") //#747D8B
        static let seprator = UIColor(named: "seprator") ?? UIColor(hex: "#727D90") //#727D90
        
        
        
        
    }
    //MARK: TextField Color.
    struct TextField{
        static let textFieldBg = UIColor(named: "textFieldBg")  ?? UIColor(hex: "#EDEFF4") //#EDEFF4
            static let textFieldBorder = UIColor(named: "textFieldBg")  ?? UIColor(hex: "#CBD0DB") //#CBD0DB
        
        
        
        static let borderTextField = UIColor(named: "borderColor")  ?? UIColor(hex: "#9B9EA2") //#9B9EA2
        static let placeholderTextField = UIColor(named: "placeHolder")  ?? UIColor(hex: "#E1E2E3") //#E1E2E3
        static let bgTextField = UIColor(named: "bgColor")  ?? UIColor(hex: "#F7F8FC") //#F7F8FC
        static let bgBeige =  View.bgBeige
    }
    
    //MARK: Button Color.
    struct Button{
        static let lightBlue = UIColor(named: "lightBlue")  ?? UIColor(hex: "#296DFF") // #296DFF
           static let darkGray = UIColor(named: "darkGray")  ?? UIColor(hex: "#475569") // #475569
           static let green = UIColor(named: "green")  ?? UIColor(hex: "#04D98B") // #04D98B
           static let purple = UIColor(named: "purple")  ?? UIColor(hex: "#7719EF") // #7719EF
        

    }
    
    
    struct Segment{
        static let whiteFrost = UIColor(named: "whiteFrost")  ?? UIColor(hex: "#E3E6EB") // #959596
    }
    
    //MARK: Commomn Color Used in Multiple Location.
//    static let primary = UIColor(named: "primary") ?? UIColor(hex: "#00BD19") //#00BD19
//    static let black = UIColor(named: "black") ?? UIColor(hex: "#000000") //#000000
    static let mediumDark = UIColor(named: "mediumDark") ?? UIColor(hex: "#505761") //#505761
    static let medium = UIColor(named: "medium") ?? UIColor(hex: "#747D8B") //#747D8B
    static let mediumLight = UIColor(named: "mediumLight") ?? UIColor(hex: "#C8CFDB") //#C8CFDB
    static let light = UIColor(named: "light") ?? UIColor(hex: "#EEF1F7") //#EEF1F7
    static let ultraLight = UIColor(named: "ultraLight") ?? UIColor(hex: "#F7F8FB") //#F7F8FB
    static let dangerRed = UIColor(named: "dangerRed") ?? UIColor(hex: "#EB3B5A") //#EB3B5A
    static let warningOrange = UIColor(named: "warningOrange") ?? UIColor(hex: "#F97F2D") //#F97F2D
    static let successGreen = UIColor(named: "successGreen") ?? UIColor(hex: "#1DBC64") //#1DBC64
    static let yellow = UIColor(named: "yellow") ?? UIColor(hex: "#F4AC2C") //#F4AC2C
    static let turquoise = UIColor(named: "turquoise") ?? UIColor(hex: "#0DB7AA") //#0DB7AA
//    static let lightBlue = UIColor(named: "lightBlue") ?? UIColor(hex: "#259DD8") //#259DD8
    static let blue = UIColor(named: "blue") ?? UIColor(hex: "#2F6DD1") //#2F6DD1
    static let purple = UIColor(named: "purple") ?? UIColor(hex: "#8854D0") //#8854D0
    static let pink = UIColor(named: "pink") ?? UIColor(hex: "#ED45B1") //#ED45B1
    static let kellyGreen = UIColor(named: "kellyGreen") ?? UIColor(hex: "#2F763C") //#2F763C
    static let pearl = UIColor(named: "pearl") ?? UIColor(hex: "#2F763C") //#2F763C
    static let ghostWhite = UIColor(named: "ghostWhite") ?? UIColor(hex: "#F7F8FC") //#F7F8FC
    
    
    //OLD
    struct Common{
        static let Theam = UIColor(named: "theamColor") ?? UIColor(hex: "#F48B18") //#F5F6FA
        static let lightBeige = UIColor(named: "lightBeige") ?? UIColor(hex: "#F0F0F0") //#F0F0F0
        static let lightMist = UIColor(named: "lightMist")  ?? UIColor(hex: "#F7F8FB") //#F7F8FB
        static let lightBlue = UIColor(named: "white") ?? UIColor(hex: "#ECF0F9") //#ECF0F9
        static let darkBlue =  UIColor(named: "darkBlue") ?? UIColor(hex: "#263642") //#263642
        static let dangerRed = UIColor(named: "dangerRed") ?? UIColor(hex: "#EB3B5A") //#EB3B5A
        

    }
    
    //MARK: View Color.
    struct View{
        static let violet = UIColor(named: "violet")  ?? UIColor(hex: "#727D91") // #727D91
        static let pearl = UIColor(named: "pearl")  ?? UIColor(hex: "#EDEFF4") // #EDEFF4
        
        
        
//        static let bgLightGray = Common.lightGray
        static let bgLighBeige = Common.lightBeige
        static let bgLightMist = Common.lightMist
        static let lightBlue = Common.lightBlue
        static let bgFaintWhite = UIColor(named: "faintWhite") ?? UIColor(hex: "#F0F1F2") //#F0F1F2
        static let bgBeige =  UIColor(named: "beige") ?? UIColor(hex: "#E8E9EF") //#E8E9EF
        static let bgViolet =  UIColor(named: "bgViolet") ?? UIColor(hex: "#ECEEF1") //##ECEEF1
    }
    
    //MARK: Image Color.
    struct Image{
        static let darkGreen = UIColor(named: "darkGreen")  ?? UIColor(hex: "#649433") //#649433
    }
    
    
    //Used in Multiple Location.
    //    struct Common{
    //        static let lightGray = UIColor(r: 245, g: 246, b: 250, alpha: 1)
    //        static let lightBeige = UIColor(r: 240, g: 240, b: 240, alpha: 1)
    //        static let lightMist = UIColor(red: 247, green: 248, blue: 251)
    //    }
    //    struct TextField{
    //        static let bgWhite = UIColor(r: 236, g: 240, b: 249, alpha: 1)
    //        static let bgLightBeige = Common.lightBeige
    //    }
    //    struct Button{
    //        static let bgOrange = UIColor(r: 246, g: 155, b: 49, alpha: 1)
    //    }
    //    struct View{
    //        static let bgLightGray = Common.lightGray
    //        static let bgGray = Common.lightBeige
    //        static let bgLightMist = Common.lightMist
    //        static let bgFaintWhite = UIColor(red: 240, green: 241, blue: 242)
    //        static let bgBeige =  UIColor(red: 232, green: 233, blue: 239)
//            static let bgViolet = UIColor(red: 236, green: 238, blue: 241)
    //    }
    //    struct Segment{
    //        static let bgLightGray =  Common.lightGray
    //        static let borderLightGray =  Common.lightGray
    //    }
    //    struct Label{
    //        static let lightGreen = UIColor(r: 118, g: 162, b: 66, alpha: 1)
    //        static let darkBlue =  UIColor(r: 38, g: 54, b: 66, alpha: 1)
    //    }
    //    struct Image{
    //        static let darkGreen = UIColor(r: 100, g: 148, b: 51, alpha: 1)
    //    }
    //}
}
    
//Extension UIColor used For Convert Hex To Color.
extension UIColor {
    convenience init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb >> 16) & 0xFF) / 255.0
        let green = CGFloat((rgb >> 8) & 0xFF) / 255.0
        let blue = CGFloat(rgb & 0xFF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
    
    
    
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
    
    
