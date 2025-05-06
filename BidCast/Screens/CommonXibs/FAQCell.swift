//
//  FAQCell.swift
//  Hey MarketPlace App
//
//  Created by JAM-E-221 on 03/09/24.
//

import UIKit

class FAQCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var showBtn: UIButton!
    @IBOutlet weak var outViewOlt: UIView!
    @IBOutlet weak var outerView: UIStackView!
    @IBOutlet weak var secondView: UIView!
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var lblQuestions : UILabel!
    @IBOutlet weak var lblAnswer : UILabel!
    @IBOutlet weak var vertorImg: UIImageView!
    
    //MARK: properties.
    static let identifier = "FAQCell"
    var isHiddenDetails = false
    var didTabFAQ : (UIButton) -> () = {_ in}
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: IBAction.
    @IBAction func didtap(_ sender: UIButton) {
        self.didTabFAQ(sender)

    }
    
    //MARK: setupUI.
    func setupUI(){
        self.outViewOlt.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
//        self.lblQuestions.font = OutFitFont.defaultBold(size: 13.0).value
//        self.lblAnswer.font = OutFitFont.defaultRegular(size: 13.0).value
        
    }
    
}
