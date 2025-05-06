//
//  SignUpTodayCell.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 26/12/24.
//

import UIKit

class SignUpTodayCell: UITableViewCell {

    //MARK: IBOutlets.
    @IBOutlet weak var newToRiseShine: UIButton!
    @IBOutlet var signUpBtn: UIButton!
    
    //MARK: properties.
    static let identifier = "SignUpTodayCell"
    var didTapSignUpClosure : (UIButton) -> () = {_ in}
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    //MARK: IBAction.
    @IBAction func didTapSignUP(_ sender: UIButton) {
        self.didTapSignUpClosure(sender)
    }
    
    //MARK: setupUI
    func setupUI(){
        self.newToRiseShine.titleLabel?.font = JostFont.defaultSemiBold(size: 13).value
        self.signUpBtn.titleLabel?.font = JostFont.defaultBold(size: 13).value
        selectionStyle = .none
    }
}
