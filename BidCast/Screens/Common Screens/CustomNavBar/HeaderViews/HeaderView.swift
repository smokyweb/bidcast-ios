//
//  HeaderView.swift
//  YTTarun
//
//  Created by Abdul-JAM-E-157 on 12/05/24.
//

import UIKit

class HeaderView: UIView {
    
    //MARK: IBOutlets
    @IBOutlet weak var blueView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var midLbl: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var bottomLbl: UILabel!
    @IBOutlet var cenetrVerticalConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var backButtonPressed: () -> () = {}
    var navRightButtonPressed : () -> () = {}
    
    // Closure actions for buttons
    var rightButtonAction: (() -> Void)?
    var leftButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("HeaderView", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        midLbl.lineBreakMode = .byWordWrapping
        midLbl.numberOfLines = 0
        midLbl.font = OutFitFont.defaultBold(size: 13.0).value
        bottomLbl.font = OutFitFont.defaultSemiBold(size: 11.0).value
    }
    
    //MARK: - Setup header view
    func headerViewSetup(
        rightButtonHidden: Bool = true,
        leftButtonHidden: Bool = false,
        headerName: String,
        setRightImage: UIImage? = nil,
        setLeftImage: UIImage? = nil,
        rightButtonAction: (() -> Void)? = nil,
        leftButtonAction: (() -> Void)? = nil
    ) {
        // Hide or show buttons
        rightButton.isHidden = rightButtonHidden
        leftButton.isHidden = leftButtonHidden
        
        
        // Set header name
        midLbl.text = headerName
        
        // Set button actions
        self.rightButtonAction = rightButtonAction
        self.leftButtonAction = leftButtonAction
        
        // Set right images if provided
        if let rightImage = setRightImage {
            rightButton.setImage(rightImage, for: .normal)
//            rightButton.se
        }
        
        // Set left images if provided
        if let leftImage = setLeftImage {
            leftButton.setImage(leftImage, for: .normal)
            
        }
        
        // Add target actions for right and left buttons
        rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(didTapLeftButton), for: .touchUpInside)
    }

    //MARK: didTapRightButton
    @objc func didTapRightButton() {
        rightButtonAction?()
    }
    //MARK: didTapLeftButton
    @objc func didTapLeftButton() {
        leftButtonAction?()
    }
    //MARK: IBActions
    @IBAction func backAction(_ sender: UIButton) {
        backButtonPressed()
    }
    
    
    @IBAction func rightBtnActiio(_ sender: UIButton) {
        navRightButtonPressed()
    }
}
