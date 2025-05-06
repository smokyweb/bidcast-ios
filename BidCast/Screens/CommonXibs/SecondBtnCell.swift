//
//  SecondBtnCell.swift
//  Rise Shine Swing
//
//  Created by JAM-E-221 on 02/09/24.
//

import UIKit

class SecondBtnCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var exitBtn: UIButton!
    
    //MARK: properties.
    static let identifier = "SecondBtnCell"
    var didTapExit : (UIButton) -> () = { _ in}
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        setupBtnUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: IBAction.
    @IBAction func didTap(_ sender: UIButton) {
        self.didTapExit(sender)
        
    }
    
    //MARK: UISetup()
    func setupBtnUI(){
        self.exitBtn.backgroundColor = AppColor.secondary
        self.exitBtn.makeCornerRounded(ofSize: Corner_26)
        self.exitBtn.setTitleColor(.white, for: .normal)
        selectionStyle = .none
    }
}

