//
//  LabelCell.swift
//  Rise Shine Swing
//
//  Created by JAM-E-221 on 02/09/24.
//

import UIKit

class LabelCell: UITableViewCell {

    // MARK: IBOutlets.
    @IBOutlet var innerViewOlt: UIView!
    @IBOutlet weak var titleOlt: UILabel!

    // MARK: Properties.
    static let identifier = "LabelCell"
    var txtColor: UIColor = AppColor.mediumDarkGray ?? .darkGray

    // MARK: - Initializations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        titleOlt.textColor = txtColor
    }
    
    // MARK: SetupUI
    func setupUI() {
        selectionStyle = .none
        titleOlt.font = AppFont.placeHolder
        titleOlt.textColor = txtColor // Default color for the title label
    }

}
