//
//  RemberMeCell.swift
//  Last Minute Louie
//
//  Created by JAM-E-221 on 14/05/24.
//

import UIKit

class RemberMeCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var remberVector: UIImageView!
    @IBOutlet var forgotPaswordOlt: UILabel!
    @IBOutlet var rememberMe: UIView!
    @IBOutlet var rememberMeOlt: UILabel!
    //MARK: Properties
    static let identifier = "RemberMeCell"
    var remmeber : (Bool)->() = {_ in }
    var didTapForgot : (UIButton)->() = {_ in }
    var isRemembered: Bool = false {
        didSet {
            let imageName = isRemembered ? "checkmark.square.fill" : "square"
            let image = UIImage(systemName: "\(imageName)")?.withRenderingMode(.alwaysTemplate)

                self.remberVector.image = image
            self.remberVector.tintColor = isRemembered ? AppColor.primary : .primary

        }
    }
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.rememberMeOlt.font = JostFont.defaultRegular(size: 13).value
        self.forgotPaswordOlt.font = JostFont.defaultSemiBold(size: 13).value
        isRemembered = false
        selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: IBAction.
    @IBAction func didTapRememberBtn(_ sender: UIButton) {
        isRemembered.toggle()
        self.remmeber(isRemembered)
        //
    }
    
    //MARK: IBAction.
    @IBAction func DidTabFor(_ sender: UIButton) {
        self.didTapForgot(sender)
    }
    
}
