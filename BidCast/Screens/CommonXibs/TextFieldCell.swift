//
//  TextFieldCell.swift
//  BidCast
//
//  Created by JAM_328 on 10/12/24.
//

import UIKit

class TextFieldCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet var forgotPassword: UIButton!
    @IBOutlet var textFieldOuterView: UIView!
    @IBOutlet weak var eyeBtnOlt: UIButton!
    @IBOutlet var textFieldOlt: UITextField!
    @IBOutlet weak var titleLblOlt: UILabel!    
    @IBOutlet weak var imgIconOlt: UIImageView!
    @IBOutlet weak var imgWidht: NSLayoutConstraint!
    var isComeFrom : String = ""
    
    //MARK: Properties.
    static let identifier = "TextFieldCell"
    var typing : (String) -> () = {_ in }
    var number = Int()
    var entertext : (UITextField) -> () = {_ in  }
    var didTapForgotPassClosure : (UIButton) -> () = {_ in}
    var iconClick = false
    var isFor = ""
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: setupUI
    func setupUI(){
        selectionStyle = .none
        self.textFieldOlt.delegate = self
        self.titleLblOlt.font = OutFitFont.defaultBold(size: 13.0).value
        self.textFieldOlt.font = JostFont.defaultRegular(size: 15).value
        self.titleLblOlt.font = AppFont.Labeltitle
        self.eyeBtnOlt.setImage(UIImage(named: "ic_eyeOff"), for: .normal)
        self.textFieldOuterView.makeCornerRounded(ofSize: Corner_08)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textFieldOlt.text = " "
            self.textFieldOlt.text = ""
        }
        self.textFieldOuterView.addBorders(of: AppColor.mediumLightGray ?? .systemGray3, width: Width_01)
    }
    
    //MARK: setupTextField
    func setupTextField(placeHolder: String,
                        keyboardType: UIKeyboardType? = .default, // Default to .default if not provided
                        isEyeHidden: Bool = false,
                        isSecureTextEntry: Bool? = nil) {
        // Set the visibility of the eye button (for showing/hiding the password)
        eyeBtnOlt.isHidden = isEyeHidden
        
        // Set the placeholder text for the text field
        textFieldOlt.placeholder = placeHolder
        
        // Set the keyboard type for the text field (default to .default if not provided)
        textFieldOlt.keyboardType = keyboardType ?? .default
        
        // Set the secureTextEntry for the text field
        if let isSecureText = isSecureTextEntry {
            textFieldOlt.isSecureTextEntry = isSecureText
        } else {
            textFieldOlt.isSecureTextEntry = false // Default behavior
        }
    }
    
    //MARK: didTapEyeBtnOlt.
    @IBAction func didTapEyeBtnOlt(_ sender: Any) {
        if(iconClick == true) {
            self.eyeBtnOlt.setImage(UIImage(named: "ic_eyeOff"), for: .normal)
            textFieldOlt.isSecureTextEntry = true
        }else{
            textFieldOlt.isSecureTextEntry = false
            self.eyeBtnOlt.setImage(UIImage(named: "ic_eye"), for: .normal)
        }
        iconClick = !iconClick
    }
    
    @IBAction func btnTapped(_ sender: UIButton) {
        self.didTapForgotPassClosure(sender)
    }
}

//MARK: UITextFieldDelegate.
extension TextFieldCell : UITextFieldDelegate{
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.entertext(textField)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.number = number + 1
        self.typing(textField.text ?? "")
        return true
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
////        let uppercasedString = string.uppercased()
////        textField.text = (textField.text ?? "") + uppercasedString
//        self.entertext(textField)
////        self.textFieldOlt.text = textField.text?.capitalized
//        return true
//    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // Define maximum lengths
        let maxLengths: [String: [Int]] = [
            "ZipCode": [4, 6]
        ]
        
        // Determine the current context/type from `isComeFrom`
        guard let validLengths = maxLengths[isComeFrom] else {
            self.entertext(textField) // Call your custom function if the type is unknown
            return true
        }
        
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        let updatedLength = updatedText.count

        for maxLength in validLengths {
            if updatedLength <= maxLength {
                return true
            }
        }
        
        return false
    }
}
