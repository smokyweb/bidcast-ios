//
//  AlertWithDoubleButtonViewController.swift
//  Rise Shine Swing
//
//  Created by jam 1 TB on 14/12/24.
//

import UIKit

class AlertWithDoubleButtonViewController: UIViewController {

    //MARK: IBOutlets.
    @IBOutlet weak var outerview: UIView!
    @IBOutlet weak var alertTypeimgView: UIImageView!
    @IBOutlet weak var alertTypeHeadingLbl: UILabel!
    @IBOutlet weak var alertTypeContentLbl: UILabel!
    @IBOutlet weak var alertTypeFirstBtn: UIButton!
    @IBOutlet weak var alertTypeSecondBtn: UIButton!
    @IBOutlet weak var firstBtnWidth: NSLayoutConstraint!
    @IBOutlet weak var secondBtnWidth: NSLayoutConstraint!
    
    
    //MARK: Properties.
    var image = UIImage(named: "")
    var heading = ""
    var content = ""
    var firstBtnTitle = ""
    var secondBtnTitle = ""
    var firstBtnClosure : () -> () = {}
    var secondBtnClosure : () -> () = {}
    var firstBackColor = UIColor.black
    var secondBackColor = UIColor.black
    var isHiddenRequired = false
    var titleColor1 = UIColor.white
    var titleColor2 = UIColor.black
    var borderColor1 = UIColor.clear
    var borderColor2 = UIColor.clear

    
    
    //MARK: ViewLifecycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        alertTypeHeadingLbl.font = OutFitFont.defaultExtraBold(size: 23.0).value
        alertTypeContentLbl.font = AppFont.placeHolder
        alertTypeFirstBtn.titleLabel?.font = OutFitFont.defaultExtraBold(size: 15.0).value
        alertTypeSecondBtn.titleLabel?.font = OutFitFont.defaultExtraBold(size: 15.0).value
        alertTypeimgView.image = image
        alertTypeFirstBtn.backgroundColor = firstBackColor
        alertTypeSecondBtn.backgroundColor = secondBackColor
        alertTypeHeadingLbl.text = heading
        alertTypeContentLbl.text = content
        alertTypeFirstBtn.setupButton(title: firstBtnTitle,titleColor: titleColor1,borderWidth: Width_01, borderColor: borderColor1)
        alertTypeSecondBtn.setupButton(title: secondBtnTitle,titleColor: titleColor2,borderWidth: Width_01, borderColor: borderColor2)
        
        alertTypeFirstBtn.makeCornerRounded(ofSize: Corner_26)
        self.alertTypeSecondBtn.makeCornerRounded(ofSize: Corner_26)
        if isHiddenRequired{
            self.alertTypeSecondBtn.isHidden = true
        }else{
            self.alertTypeSecondBtn.isHidden = false
        }
        self.setNavigationBarHidden(true)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
    }
    
    //MARK: IBActions.
    @IBAction func firstBtnAction(_ sender: UIButton) {
        self.dismiss(animated: true){
            self.firstBtnClosure()
        }
    }
    @IBAction func backBtnAction(_ sender: UIButton) {
        if UserDefaults.userRole == "Guest"{
            self.secondBtnClosure()
        }else{
        }
    }
    
    @IBAction func alertSecondAction(_ sender: UIButton) {
        self.dismiss(animated: true){
            self.secondBtnClosure()
        }
    }
}
