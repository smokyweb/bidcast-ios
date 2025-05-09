//
//  DownloadwithTitleCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 09/05/25.
//

import UIKit

class DownloadwithTitleCell: UITableViewCell {

    @IBOutlet weak var innerViewOlt: UIView!
    
    @IBOutlet weak var outerViewOlt: UIView!
    
    static let identifier = "DownloadwithTitleCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        self.outerViewOlt.makeCornerRounded(ofSize: 12)
        self.innerViewOlt.makeCornerRounded(ofSize: 8)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
