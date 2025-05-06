//
//  DetailsTableViewCell.swift
//  BidCast
//
//  Created by JamTech on 13/12/24.
//

import UIKit

class DetailsTableViewCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var forwordBtn: UIButton!
    @IBOutlet weak var topLbl: UILabel!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var bottomLbl: UILabel!
    @IBOutlet weak var outerView: UIView!
    @IBOutlet weak var innerView: UIView!
    
    //MARK: Properties.
    static let identifier = "DetailsTableViewCell"
    var topLabelText = NSAttributedString()
    var bottomLabelText = NSAttributedString()
    var isProfileImageHidden = true
    var isImageCircular: Bool = true
    var profileBorderColor: UIColor = .black
    var forwardBtnTappedClosure : (UIButton) -> () = {_ in  }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        self.topLbl.attributedText = topLabelText
        self.bottomLbl.attributedText = bottomLabelText
        self.profileImgView.isHidden = isProfileImageHidden
        if isImageCircular {
            self.profileImgView.makeCircular()
        }
        else {
            self.profileImgView.makeCornerRounded(ofSize: Corner_08)
        }
        
        self.profileImgView.layer.borderWidth = 1.0
        self.profileImgView.layer.borderColor = profileBorderColor.cgColor
    }
    
    @IBAction func forwordBtnTappedAction(_ sender: UIButton) {
        self.forwardBtnTappedClosure(sender)
    }
}
