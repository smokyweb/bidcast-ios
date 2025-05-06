//
//  HeaderWithAppName.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 06/05/25.
//

import UIKit

class HeaderWithAppName: UIView {
    
    //MARK: IBOutlets
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var midLbl: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var appButton: UIButton!
    @IBOutlet var cenetrVerticalConstraint: NSLayoutConstraint!
    @IBOutlet var widthConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var appButtonPresses: () -> () = {}
    var navRightButtonPressed : () -> () = {}
    var navLeftButtonPressed : () -> () = {}
    
    // Closure actions for buttons
    var rightButtonAction: (() -> Void)?
    var leftButtonAction: (() -> Void)?
    var appButtonAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("HeaderWithAppName", owner: self, options: nil)
        addSubview(containerView)
        containerView.frame = self.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        midLbl.lineBreakMode = .byWordWrapping
        midLbl.numberOfLines = 0
        midLbl.font = OutFitFont.defaultBold(size: 18.0).value
        
    }
    
    //MARK: - Setup header view
    func headerViewSetup(
        appButtonHidden : Bool = false,
        rightButtonHidden: Bool = true,
        leftButtonHidden: Bool = false,
        headerName: String,
        setRightImage: UIImage? = nil,
        setLeftImage: UIImage? = nil,
        setAppBtnImage : UIImage? = nil,
        appButtonAction : (() -> Void)? = nil,
        rightButtonAction: (() -> Void)? = nil,
        leftButtonAction: (() -> Void)? = nil
    ) {
        // Hide or show buttons
        appButton.isHidden = appButtonHidden
        rightButton.isHidden = rightButtonHidden
        leftButton.isHidden = leftButtonHidden
        
        
        // Set header name
        midLbl.text = headerName
        
        // Set button actions
        self.rightButtonAction = rightButtonAction
        self.leftButtonAction = leftButtonAction
        self.appButtonAction = appButtonAction
        
        // Set right images if provided
        if let rightImage = setRightImage {
            rightButton.setImage(rightImage, for: .normal)
        }
        
        // Set left images if provided
        if let leftImage = setLeftImage {
           
            leftButton.setImage(leftImage, for: .normal)
            
            widthConstraint.constant = 30.0
        }
        
        // Set appBtnImage images if provided
        if let appBtnImage = setAppBtnImage {
            appButton.setImage(appBtnImage, for: .normal)
            // Set width and height based on the app button image size
            let appBtnImageSize = appBtnImage.size
            widthConstraint.constant = appBtnImageSize.width
            let heightConstraint = appButton.heightAnchor.constraint(equalToConstant: appBtnImageSize.height)
            heightConstraint.isActive = true
            widthConstraint.constant = 30.0
        }
        
        self.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? 20 : 0
        // Add target actions for right and left buttons
        rightButton.addTarget(self, action: #selector(didTapRightButton), for: .touchUpInside)
        leftButton.addTarget(self, action: #selector(didTapLeftButton), for: .touchUpInside)
        appButton.addTarget(self, action: #selector(didTapAppButton), for: .touchUpInside)
    }

    //MARK: didTapRightButton
    @objc func didTapRightButton() {
        rightButtonAction?()
    }
    //MARK: didTapLeftButton
    @objc func didTapLeftButton() {
        leftButtonAction?()
    }
    
    //MARK: didTapAppButton
    @objc func didTapAppButton() {
        appButtonAction?()
    }
    //MARK: IBActions
   
    @IBAction func leftBtnAction(_ sender: UIButton) {
        navLeftButtonPressed()
    }
    
    
    @IBAction func rightBtnActiio(_ sender: UIButton) {
        navRightButtonPressed()
    }
}


