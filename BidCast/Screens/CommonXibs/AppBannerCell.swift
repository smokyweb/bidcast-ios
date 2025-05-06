//
//  AppBannerCell.swift
//  BidCast
//
//  Created by JAM-E-221 on 31/08/24.
//

import UIKit

class AppBannerCell: UITableViewCell {

    //MARK: IBOutlets.
    @IBOutlet weak var bannerImg: UIImageView!
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var ImgHeight: NSLayoutConstraint!
    @IBOutlet var btnOlt: UIButton!
    
    //MARK: Properties.
    static let identifier = "AppBannerCell"
    var didTapSum : (UIButton) -> () = {_ in}
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func backBtnOlt(_ sender: UIButton) {
        self.didTapSum(sender)
    }
    
    
    //MARK: setupUI
    func setupUI(){
        selectionStyle = .none
    }
}
