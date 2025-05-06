//
//  SubscriptionsCell.swift
//  Hey MarketPlace App
//
//  Created by Jamtech on 03/09/24.
//

import UIKit

class SubscriptionsCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet var imgSubBg: UIImageView!
    @IBOutlet var learnMoreBtn: UIButton!
    @IBOutlet var subTittleOlt: UILabel!
    @IBOutlet var subDescription: UILabel!
    @IBOutlet var subDetail: UILabel!
    @IBOutlet var amountOlt: UILabel!
    @IBOutlet weak var innerViewOlt: UIView!
    @IBOutlet weak var outerViewOlt: UIView!
    
    //MARK: properties.
    static let identifier = "SubscriptionsCell"

    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func btnTappedLearnMore(_ sender: UIButton) {
    }
    
    //MARK: func for setupUI
    func setupUI(){
        learnMoreBtn.makeCornerRounded(ofSize: Corner_22)
        innerViewOlt.makeCornerRounded(ofSize: Corner_05)
    }
    
}
