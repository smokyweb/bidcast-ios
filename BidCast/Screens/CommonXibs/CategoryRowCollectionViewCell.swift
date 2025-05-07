//
//  CategoryRowCollectionViewCell.swift
//  BidCast
//
//  Created by Fazal-JAM-E-329 on 07/05/25.
//

import UIKit

class CategoryRowCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var outerStackView: UIStackView!
    
    static let identifier = "CategoryRowCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        categoryLabel.setupLabel(title: "Category", txtColor: .darkGray, fontSize: AppFont.label)
    }
}
