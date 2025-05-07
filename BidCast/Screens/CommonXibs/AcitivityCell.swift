//
//  AcitivityCell.swift
//  BidCast
//
//  Created by Fazal_JAM-E-329 on 06/05/25
//

import UIKit

class AcitivityCell: UITableViewCell {
    
    //MARK: IBOutlets.
    
    @IBOutlet var mainViewOlt: UIView!
    @IBOutlet weak var userImageOlt: UIImageView!
    @IBOutlet weak var userNameOlt: UILabel!
    @IBOutlet weak var userbidDetail: UILabel!
    @IBOutlet weak var userbidPrice: UILabel!
    @IBOutlet weak var bidderImageOlt: UIImageView!
    @IBOutlet weak var bidderNameDetail: UILabel!
    @IBOutlet var bidderBidDetails: UILabel!
    @IBOutlet weak var bidderPriceDetail: UILabel!
    @IBOutlet var declineBtn: UIButton!
    @IBOutlet var acceptBtn: UIButton!
    @IBOutlet var acceptStack: UIStackView!
    @IBOutlet var bidderStack: UIStackView!
    @IBOutlet var userStack: UIStackView!
    @IBOutlet var acceptBtnHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bidderVwHeightConstraint: NSLayoutConstraint!
    @IBOutlet var userVwHeightConstraint: NSLayoutConstraint!
    @IBOutlet var bidderDate: UILabel!
    
    //MARK: properties.
    static let identifier = "AcitivityCell"
    var didTapAccept : (UIButton)->() = {_ in}
    var didTapReject : (UIButton)->() = {_ in }
    
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
        self.mainViewOlt.dropShadow(opacity: 0, shadowRadius: 0, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
        self.userNameOlt.font = OutFitFont.defaultBold(size: 13.0).value
        self.userbidDetail.font = OutFitFont.defaultMedium(size: 13.0).value
        self.userbidPrice.font =  OutFitFont.defaultBold(size: 15.0).value
        self.bidderNameDetail.font = OutFitFont.defaultBold(size: 13.0).value
        self.bidderBidDetails.font = OutFitFont.defaultRegular(size: 13.0).value
        self.bidderDate.font =  OutFitFont.defaultRegular(size: 13.0).value
        self.bidderPriceDetail.font =  OutFitFont.defaultBold(size: 15.0).value
        self.userImageOlt.makeCircular()
        self.bidderImageOlt.makeCornerRounded(ofSize: Corner_08)
        self.acceptBtn.makeCornerRounded(ofSize: Corner_08)
        self.declineBtn.makeCornerRounded(ofSize: Corner_08)
    }
    
    @IBAction func acceptTapped(_ sender: UIButton) {
        self.didTapAccept(sender)
    }
    
    @IBAction func declineTapped(_ sender: UIButton) {
        self.didTapReject(sender)
    }
    
    
    //MARK: hideShowBidderView
    func hideShowBidderView(stackHidden: Bool, height: Double? = Const.Height.AutomaticDimension) {
        bidderStack.isHidden = stackHidden
        bidderVwHeightConstraint.constant = stackHidden ? 0.0 : 65
    }
    
    //MARK: hideShowUserView
    func hideShowUserView(stackHidden: Bool, height: Double? = Const.Height.AutomaticDimension) {
        userStack.isHidden = stackHidden
        userVwHeightConstraint.constant = stackHidden ? 0.0 : 65
    }

    
    //MARK: hideAcceptView
    func hideShowAcceptView(stackHidden : Bool ,height : Double? = Const.Height.AutomaticDimension){
        acceptStack.isHidden = stackHidden
        acceptBtnHeightConstraint.constant = stackHidden ? 0.0 : 65
    }
}
