//
//  KeyCollectionViewCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 08/05/25.
//

import UIKit

class KeyCollectionViewCell: UICollectionViewCell {

    static let identifier = "KeyCollectionViewCell"
    
    @IBOutlet weak var imgOlt: UIImageView!
    @IBOutlet weak var subLabelOlt: UILabel!
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var outerViewOlt: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }

}
