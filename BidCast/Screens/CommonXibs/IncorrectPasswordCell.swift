//
//  LabelCell.swift
//  BidCast
//
//  Created by JAM-E-221 on 02/09/24.
//

import UIKit

class IncorrectPasswordCell: UITableViewCell {

    // MARK: IBOutlets.
    @IBOutlet var innerViewOlt: UIView!
    @IBOutlet weak var titleOlt: UILabel!

    // MARK: Properties.
    static let identifier = "IncorrectPasswordCell"

    // MARK: - Initializations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Setup UI
    func setupUI() {
        selectionStyle = .none
        innerViewOlt.makeCornerRounded(ofSize: Corner_06)
        innerViewOlt.backgroundColor = .beige
    }
}
