//
//  AlarmCell.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25. on 02/09/24.
//

import UIKit

class AlarmCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet var alarmSwitch: UISwitch!
    @IBOutlet weak var titleOlt: UILabel!
    @IBOutlet weak var innerViewOlt: UIView!
    @IBOutlet weak var descriptionOlt: UILabel!
    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet var sepratorBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var innerVwTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var innnerVwBottomConstraint: NSLayoutConstraint!
    @IBOutlet var descHeightConst: NSLayoutConstraint!
    
    //MARK: properties.
    static let identifier = "AlarmCell"
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        alarmSwitch.onTintColor = .lightBlue
        setupUI()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    @IBAction func alramSwitchTapped(_ sender: UISwitch) {
    }
    
    //MARK: setupUI
    func setupUI(){
        titleOlt.font = OutFitFont.defaultRegular(size: 26.0).value
        descriptionOlt.font = JostFont.defaultRegular(size: 16.0).value
    }
}
