//
//  AddressCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 09/05/25.
//

import UIKit

class AddressCell: UITableViewCell {

    static let identifier = "AddressCell"
    
    @IBOutlet weak var centerConst: NSLayoutConstraint!
    @IBOutlet weak var defaiultOlt: UIButton!
    @IBOutlet weak var addressTypeOlt: UILabel!
    @IBOutlet weak var stateOlt: UILabel!
    @IBOutlet weak var streetOlt: UILabel!
    @IBOutlet weak var nameLblOlt: UILabel!
    
    @IBOutlet weak var optionBtnOlt: UIButton!
    @IBOutlet weak var phoneOlt: UILabel!
    @IBOutlet weak var countryOlt: UILabel!
    
    @IBOutlet weak var outerVIewOlt: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.defaiultOlt.makeCornerRounded(ofSize: self.defaiultOlt.frame.height/2)
        self.defaiultOlt.backgroundColor = .darkBlue.withAlphaComponent(0.3)
        self.optionBtnOlt.transform = self.optionBtnOlt.transform.rotated(by: Double.pi/2)
        self.outerVIewOlt.makeCornerRounded(ofSize: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
