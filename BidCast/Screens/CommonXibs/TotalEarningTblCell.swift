//
//  TotalEarningTblCell.swift
//  Onleetech App
//
//  Created by JAM_E_329 on 06/02/25.
//

import UIKit

class TotalEarningTblCell: UITableViewCell {

    @IBOutlet var outerViewOlt: UIView!
    @IBOutlet var titleOltFirst: UILabel!
    @IBOutlet var titleOltSec: UILabel!
    
    //MARK: Properties.
    static let identifier = "TotalEarningTblCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupUI(){
        titleOltFirst.font = AppFont.placeHolder
        titleOltSec.font =  OutFitFont.defaultBold(size: 16.0).value
        self.outerViewOlt.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_08, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
    }
    
}
