//
//  ViewCell.swift
//  Rise Shine Swing
//
//  Created by jam 1 TB on 10/12/24.
//

import UIKit
import OTPFieldView

class ViewCell: UITableViewCell {
    @IBOutlet var viewOtpOlt: OTPFieldView!
    
    //MARK: properties.
    static let identifier = "ViewCell"
    var enteredOTPClosure: (String) -> () = { _ in }

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        otpViewSetup()
    }
    
    //MARK: otpViewSetup.
    func otpViewSetup(){
        
        self.viewOtpOlt.fieldsCount = 4
        self.viewOtpOlt.fieldBorderWidth = 1
        self.viewOtpOlt.defaultBorderColor = AppColor.TextField.borderTextField ?? .darkGray
        self.viewOtpOlt.defaultBackgroundColor = UIColor(hex: "#EEF1F4") ?? .lightGray
        self.viewOtpOlt.cursorColor = UIColor.gray
//        self.viewOtpOlt.fieldSize = 56
        self.viewOtpOlt.separatorSpace = 40
        self.viewOtpOlt.shouldAllowIntermediateEditing = false
        self.viewOtpOlt.displayType = .roundedCorner
        self.viewOtpOlt.delegate = self
        self.viewOtpOlt.initializeUI()
        selectionStyle = .none
    }
}

//MARK: OTPFieldViewDelegate
extension ViewCell: OTPFieldViewDelegate {
    func hasEnteredAllOTP(hasEnteredAll hasEntered: Bool) -> Bool {
        debugLog("Has entered all OTP? \(hasEntered)")
        return false
    }
    
    func shouldBecomeFirstResponderForOTP(otpTextFieldIndex index: Int) -> Bool {
        return true
    }
    
    func enteredOTP(otp otpString: String) {
        debugLog("OTPString: \(otpString)")
        enteredOTPClosure(otpString)
    }
}
