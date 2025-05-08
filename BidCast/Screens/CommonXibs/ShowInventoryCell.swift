//
//  ShowInventoryCell.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25
//

import UIKit

class ShowInventoryCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var imageOlt: UIImageView!
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var innerViewOlt: UIView!
    @IBOutlet weak var descriptionOlt: UILabel!
    @IBOutlet var stockOlt: UILabel!
    @IBOutlet var priceDeatilOlt: UILabel!
    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet var imgWidthConstraint: NSLayoutConstraint!
    @IBOutlet var imgLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var menuBtn: UIButton!
    
    var didTapMenuCloser : (UIButton) -> () = {_ in}
    
    
    //MARK: properties.
    static let identifier = "ShowInventoryCell"
    
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
        self.innerViewOlt.dropShadow(opacity: 0, shadowRadius: 0, cornerRadius: Corner_08, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
        self.innerViewOlt.addBorders(of: AppColor.bgColor ?? .defaultDarkBgColor, width: Width_01)
        addTopLeftAndBottomLeftCorner(to: imageOlt, radius: Corner_08)
        self.titleOlt.font = OutFitFont.defaultBold(size: 15.0).value
        self.descriptionOlt.font = JostFont.defaultMedium(size: 13.0).value
        self.stockOlt.font = JostFont.defaultBold(size: 13.0).value
        self.priceDeatilOlt.font = JostFont.defaultRegular(size: 13.0).value
    }
    
    @IBAction func didTapMenu(_ sender: UIButton) {
        self.didTapMenuCloser(sender)
    }
    
    //MARK: for hide Image
    func hideImage(){
        imgWidthConstraint.constant = 0
        imgLeadingConstraint.constant = 0
    }
    
    //MARK: for show Image
    func showImage(){
        imgWidthConstraint.constant = 44
        imgLeadingConstraint.constant = 16
    }

}
