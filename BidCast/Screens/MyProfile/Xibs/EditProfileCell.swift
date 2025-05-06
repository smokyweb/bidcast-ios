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
    @IBOutlet var titleOlt: UILabel!
    
    //MARK: properties.
    static let identifier = "EditProfileCell"
    var didTapDelete : (UIButton) ->() = { _ in }
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImage.makeCornerRounded(ofSize: Corner_60)
        self.titleOlt.font = OutFitFont.defaultBold(size: 13.0).value
        deleteBtn.addBorders(of: .white, width: Width_01)
        deleteBtn.layer.cornerRadius = deleteBtn.frame.width / 2
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: IBAction.
    @IBAction func didTap(_ sender: UIButton) {
        self.didTapDelete(sender)
    }
}
