//
//  MyOrderCell.swift
//  BidCast
//
//  Created by Fazal_JAM-E-329 on 06/05/25
//

import UIKit

class MyOrderCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet var mainViewOlt: UIView!
    @IBOutlet weak var userNameOlt: UILabel!
    @IBOutlet weak var userbidDetail: UILabel!
    @IBOutlet weak var userbidPrice: UILabel!
    @IBOutlet weak var bidderImageOlt: UIImageView!
    @IBOutlet weak var bidderNameDetail: UILabel!
    @IBOutlet var bidderBidDetails: UILabel!
    @IBOutlet var acceptStack: UIStackView!
    @IBOutlet var bidderStack: UIStackView!
    @IBOutlet var userStack: UIStackView!
    @IBOutlet var acceptBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bidderVwHeightConstraint: NSLayoutConstraint!
    @IBOutlet var userVwHeightConstraint: NSLayoutConstraint!
    @IBOutlet var orderAmountTitle: UILabel!
    @IBOutlet var orderAmountTotal: UILabel!
    @IBOutlet var orderView: UIView!
    

    //MARK: properties.
    static let identifier = "MyOrderCell"
    
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
        self.mainViewOlt.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
        self.userNameOlt.font = OutFitFont.defaultBold(size: 13.0).value
        self.userbidDetail.font = OutFitFont.defaultMedium(size: 13.0).value
        self.userbidPrice.font =  OutFitFont.defaultRegular(size: 13.0).value
        self.bidderNameDetail.font = OutFitFont.defaultBold(size: 13.0).value
        self.bidderBidDetails.font = OutFitFont.defaultRegular(size: 13.0).value
        self.orderAmountTitle.font = OutFitFont.defaultMedium(size: 13.0).value
        self.orderAmountTotal.font = OutFitFont.defaultBold(size: 13.0).value
        self.bidderImageOlt.makeCornerRounded(ofSize: Corner_08)
        self.bidderImageOlt.makeCircular()
        orderView.layer.cornerRadius = orderView.frame.size.height / 4
        orderView.clipsToBounds = true
    }
    
}
