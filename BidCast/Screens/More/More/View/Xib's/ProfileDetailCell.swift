//
//  ProfileDetailCell.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 02/09/24.
//

import UIKit

class ProfileDetailCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var imageOlt: UIImageView!
    @IBOutlet var imgViewOlt: UIView!
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var rightButtonOlt: UIButton!
    @IBOutlet weak var innerViewOlt: UIView!
    @IBOutlet weak var descriptionOlt: UILabel!
    @IBOutlet weak var outerViewOlt: UIView!
    
    //MARK: properties.
    static let identifier = "ProfileDetailCell"
    var didTapNext : (UIButton)->() = {_ in}
  
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    //MARK: setupUI
    func setupUI(){
        imageOlt.makeCornerRounded(ofSize: Corner_08)
        imgViewOlt.makeCornerRounded(ofSize: Corner_08)
        imgViewOlt.addBorders(of: .white, width: Width_02)
        titleOlt.font = OutFitFont.defaultBold(size: 15.0).value
        descriptionOlt.font = OutFitFont.defaultMedium(size: 14.0).value
    }
    
    @IBAction func didTap(_ sender: UIButton) {
        didTapNext(sender)
    }
}
