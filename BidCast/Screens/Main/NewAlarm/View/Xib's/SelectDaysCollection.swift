//
//  SelectedListingViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 22/05/24.
//

import UIKit

class SelectDaysCollection: UICollectionViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var innerView: UIView!
    
    //MARK: properties.
    static let identifier = "SelectDaysCollection"
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle.font = JostFont.defaultSemiBold(size: 13.0).value
        innerView.makeCornerRounded(ofSize: Corner_06)
    }
}
