//
//  myMusicHeader.swift
//  Rise Shine Swing
//
//  Created by jam 1 TB on 28/12/24.
//

import UIKit

class myMusicHeader: UITableViewHeaderFooterView {
    
    @IBOutlet var sepratorLine: UILabel!
    @IBOutlet var innerViewOlt: UIView!
    @IBOutlet var subTitle: UILabel!
    @IBOutlet var imgUpsDown: UIImageView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var btnTappedArrow: UIButton!
    @IBOutlet var imgOlt: UIImageView!
    @IBOutlet var musicCountOlt: UILabel!
    var toggleSectionAction: (() -> Void)?
    
    
    @IBAction func arrowButtonTapped(_ sender: UIButton) {
        toggleSectionAction?()
    }
    
    //MARK: setupUI()
    func setupUI(){
        lblTitle.font = AppFont.LblTitleBold_17
        subTitle.font = OutFitFont.defaultMedium(size: 15.0).value
        musicCountOlt.font = OutFitFont.defaultMedium(size: 15.0).value
    }
}
