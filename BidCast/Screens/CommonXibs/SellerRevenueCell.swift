//
//  ProductCollectionViewCell.swift
//  Well Genius App
//
//  Created by Vivek-JAM-E-328 on 30/12/24.
//

import UIKit

class SellerRevenueCell: UICollectionViewCell {
    
    @IBOutlet weak var labelOlt: UILabel!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var lblStackView: UIStackView!
    @IBOutlet weak var productNameLbl: UILabel!
    
    static let identifier = "SellerRevenueCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        innerView.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_08, shadowColor: AppColor.black ?? UIColor.black)
        self.labelOlt.font = AppFont.Labeltitle
        
    }
}
