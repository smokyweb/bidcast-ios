//
//  AlertWithSingleButtonViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-328 on 14/12/24.
//

import UIKit

class AlertWithSingleButtonViewController: UIViewController {
    
    //MARK: IBOutlets.
    @IBOutlet weak var outerview: UIView!
    @IBOutlet weak var alertTypeimgView: UIImageView!
    @IBOutlet weak var alertTypeHeadingLbl: UILabel!
    @IBOutlet weak var alertTypeContentLbl: UILabel!
    @IBOutlet weak var alertTypeFirstBtn: UIButton!
    
    
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
        
        alertTypeimgView.image = image
        alertTypeHeadingLbl.text = heading
        alertTypeContentLbl.text = content
        alertTypeFirstBtn.setupButton(title: firstBtnTitle,titleColor: titleColor1,borderWidth: Width_01, borderColor: borderColor1)
        
        alertTypeFirstBtn.makeCornerRounded(ofSize: Corner_26)
        self.setNavigationBarHidden(true)
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.7)
//        addTopCorner(to: outerview)

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
