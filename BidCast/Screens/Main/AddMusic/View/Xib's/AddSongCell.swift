//
//  AddSongCell.swift
//  Rise Shine Swing
//
//  Created by jam 1 TB on 06/03/25.
//

import UIKit

class AddSongCell: UITableViewCell {

    @IBOutlet var outerView: UIView!
    @IBOutlet var addSongBtn: UIButton!
    @IBOutlet var addSubscription: UIButton!
    @IBOutlet var totalCount: UILabel!
    
    var didTapSum : (UIButton) -> () = {_ in}
    var didTapSubscription : (UIButton) -> () = {_ in}
    
    //MARK: properties.
    static let identifier = "AddSongCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    //MARK: IBAction.
    @IBAction func didTap(_ sender: UIButton) {
        self.didTapSum(sender)
    }
    
    @IBAction func addSubscription(_ sender: UIButton) {
        self.didTapSubscription(sender)
    }
    
    //MARK: setupUI
    func setupUI(){
        addSongBtn.titleLabel?.font = OutFitFont.defaultBold(size: 15.0).value
        addSubscription.titleLabel?.font = OutFitFont.defaultBold(size: 15.0).value
        totalCount.font = OutFitFont.defaultBold(size: 15.0).value
    }
    
}
