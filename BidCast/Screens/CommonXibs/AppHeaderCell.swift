//
//  AppHeaderCell.swift
//  BidCast
//
//  Created by JAM-E-221 on 31/08/24.
//

import UIKit

class AppHeaderCell: UITableViewCell {
    
    // MARK: IBOutlets
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var outerViewOlt: UIView!
    
    // MARK: Properties
    static let identifier = "AppHeaderCell"
    
    // MARK: - Initializations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: setupUI
    func setupUI(){
        titleOlt.font = OutFitFont.defaultExtraBold(size: 23.0).value
        selectionStyle = .none
    }
}
