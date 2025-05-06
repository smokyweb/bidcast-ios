//
//  TwoButtonCell.swift
//  Rise Shine Swing
//
//  Created by Fazal-JAM-E-329 on 12/12/24.
//

import UIKit

class TwoButtonCell: UITableViewCell {

    //MARK: Properties.
    static let identifier = "TwoButtonCell"

    var didTapFirst : (UIButton) -> () = {_ in}
    var didTapSeconde : (UIButton) -> () = {_ in}
    
    @IBOutlet var firstBtn: UIButton!
    
    @IBOutlet var secondeBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func firstBtnAction(_ sender: UIButton) {
        self.didTapFirst(sender)
    }
    
    @IBAction func secondeBtnAction(_ sender: UIButton) {
        self.didTapSeconde(sender)
    }
    
    //MARK: setupUI
    func setupUI(){
        firstBtn.makeCornerRounded(ofSize: Corner_06)
        secondeBtn.makeCornerRounded(ofSize: Corner_06)
    }
}
