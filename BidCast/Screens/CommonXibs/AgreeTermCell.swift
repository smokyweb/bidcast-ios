//
//  RemberMeCell.swift
//  Last Minute Louie
//
//  Created by JAM-E-329 on 06/05/25
//

import UIKit

class AgreeTermCell: UITableViewCell {
    
    //MARK: IBOutlets.
    
    @IBOutlet var submitBtnOlt: UIButton!
    @IBOutlet var outerViewOlt: UIStackView!
    @IBOutlet weak var agreeVector: UIImageView!
    @IBOutlet weak var acceptTermLbl: UILabel!
    
    //MARK: Properties
    static let identifier = "AgreeTermCell"
    var acceptTermClosure : (Bool)->() = {_ in }
    var didTapSum : (UIButton) -> () = {_ in}
    var isAcceptTerm: Bool = false {
        didSet {
            let imageName = isAcceptTerm ? "checkmark.square.fill" : "square"
            let image = UIImage(systemName: "\(imageName)")?.withRenderingMode(.alwaysTemplate)

                self.agreeVector.image = image
            self.agreeVector.tintColor = isAcceptTerm ? AppColor.primary : .primary
        }
    }
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: IBAction.
    @IBAction func didTapAcceptBtn(_ sender: UIButton) {
        isAcceptTerm.toggle()
        self.acceptTermClosure(isAcceptTerm)
    }
    //MARK: IBAction.
    @IBAction func didTp(_ sender: UIButton) {
        self.didTapSum(sender)
    }
    
    //MARK: setupUI.
    func setupUI(){
        isAcceptTerm = false
        //font
        self.acceptTermLbl.font = AppFont.placeHolder
        self.submitBtnOlt.titleLabel?.font = JostFont.defaultSemiBold(size: 13).value
        self.submitBtnOlt.makeCornerRounded(ofSize: Corner_26)
        selectionStyle = .none
    }
}
