//
//  CloseTabBarCell.swift
//  Rise Shine Swing
//
//  Created by jam 1 TB on 08/01/25.
//

import UIKit

class CloseTabBarCell: UITableViewCell {

    @IBOutlet var outerView: UIView!
    @IBOutlet var btnCancelOlt: UIButton!

    // MARK: Properties
    static let identifier = "CloseTabBarCell"
    var didTapSum: (UIButton) -> () = {_ in}

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.didTapSum(sender)
    }
}
