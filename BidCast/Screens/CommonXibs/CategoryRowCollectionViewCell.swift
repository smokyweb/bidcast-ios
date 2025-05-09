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
    @IBOutlet var seprator: UILabel!
    
    static let identifier = "CategoryRowCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
//        categoryLabel.setupLabel(title: "Category", txtColor: .darkGray, fontSize: AppFont.label)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        outerStackView.layer.cornerRadius = outerStackView.frame.height / 2
        outerStackView.layer.masksToBounds = true
    }
}
