//  BidCast
//
//  Created by Abdul-JAM-E-157 on 31/08/24.

import Foundation
import UIKit

extension UITextField{
    func addPlaceHolder(color:UIColor,placeholderText:String,font:UIFont){
        self.attributedPlaceholder = NSAttributedString(string: placeholderText,
                                                        attributes: [NSAttributedString.Key.foregroundColor: color,.font: font])
    }
    
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    
    func setRightPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        
        self.rightView = paddingView
        self.rightViewMode = .always
    }
}

extension UITextView{
    
    
}
