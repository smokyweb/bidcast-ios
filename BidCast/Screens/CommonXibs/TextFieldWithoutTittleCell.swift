//
//  TextFieldWithoutTittleCell.swift
//  BidCast
//
//  Created by JAM_328 on 10/12/24.
//

import UIKit

class TextFieldWithoutTittleCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet var textFieldOuterView: UIView!
    @IBOutlet weak var eyeBtnOlt: UIButton!
    @IBOutlet var textFieldOlt: UITextField!
    
    //MARK: Properties.
    static let identifier = "TextFieldWithoutTittleCell"
    var typing : (String) -> () = {_ in }
    var number = Int()
    var entertext : (UITextField) -> () = {_ in  }
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
        self.textFieldOuterView.makeCornerRounded(ofSize: Corner_05)
        self.textFieldOuterView.addBorders(of: AppColor.TextField.placeholderTextField ?? .systemGray3, width: Width_01)
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
            self.eyeBtnOlt.setImage(UIImage(systemName: "eye.slash"), for: .normal)
            textFieldOlt.isSecureTextEntry = true
        }else{
            textFieldOlt.isSecureTextEntry = false
            self.eyeBtnOlt.setImage(UIImage(systemName: "eye"), for: .normal)
        }
        iconClick = !iconClick
    }
}

//MARK: UITextFieldDelegate.
extension TextFieldWithoutTittleCell : UITextFieldDelegate{
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.entertext(textField)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.number = number + 1
        self.typing(textField.text ?? "")
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.entertext(textField)
        return true
    }
}
