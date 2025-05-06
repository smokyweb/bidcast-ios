//
//  SubscriptionsCell.swift
//  Hey MarketPlace App
//
//  Created by Jamtech on 03/09/24.
//

import UIKit

class SubscriptionsCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var discountViewOlt: UIView!
    @IBOutlet weak var innerViewOlt: UIView!
    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var detailOlt: UILabel!
    @IBOutlet weak var amountOlt: UILabel!
    @IBOutlet weak var dollarOlt: UILabel!
    @IBOutlet weak var monthlyOlt: UILabel!
    @IBOutlet weak var activeView: UIView!
    @IBOutlet weak var activeOlt: UILabel!
    @IBOutlet var selctedSubOlt: UIImageView!
    
    
    //MARK: properties.
    static let identifier = "SubscriptionsCell"

    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    func setupUI(){
        self.titleOlt.font = OutFitFont.defaultBold(size: 19.0).value
        self.discountLbl.font = OutFitFont.defaultExtraBold(size: 10.0).value
        self.discountLbl.font  = AppFont.placeHolder
        self.discountViewOlt.makeCornerRounded(ofSize: Corner_06)
        self.innerViewOlt.dropShadow(opacity: 0.5, shadowRadius: Radius_02, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? .squirrelGrey)
    }
    
}
