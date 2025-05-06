//
//  SubmitCell.swift
//  Last Minute Louie
//
//  Created by JAM-E-221 on 13/05/24.
//

import UIKit

class SubmitCell: UITableViewCell {
    
    //MARK: IBOutlets.
    
    @IBOutlet var innerViewOlt: UIView!
    @IBOutlet weak var contentOuterViewoLt: UIView!
    @IBOutlet weak var submitBtnOlt: UIButton!
    
    //MARK: Properties.
    static let identifier = "SubmitCell"
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
        self.submitBtnOlt.titleLabel?.font = OutFitFont.defaultExtraBold(size: 15).value
        self.submitBtnOlt.makeCornerRounded(ofSize: Corner_08)
        selectionStyle = .none
    }
  
}

