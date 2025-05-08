//
//  MemberCollectionViewCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 08/05/25.
//

import UIKit

class MemberCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imgOlt: UIImageView!
    
    @IBOutlet weak var subLabelOlt: UILabel!
    @IBOutlet weak var lblOlt: UILabel!
    @IBOutlet weak var outerViewOlt: UIView!
    static let identifier = "MemberCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        self.outerViewOlt.backgroundColor = .clear
    }

}
