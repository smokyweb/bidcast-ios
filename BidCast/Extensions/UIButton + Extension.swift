//
//  UIButton + Extension.swift
//  BidCast
//
//  Created by JAM-E-174 on 07/10/24.
//

import Foundation
import UIKit


extension UIButton {
    func setupButton(
        title: String? = nil,
        titleColor: UIColor? = nil,
        backgroundColor: UIColor? = nil,
        borderWidth: CGFloat? = nil,
        borderColor: UIColor? = nil,
        image: UIImage? = nil,
        imageRenderColor: UIColor? = nil,  // Add the imageRenderColor parameter
        for state: UIControl.State = .normal
    ) {
        // Set title
        if let title = title {
            self.setTitle(title, for: state)
        }
        
        // Set title color
        if let titleColor = titleColor {
            self.setTitleColor(titleColor, for: state)
        }
        
        // Set background color
        if let backgroundColor = backgroundColor {
            self.backgroundColor = backgroundColor
        }
        
        // Set border width and border color
        if let borderWidth = borderWidth {
            self.layer.borderWidth = borderWidth
            
            if let borderColor = borderColor {
                self.layer.borderColor = borderColor.cgColor
            } else {
                // If no border color is provided, set to clear
                self.layer.borderColor = UIColor.clear.cgColor
            }
        }
        
        // Set image
        if let image = image {
            self.setImage(image, for: state)
            
            // Apply render color to the image if provided
            if let renderColor = imageRenderColor {
                self.imageView?.tintColor = renderColor
                self.setImage(image.withRenderingMode(.alwaysTemplate), for: state)  // Render the image with the template mode
            }
        }
    }
}

