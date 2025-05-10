//
//  MyAccountCell.swift
//  Onleetech App
//
//  Created by JAM_E_329 on 03/02/25.
//

import UIKit

class MyAccountCell: UITableViewCell {

    //MARK: IBOutlet.
    @IBOutlet var mainViewOlt: UIView!
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var userNameOlt: UILabel!
    @IBOutlet var descriptionOlt: UILabel!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var phoneLblOlt: UILabel!
    @IBOutlet var phoneImg: UIImageView!
    @IBOutlet var emailImg: UIImageView!
    @IBOutlet var emailOlt: UILabel!
    @IBOutlet var userDetailStackView: UIStackView!
    
    //MARK: properties.
    static let identifier = "MyAccountCell"
    var didTapEdit : (UIButton)->() = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func editMyAccount(_ sender: UIButton) {
        didTapEdit(sender)
    }
    
    //MARK: setupUI.
    func setupUI(){
        profileImage.makeCircular()
        userNameOlt.font = OutFitFont.defaultBold(size: 15.0).value
        descriptionOlt.font = AppFont.placeHolder
        editButton.titleLabel?.font = OutFitFont.defaultBold(size: 10.0).value
        phoneLblOlt.font = AppFont.placeHolder
        emailOlt.font = AppFont.placeHolder
        editButton.makeCornerRounded(ofSize: 13.5)
    }
}

