//
//  AddSongList.swift
//  Rise Shine Swing
//
//  Created by jam 1 TB on 06/03/25.
//

import UIKit

class AddSongList: UITableViewCell {

    //MARK: IBOutlets.
    @IBOutlet var subTitleOlt: UILabel!
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var rightButtonOlt: UIButton!
    @IBOutlet weak var outerViewOlt: UIView!
    
    //MARK: properties.
    static let identifier = "AddSongList"
    
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
        self.outerViewOlt.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_12, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
    }
}
