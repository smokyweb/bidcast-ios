//
//  TitleAndDescriptionCell.swift
//  Rise Shine Swing
//
//  Created by jam 1 TB on 08/01/25.
//

import UIKit

class TitleAndDescriptionCell: UITableViewCell {
    
    @IBOutlet var lblTitleOlt: UILabel!
    @IBOutlet var titleTxtFieldOlt: UITextField!
    @IBOutlet var textViewOlt: UITextView!
    @IBOutlet var descriptionOlt: UILabel!
    @IBOutlet var outerViewOlt: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    //MARK: Properties.
    static let identifier = "TitleAndDescriptionCell"
    var typing : (String) -> () = {_ in }
    var number = Int()
    var enterTitletext : (UITextField) -> () = {_ in  }
    var enterDesctext : (UITextView) -> () = {_ in }
    var placeholderText = "Type here..."
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    //MARK: setupUI.
    func setupUI(){
        self.titleTxtFieldOlt.delegate = self
        self.textViewOlt.delegate = self
        self.outerViewOlt.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
        lblTitleOlt.font = OutFitFont.defaultBold(size: 13.0).value
        titleTxtFieldOlt.font = JostFont.defaultRegular(size: 13.0).value
        descriptionOlt.font = OutFitFont.defaultBold(size: 13.0).value
        textViewOlt.font = JostFont.defaultRegular(size: 13.0).value
    }
}

//MARK: UITextFieldDelegate.
extension TitleAndDescriptionCell : UITextFieldDelegate{
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.enterTitletext(textField)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.number = number + 1
        self.typing(textField.text ?? "")
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.enterTitletext(textField)
        return true
    }
}


//MARK: UITextViewDelegate.
extension TitleAndDescriptionCell : UITextViewDelegate{
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text != placeholderText || textView.text != "" {
            self.enterDesctext(textView)
        }
        if textView.text == placeholderText{
            self.textViewOlt.text = ""
            self.textViewOlt.textColor = .black
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text != placeholderText || textView.text != "" {
            self.enterDesctext(textView)
        }
        if textView.text == placeholderText{
            self.textViewOlt.text = ""
            self.textViewOlt.textColor = .black
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholderText{
            self.textViewOlt.text = ""
        }
        
    }
}

