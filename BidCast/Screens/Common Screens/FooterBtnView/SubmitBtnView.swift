//
//  SubmitBtnView.swift
//  BidCast
//
//  Created by Abdul-JAM-E-157 on 11/01/25.
//

import UIKit

class SubmitBtnView: UITableViewHeaderFooterView{
    
    //MARK: IBOutlets.
    
    @IBOutlet var innerViewOlt: UIView!
    @IBOutlet weak var contentOuterViewoLt: UIView!
    @IBOutlet weak var submitBtnOlt: UIButton!
    
    //MARK: Properties.
    static let identifier = "SubmitBtnView"
    var didTapSum : (UIButton) -> () = {_ in}
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    //MARK: IBAction.
    @IBAction func didTp(_ sender: UIButton) {
        self.didTapSum(sender)
    }
    
    //MARK: setupUI
    func setupUI(){
        self.submitBtnOlt.titleLabel?.font = JostFont.defaultSemiBold(size: 13).value
        self.submitBtnOlt.makeCornerRounded(ofSize: Corner_26)
//        selectionStyle = .none
    }
  
}
