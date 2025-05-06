//  Rise Shine Swing
//
//  Created by Abdul-JAM-E-157 on 31/08/24.

import Foundation
import UIKit

extension UIView{
    
    func makeCornerRounded(ofSize:CGFloat){
        self.layer.cornerRadius = ofSize
        self.clipsToBounds = true
    }
    
    func makeCircular() {
        self.layer.cornerRadius = (self.frame.size.width) / 2
        self.clipsToBounds = true
    }

    func addTopCorner(to view: UIView, cornerRadius: CGFloat) {
        view.layer.cornerRadius = cornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]  // Top corners
        view.clipsToBounds = true  // Ensure that the content is clipped to the rounded corners
    }

    func addBottomCorner(to view: UIView, cornerRadius: CGFloat) {
        view.layer.cornerRadius = cornerRadius
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        view.clipsToBounds = true  // Ensure that the content is clipped to the rounded corners
    }
//    func addBottomCorner(to view : UIView){
//        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//    }
    func addBottomLeftCorner(to view : UIView, radius: CGFloat){
        view.layer.cornerRadius = radius
        view.layer.maskedCorners = [.layerMinXMaxYCorner]
    }

    func addTopLeftAndBottomLeftCorner(to view: UIView, radius: CGFloat) {
        // Apply corner radius to the top-left and bottom-left corners
        view.layer.cornerRadius = radius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]  // Top-left and Bottom-left corners
    }
    
    enum ShadowSide {
        case top
        case bottom
        case left
        case right
    }

    func applySideShadow(to view: UIView, opacity: Float, shadowRadius: CGFloat, shadowColor: UIColor, cornerRadius: CGFloat, sides: [ShadowSide]) {
        // Reset shadow properties first (so they don't accumulate from previous shadows)
        view.layer.shadowOpacity = opacity
        view.layer.shadowRadius = shadowRadius
        view.layer.shadowColor = shadowColor.cgColor
        view.layer.masksToBounds = false  // Ensure the shadow isn't clipped by the rounded corners
        view.layer.cornerRadius = cornerRadius  // Apply corner radius to view

        // Set shadow offset based on which sides are selected
        var shadowOffset = CGSize(width: 0, height: 0)  // Default no offset

        // Apply shadow offset for each side as required
        if sides.contains(.top) {
            shadowOffset = CGSize(width: 0, height: -2)  // Shadow offset for the top
        }
        if sides.contains(.bottom) {
            shadowOffset = CGSize(width: 0, height: 2)  // Shadow offset for the bottom
        }
        if sides.contains(.left) {
            shadowOffset = CGSize(width: -2, height: 0)  // Shadow offset for the left
        }
        if sides.contains(.right) {
            shadowOffset = CGSize(width: 2, height: 0)  // Shadow offset for the right
        }

        // Apply the shadow offset
        view.layer.shadowOffset = shadowOffset
    }



    
    func addDottedBorder(to view: UIView) {
       // Remove any existing dotted border before adding a new one
       view.layer.sublayers?.removeAll { $0 is CAShapeLayer }
       
       let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = AppColor.Label.SquirrelGrey?.cgColor
       shapeLayer.fillColor = nil // Don't fill the inside of the shape
       shapeLayer.lineDashPattern = [6, 3] // The pattern for the dots (6pt of line, 3pt gap)
       shapeLayer.lineWidth = 1 // Set the width of the border
       shapeLayer.frame = view.bounds
       shapeLayer.path = UIBezierPath(rect: view.bounds).cgPath
       
       view.layer.addSublayer(shapeLayer)
   }
    
    func addBorders(of color:UIColor,width: CGFloat){
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }
    func addDottedBorder(borderColor: UIColor = .black, borderWidth: CGFloat = 2.0, pattern: [NSNumber] = [6, 3]) {
            // Remove existing border if any
            self.layer.sublayers?.forEach { layer in
                if let shapeLayer = layer as? CAShapeLayer {
                    shapeLayer.removeFromSuperlayer()
                }
            }

            // Create a new CAShapeLayer
            let shapeLayer = CAShapeLayer()
            shapeLayer.strokeColor = borderColor.cgColor
            shapeLayer.lineWidth = borderWidth
            shapeLayer.lineDashPattern = pattern
            shapeLayer.fillColor = nil

            // Create a path for the border
            let path = UIBezierPath(rect: self.bounds)
            shapeLayer.path = path.cgPath

            // Add the shape layer to the view's layer
            self.layer.addSublayer(shapeLayer)
        }
    
    func dropShadow(opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat,shadowColor:UIColor) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius
        layer.cornerRadius = cornerRadius
    }
        
        // Function to add shadow on Top, Left, and Right
    func dropShadowTopLeftRight(opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat, shadowColor: UIColor) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = shadowRadius
        layer.cornerRadius = cornerRadius
        
        // Apply shadow offset for Top, Left, and Right
        layer.shadowOffset = CGSize(width: 0, height: -shadowRadius)  // Shadow will appear at top
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
        
        // Function to add shadow on Bottom, Left, and Right
    func dropShadowBottomLeftRight(opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat, shadowColor: UIColor) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = shadowRadius
        layer.cornerRadius = cornerRadius
        
        // Apply shadow offset for Bottom, Left, and Right
        layer.shadowOffset = CGSize(width: 0, height: shadowRadius)  // Shadow will appear at bottom
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
        
        // Function to add shadow on Left and Right
    func dropShadowLeftAndRight(opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat, shadowColor: UIColor) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = shadowRadius
        layer.cornerRadius = cornerRadius
        
        // Apply shadow offset for Left and Right
        layer.shadowOffset = CGSize(width: shadowRadius, height: 0)  // Shadow will appear at left and right
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }



    func dropShadowForSide(opacity: Float, shadowRadius: CGFloat, cornerRadius: CGFloat,shadowColor:UIColor) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = shadowRadius
        layer.cornerRadius = cornerRadius
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }
    func roundCorners(_ corner: UIRectCorner,_ radii: CGFloat) {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = self.layer.bounds
        maskLayer.path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corner, cornerRadii: CGSize(width: radii, height: radii)).cgPath
      
        self.layer.mask = maskLayer
        layer.masksToBounds = true
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
    
    func section(width: CGFloat? = nil, height: CGFloat? = nil, lineWidth: CGFloat = 2, lineDashPattern:[NSNumber]? = [6,3], strokeColor: UIColor = UIColor.red, fillColor: UIColor = UIColor.clear) {
        
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

extension UIView {
    /// Adds a dashed border to the view.
    /// - Parameters:
    ///   - color: The color of the dashed border. Default is black.
    ///   - lineWidth: The width of the border lines. Default is 1.
    ///   - dashPattern: The dash pattern as an array of NSNumber. Default is `[4, 2]`.
    ///   - cornerRadius: The corner radius of the border. Default is 0.
    func addDashedBorder() {
        let color = UIColor.gray.cgColor
        let shapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 2
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [5, 5]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 5).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}
//MARK: UIView.
extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while let responder = parentResponder {
            parentResponder = responder.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
