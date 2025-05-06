//
//  HeaderView.swift
//  YTTarun
//
//  Created by Abdul-JAM-E-157 on 12/05/24.
//

import UIKit

class MoreHeaderView: UIView {
    
    //MARK: IBOutlets
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var midLbl: UILabel!
    
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("MoreHeaderView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        midLbl.lineBreakMode = .byWordWrapping
        midLbl.numberOfLines = 0
        midLbl.font = OutFitFont.defaultBold(size: 13.0).value
        
    }
}
