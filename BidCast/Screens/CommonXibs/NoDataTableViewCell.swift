//
//  NoDataTableViewCell.swift
//  Last Minute Louie
//
//  Created by JAM-E-221 on 30/05/24.
//

import UIKit

class NoDataTableViewCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var labelOlt: UILabel!
    @IBOutlet weak var outerView: UIView!
    
    //MARK: properties.
    static let identifier = "NoDataTableViewCell"
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor =  AppColor.View.bgLightMist
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: setupUI
    func setupUI(){
        labelOlt.font = OutFitFont.defaultBold(size: 13.0).value
        self.outerView.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
    }
}
