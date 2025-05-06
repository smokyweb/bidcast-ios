//
//  GalleryRowTableViewCell.swift
//  Rise Shine Swing
//
//  Created by JamTech on 18/12/24.
//

import UIKit

class SongRowTableViewCell: UITableViewCell {

    //MARK: IBOutlets.
    
    @IBOutlet var innerViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var innerViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageOlt: UIImageView!
    @IBOutlet var subTitleOlt: UILabel!
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var rightButtonOlt: UIButton!
    @IBOutlet weak var innerViewOlt: UIView!
    @IBOutlet weak var outerViewOlt: UIView!
    
    //MARK: properties.
    static let identifier = "SongRowTableViewCell"
    var didTapDeleteImg: (UIButton) -> () = {_ in}
    var didTapDeleteServerImg: (UIButton) -> () = {_ in}
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: IBAction.
    @IBAction func didTab(_ sender: UIButton) {
        self.didTapDeleteImg(sender)
    }
    
    //MARK: setupUI
    func setupUI(){
        titleOlt.font = JostFont.defaultSemiBold(size: 13.0).value
        subTitleOlt.font = JostFont.defaultRegular(size: 12.0).value
    }
}
