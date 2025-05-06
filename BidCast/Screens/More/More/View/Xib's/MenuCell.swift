//
//  MenuCell.swift
//  BidCast
//
//  Created by JAM-E-Ankit on 16/10/24.
//

import UIKit

class MenuCell: UITableViewCell {
    
    @IBOutlet weak var OuterView: UIView!
    @IBOutlet weak var nextBtnImg: UIImageView!
    @IBOutlet weak var contentOuterViewOlt: UIView!
    @IBOutlet weak var labelOlt: UILabel!
    @IBOutlet weak var vectorView: UIView!
    @IBOutlet weak var vectorImage: UIImageView!
    @IBOutlet weak var nextBtnOlt: UIButton!
    
    @IBOutlet var borderWidth: UIView!
    static let identifier = "MenuCell"
    var didTapNext : (UIButton)->() = {_ in}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didTap(_ sender: UIButton) {
        didTapNext(sender)
    }
    
}
