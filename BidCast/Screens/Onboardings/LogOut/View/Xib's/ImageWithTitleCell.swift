//
//  ImageWithTitleCell.swift
//  Hey MarketPlace App
//
//  Created by Jamtech on 04/09/24.
//

import UIKit

class ImageWithTitleCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var imageOlt: UIImageView!
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var locationNameOlt: UILabel!
    @IBOutlet weak var locationImgOlt: UIImageView!
    @IBOutlet weak var constraintWidth: NSLayoutConstraint!
    
    //MARK: properties.
    static let identifier = "ImageWithTitleCell"
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
