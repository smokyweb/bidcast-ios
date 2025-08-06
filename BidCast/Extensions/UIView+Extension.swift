//
//  UIView+Extension.swift
//  MentorPOS
//
//  Created by Trend Setterz on 3/5/20.
//  Copyright © 2020 admin. All rights reserved.
//

import Foundation
import UIKit

public let kShapeDashed : String = "kShapeDashed"

extension UIView{
    
    func makeCornerRounded(ofSize:CGFloat){
        self.layer.cornerRadius = ofSize
        self.clipsToBounds = true
    }
    
    func addBorders(of color:UIColor,width: CGFloat){
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    
    func dropShadow(opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat,shadowColor:UIColor) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius
        layer.cornerRadius = cornerRadius
    }
    
    func dropShadowForSide(opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat,shadowColor:UIColor) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    
//    func addLine(position : LINE_POSITION, color: UIColor, width: Double) {
//        let lineView = UIView()
//        lineView.backgroundColor = color
//        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
//        self.addSubview(lineView)
//        
//        let metrics = ["width" : NSNumber(value: width)]
//        let views = ["lineView" : lineView]
//        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
//        
//        switch position {
//        case .LINE_POSITION_TOP:
//            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
//            break
//        case .LINE_POSITION_BOTTOM:
//            self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutConstraint.FormatOptions(rawValue: 0), metrics:metrics, views:views))
//            break
//        }
//    }
//    
    
    
    func removeDashedBorder(_ view: UIView) {
        view.layer.sublayers?.forEach {
            if kShapeDashed == $0.name {
                $0.removeFromSuperlayer()
            }
        }
    }
    
    
    func addDashedBorder(width: CGFloat? = nil, height: CGFloat? = nil, lineWidth: CGFloat = 2, lineDashPattern:[NSNumber]? = [6,3], strokeColor: UIColor = UIColor.defaultTheme, fillColor: UIColor = UIColor.clear) {
        
        
        var fWidth: CGFloat? = width
        var fHeight: CGFloat? = height
        
        if fWidth == nil {
            fWidth = self.frame.width
        }
        
        if fHeight == nil {
            fHeight = self.frame.height
        }
        
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        
        let shapeRect = CGRect(x: 0, y: 0, width: fWidth!, height: fHeight!)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: fWidth!/2, y: fHeight!/2)
        shapeLayer.fillColor = fillColor.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = lineDashPattern
        shapeLayer.name = kShapeDashed
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 0).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
    
    func addTopBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        border.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }

    func addBottomBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        border.frame = CGRect(x: 0, y: frame.size.height - borderWidth, width: frame.size.width, height: borderWidth)
        addSubview(border)
    }

    func addLeftBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.frame = CGRect(x: 0, y: 0, width: borderWidth, height: frame.size.height)
        border.autoresizingMask = [.flexibleHeight, .flexibleRightMargin]
        addSubview(border)
    }

    func addRightBorder(with color: UIColor?, andWidth borderWidth: CGFloat) {
        let border = UIView()
        border.backgroundColor = color
        border.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin]
        border.frame = CGRect(x: frame.size.width - borderWidth, y: 0, width: borderWidth, height: frame.size.height)
        addSubview(border)
    }
}



extension UIApplication {
    
//    class func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
//
//        if let nav = viewController as? UINavigationController
//        {
//            return topViewController(nav.visibleViewController)
//        }
//
//        if let tab = viewController as? UITabBarController {
//            if let selected = tab.selectedViewController
//            {
//                return topViewController(selected)
//            }
//        }
//
//        if let presented = viewController?.presentedViewController
//        {
//            return topViewController(presented)
//        }
//
//        return viewController
//    }
	
}
//
//extension UIView {
//    
//    //Setting Corner Radius
//    
//    @IBInspectable
//    var cornerRadius : CGFloat {
//        
//        get{
//          return self.layer.cornerRadius
//        }
//        
//        set(newValue) {
//            self.layer.cornerRadius = newValue
//        }
//        
//    }
//    
//    
//    //MARK:- Setting bottom Line
//    
//    @IBInspectable
//    var borderLineWidth : CGFloat {
//        get {
//            return self.layer.borderWidth
//        }
//        set(newValue) {
//            self.layer.borderWidth = newValue
//        }
//    }
//    
//    
//    //MARK:- Setting border color
//    
//    @IBInspectable
//    var borderColor : UIColor {
//        
//        get {
//            
//            return UIColor(cgColor: self.layer.borderColor ?? UIColor.clear.cgColor)
//        }
//        set(newValue) {
//            self.layer.borderColor = newValue.cgColor
//        }
//        
//    }
//    
//    
//    //MARK:- Shadow Offset
//    
//    @IBInspectable
//    var offsetShadow : CGSize {
//        
//        get {
//           return self.layer.shadowOffset
//        }
//        set(newValue) {
//            self.layer.shadowOffset = newValue
//        }
//        
//        
//    }
//    
//    
//    //MARK:- Shadow Opacity
//    @IBInspectable
//    var opacityShadow : Float {
//        
//        get{
//            return self.layer.shadowOpacity
//        }
//        set(newValue) {
//            self.layer.shadowOpacity = newValue
//        }
//        
//    }
//    
//    //MARK:- Shadow Color
//    @IBInspectable
//    var colorShadow : UIColor? {
//        
//        get{
//           return UIColor(cgColor: self.layer.shadowColor ?? UIColor.clear.cgColor)
//        }
//        set(newValue) {
//            self.layer.shadowColor = newValue?.cgColor
//        }
//    }
//    
//    //MARK:- Shadow Radius
//    @IBInspectable
//    var radiusShadow : CGFloat {
//        get {
//             return self.layer.shadowRadius
//        }
//        set(newValue) {
//            
//           self.layer.shadowRadius = newValue
//        }
//    }
//    
//    //MARK:- Mask To Bounds
//    
//    @IBInspectable
//    var maskToBounds : Bool {
//        get {
//            return self.layer.masksToBounds
//        }
//        set(newValue) {
//            
//            self.layer.masksToBounds = newValue
//        }
//    }
//    
//    //MARK:- Make View Round
//    
//    func makeRoundedCorner(){
//        self.layer.masksToBounds = true
//        self.layer.cornerRadius = self.bounds.width/2
//    }
//   
//
//}
//
//
//
//extension UIButton {
//    
//    @IBInspectable
//    var cornerRadiusBtn : CGFloat {
//        
//        get{
//          return self.layer.cornerRadius
//        }
//        
//        set(newValue) {
//            self.layer.cornerRadius = newValue
//        }
//        
//    }
//    
//    //MARK:- Setting bottom Line
//    @IBInspectable
//    var borderLineWidthBtn : CGFloat {
//        get {
//            return self.layer.borderWidth
//        }
//        set(newValue) {
//            self.layer.borderWidth = newValue
//        }
//    }
//    
//    
//    //MARK:- Setting border color
//    
//    @IBInspectable
//    var borderColorBtn : UIColor {
//        
//        get {
//            
//            return UIColor(cgColor: self.layer.borderColor ?? UIColor.clear.cgColor)
//        }
//        set(newValue) {
//            self.layer.borderColor = newValue.cgColor
//        }
//        
//    }
//}
//
//
//
//extension UITextField {
//    
//    @IBInspectable
//    var cornerRadiusTF : CGFloat {
//        
//        get{
//          return self.layer.cornerRadius
//        }
//        
//        set(newValue) {
//            self.layer.cornerRadius = newValue
//        }
//        
//    }
//    
//    //MARK:- Setting bottom Line
//    @IBInspectable
//    var borderLineWidthTF : CGFloat {
//        get {
//            return self.layer.borderWidth
//        }
//        set(newValue) {
//            self.layer.borderWidth = newValue
//        }
//    }
//    
//    
//    //MARK:- Setting border color
//    
//    @IBInspectable
//    var borderColorTF : UIColor {
//        
//        get {
//            
//            return UIColor(cgColor: self.layer.borderColor ?? UIColor.clear.cgColor)
//        }
//        set(newValue) {
//            self.layer.borderColor = newValue.cgColor
//        }
//        
//    }
//}

extension UIViewController {
    var topMostViewController: UIViewController {
        if let presentedVC = self.presentedViewController {
            return presentedVC.topMostViewController
        }
        if let nav = self as? UINavigationController {
            return nav.visibleViewController?.topMostViewController ?? nav
        }
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }
        return self
    }
}

