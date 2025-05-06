//
//  SelectedListingViewController.swift
//  BidCast
//
//  Created by JAM-E-214 on 22/05/24.
//

import UIKit

class ImagesCollectionViewCell: UICollectionViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var profileImage: UIImageView!
    
    //MARK: properties.
    static let identifier = "ImagesCollectionViewCell"
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.makeCornerRounded(ofSize: Corner_12)
        profileImage.addBorders(of: .black, width: Width_01)
    }
}
