//
//  HomeHeaderTableViewCell.swift
//  Well Genius App
//
//  Created by Vivek-JAM-E-328 on 12/12/24.
//

import UIKit

class HomeHeaderTableViewCell: UITableViewCell {
    
    //MARK: IBOutlets
    
    @IBOutlet weak var backBtnOlt: UIButton!
    @IBOutlet weak var userImgOlt: UIImageView!
    @IBOutlet weak var rightNotificationBtnOlt: UIButton!
    @IBOutlet weak var rightEditBtnOlt: UIButton!
    @IBOutlet weak var midLblOlt: UILabel!
    @IBOutlet weak var userNameOlt: UILabel!
    @IBOutlet weak var userDateStack: UIStackView!
    
    
    //MARK: Properties.
    static let identifier = "HomeHeaderTableViewCell"
    var backButtonPressed: () -> () = {}
    var navRightNotiButtonPressed : () -> () = {}
    var navRightEditButtonPressed : () -> () = {}
    var privateButtonPressed : () -> () = {}
    var midLblText = ""
    var userNameTxt = ""
    
    var isHidefirstRightBtn: Bool = true
    var profileImage: UIImage? = UIImage(named: "image1")
    var backBtnImage: UIImage? = UIImage(named: "search")
    var userDateIsHidden = false
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.midLblOlt.font = LatoFont.defaultBold(size: 14).value
        self.userNameOlt.font = LatoFont.defaultBold(size: 22).value

        self.userImgOlt.addBorders(of: .white, width: 4.5)
        self.userNameOlt.text = userNameTxt
        self.rightEditBtnOlt.isHidden = isHidefirstRightBtn
        self.midLblOlt.text = midLblText
        userImgOlt.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
        self.userImgOlt.layer.cornerRadius = self.userImgOlt.frame.height/2
        self.userDateStack.isHidden = userDateIsHidden
        self.backBtnOlt.setImage(backBtnImage, for: .normal)
    }
    
    //MARK: IBActions
    
    @IBAction func backAction(_ sender: UIButton) {
        backButtonPressed()
    }
    
    @IBAction func rightNotificationBtnActiio(_ sender: UIButton) {
        navRightNotiButtonPressed()
    }
    
    @IBAction func rightEditBtnActiio(_ sender: UIButton) {
        navRightEditButtonPressed()
    }
    
}
