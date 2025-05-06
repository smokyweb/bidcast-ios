//
//  TextViewCell.swift
//  Last Minute Louie
//
//  Created by JAM-E-221 on 15/05/24.
//

import UIKit

class TextViewCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textViewOlt: UITextView!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var textViewheight: NSLayoutConstraint!
    
    //MARK: properties.
    static let identifier = "TextViewCell"
    var enterText : (UITextView) -> () = {_ in }
    var placeholderText = ""
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.outerView.makeCornerRounded(ofSize: Corner_12)
        self.textViewOlt.font = AppFont.placeHolder
        self.outerView.addBorders(of: AppColor.mediumLightGray ?? .systemGray3, width: Width_01)
        self.textViewOlt.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

//MARK: UITextViewDelegate.
extension TextViewCell : UITextViewDelegate{
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text != "Type here..." || textView.text != "" {
            self.enterText(textView)
        }
        if textView.text == "Type here..."{
            self.textViewOlt.text = ""
            self.textViewOlt.textColor = .black
        }
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text != "Type here..." || textView.text != "" {
            self.enterText(textView)
        }
        if textView.text == "Type here..."{
            self.textViewOlt.text = ""
            self.textViewOlt.textColor = .black
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Type here..."{
            self.textViewOlt.text = ""
        }
    }
}

