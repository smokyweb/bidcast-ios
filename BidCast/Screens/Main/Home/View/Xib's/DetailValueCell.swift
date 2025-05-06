//
//  DetailValueCell.swift
//  Rise Shine Swing
//
//  Created by Fazal-JAM-E-329 on 13/12/24.
//

import UIKit

class DetailValueCell: UITableViewCell {
    
    //MARK: Properties.
    static let identifier = "DetailValueCell"
    
    
    @IBOutlet var innerViewOlt: UIView!
    @IBOutlet var lblTittle: UILabel!
    @IBOutlet var lblValue: UILabel!
    @IBOutlet var innerViewBottomConst: NSLayoutConstraint!
    @IBOutlet var innerViewTopConst: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //MARK: setupUI
    func setupUI(){
        innerViewOlt.makeCornerRounded(ofSize: Corner_06)
    }
}
