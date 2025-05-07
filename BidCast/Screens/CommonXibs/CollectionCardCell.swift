//
//  CollectionCardCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 07/05/25.
//

import UIKit

class CollectionCardCell: UICollectionViewCell {

    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var categoyView: UILabel!
    @IBOutlet weak var imgViewOlt: UIImageView!
    @IBOutlet weak var profileNameOlt: UILabel!
    @IBOutlet weak var profileImgOlt: UIImageView!
    @IBOutlet weak var innerViewOlt: UIView!
    @IBOutlet weak var outerViewOlt: UIView!
    static let identifier = "CollectionCardCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.innerViewOlt.makeCornerRounded(ofSize: 12)
    }

}
