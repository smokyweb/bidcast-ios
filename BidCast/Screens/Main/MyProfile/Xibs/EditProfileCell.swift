//
//  EditProfileCell.swift
//  Hey MarketPlace App
//
//  Created by JAM-E-221 on 03/09/24.
//

import UIKit

class EditProfileCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    
    //MARK: properties.
    static let identifier = "EditProfileCell"
    var didTapDelete : (UIButton) ->() = { _ in }
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImage.makeCornerRounded(ofSize: Corner_60)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: IBAction.
    @IBAction func didTap(_ sender: UIButton) {
        self.didTapDelete(sender)
    }
    
}
