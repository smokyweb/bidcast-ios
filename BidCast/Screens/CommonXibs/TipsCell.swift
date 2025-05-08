//
//  LocationNameCell.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25
//

import UIKit

class TipsCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var imageOlt: UIImageView!
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var innerViewOlt: UIView!
    @IBOutlet weak var descriptionOlt: UILabel!
    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet var priceLbl: UILabel!
    
    
    
    //MARK: properties.
    static let identifier = "TipsCell"
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: setupUI
    func setupUI(){
        self.innerViewOlt.dropShadow(opacity: 0, shadowRadius: 0, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
        self.innerViewOlt.addBorders(of: AppColor.bgColor ?? .defaultDarkBgColor, width: Width_01)
        self.titleOlt.font = OutFitFont.defaultBold(size: 13.0).value
        self.descriptionOlt.font = JostFont.defaultSemiBold(size: 13.0).value
    }
}
