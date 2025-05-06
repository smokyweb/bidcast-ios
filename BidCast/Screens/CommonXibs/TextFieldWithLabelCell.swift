//
//  TextFieldWithLabelCell.swift
//  Last Minute Louie
//
//  Created by JAM-E-221 on 13/05/24.
//

import UIKit

class TextFieldWithLabelCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var imgLeadingOlt: NSLayoutConstraint!
    @IBOutlet weak var seperatorWidthOlt: NSLayoutConstraint!
    @IBOutlet weak var seperatorView: UIView!
    @IBOutlet weak var editPasswordOlt: UILabel!
    @IBOutlet weak var textFieldOuterView: UIView!
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var vectorImageolt: UIImageView!
    @IBOutlet weak var eyeBtnOlt: UIButton!
    @IBOutlet weak var textFieldOlt: UITextField!
    @IBOutlet weak var imgWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailStackOlt: UIStackView!
    
    
    //MARK: Properties.
    static let identifier = "TextFieldWithLabelCell"
    var typing : (String) -> () = {_ in }
    var number = Int()
    var entertext : (UITextField) -> () = {_ in  }
    var iconClick = false
    var isFor = ""
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.textFieldOlt.delegate = self
        self.titleOlt.font = AppFont.Labeltitle
        self.textFieldOlt.font = JostFont.defaultRegular(size: 13).value
        self.textFieldOuterView.makeCornerRounded(ofSize: Corner_12)
        self.textFieldOuterView.addBorders(of: AppColor.TextField.borderTextField ?? .systemGray3, width: Width_01)
        self.emailStackOlt.isHidden = false
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: IBActions.
    @IBAction func didTapEyeBtnOlt(_ sender: Any) {
        
        if(iconClick == true) {
            self.eyeBtnOlt.setImage(UIImage(named: "ic_eyeOff"), for: .normal)
            //            eyeBtnOlt.tintColor = UIColor(r: 114, g: 176, b: 156, alpha: 1)
            textFieldOlt.isSecureTextEntry = true
        }else{
            textFieldOlt.isSecureTextEntry = false
            self.eyeBtnOlt.setImage(UIImage(named: "eye"), for: .normal)
            //            eyeBtnOlt.tintColor = UIColor(r: 114, g: 176, b: 156, alpha: 1)
        }
        iconClick = !iconClick
    }
}

//MARK: UITextFieldDelegate.
extension TextFieldWithLabelCell : UITextFieldDelegate{
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
