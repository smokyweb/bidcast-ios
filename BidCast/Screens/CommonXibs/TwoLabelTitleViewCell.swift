//
//  TwoLabelTitleViewCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 09/05/25.
//

import UIKit

class TwoLabelTitleViewCell: UITableViewCell {

    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet weak var activeBtn: UIButton!
    static let identitfier = "TwoLabelTitleViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        self.activeBtn.makeCornerRounded(ofSize: 12)
        self.outerViewOlt.makeCornerRounded(ofSize: 12)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        

        // Configure the view for the selected state
    }
    
}
