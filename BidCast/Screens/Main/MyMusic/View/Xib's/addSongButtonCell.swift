//
//  addSongButtonCell.swift
//  Rise Shine Swing
//
//  Created by jam 1 TB on 28/12/24.
//

import UIKit

class addSongButtonCell: UITableViewCell {
        
    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet weak var addSongBtnOlt: UIButton!
    
    //MARK: Properties.
    static let identifier = "addSongButtonCell"
    var didTapSum : (UIButton) -> () = {_ in}
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: IBAction.
    @IBAction func didTp(_ sender: UIButton) {
        self.didTapSum(sender)
    }
    
    //MARK: setupUI
    func setupUI(){
        self.addSongBtnOlt.makeCornerRounded(ofSize: Corner_06)
        selectionStyle = .none
    }
    
}



