//
//  AppHeaderExpendableCell.swift
//  Rise Shine Swing
//
//  Created by Vivek-JAM-E-328 on 02/09/24.
//

import UIKit

class AppHeaderExpendableCell: UITableViewCell {

    //MARK: IBOutlets.
    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var rightButtonOlt: UIButton!
    @IBOutlet weak var rightView: UIView!
    @IBOutlet weak var fotterview: UIView!
    
    
    //MARK: properties.
    static let identifier = "AppHeaderExpendableCell"
    var didTapSum : (UIButton) -> () = {_ in}
    var rightBtnName = "View All"
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
//       self.outerViewOlt.backgroundColor = .ghostWhite
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        rightButtonOlt.setTitle(rightBtnName, for: .normal)
        rightView.isHidden = true
    }
    
    //MARK: IBAction.
    @IBAction func didTapped(_ sender: UIButton) {
        didTapSum(sender)
    }
    
    
    
    // MARK: Set Background Color, Selection Style, Font, and Font Color
    func configure(backgroundColor: UIColor = .white,
                    selectionStyle: UITableViewCell.SelectionStyle = .none,
                   font: UIFont = .systemFont(ofSize: 28),
                    fontColor: UIColor = .black,
                    title : String = "Sign In",
                    rightViewHidden: Bool = true) {
        
        // Set background color
        outerViewOlt.backgroundColor = backgroundColor
        
        // Set selection style
        self.selectionStyle = selectionStyle
        
        // Set font and font color for title label
        titleOlt.text = title
        titleOlt.font = font
        titleOlt.textColor = .black
        
        rightButtonOlt.titleLabel?.font = .systemFont(ofSize: 28)
        rightButtonOlt.titleLabel?.textColor = fontColor
        
        rightButtonOlt.isHidden = rightViewHidden
    }
    
    //for hide right buton
    func hideRightButton(isHidden : Bool = false){
        rightButtonOlt.isHidden = isHidden
    }
}
