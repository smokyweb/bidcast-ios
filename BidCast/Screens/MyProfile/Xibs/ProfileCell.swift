//
//  ProfileCell.swift
//  Hey MarketPlace App
//
//  Created by JAM-E-221 on 03/09/24.
//

import UIKit

class ProfileCell: UITableViewCell {

    //MARK: IBOutlets.
    @IBOutlet weak var imageViewOlt: UIImageView!
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var imageViewRoundBG: UIView!
    
    //MARK: properties.
    static let identifier = "ProfileCell"
    var didTapEdit : (UIButton) -> () = {_ in}
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageViewOlt.makeCircular()
        self.imageViewRoundBG.makeCircular()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: IBAction.
    @IBAction func didTap(_ sender: UIButton) {
        self.didTapEdit(sender)
    }
}
