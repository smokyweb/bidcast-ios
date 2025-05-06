//
//  OtpViewController.swift
//  BidCast
//
//  Created by JAM-E-221 on 02/09/24.
//

import UIKit
import SVProgressHUD

enum OtpSection: CaseIterable {
    case AppHeaderCell
    case LabelCell
    case otpCell
    case tooManyAttemptLbl
    case SubmitCell
    case sendAgainBtnCell
}

enum OTpStatus {
    case sentOTP
    case incorrect
}

class OtpViewController: UIViewController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var otpTableView: UITableView!
    @IBOutlet weak var headerViewOlt: HeaderView!
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    
    //MARK: Properties.
    var isOtpCorrect = false
    //    var otp  = ""
    var enteredOTP = ""
    var email = ""
    var resendOTPModel = ForgetPasswordViewModel()
    var verifyOTPViewModel = OtpViewModel()
    var otpStatus: OTpStatus = .sentOTP
    
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.initViewModel()
    }
    
    //MARK: Configure views Method.
    private func configureTableView(){
        self.otpTableView.delegate = self
        self.otpTableView.dataSource = self
        self.otpTableView.configTblView(bgColor: .white)
        
        //register cells
        let cellIds = [ AppHeaderCell.identifier,
                        LabelCell.identifier,
                        SubmitCell.identifier,
                        SecondBtnCell.identifier,IncorrectPasswordCell.identifier,TextFieldCell.identifier ]
        otpTableView.registerCells(for: cellIds)
        self.configureHeaderView()
    }
    
    //MARK: configureView.
    private func configureHeaderView() {
        self.headerViewOlt.headerViewSetup(leftButtonHidden: false, headerName: AppString.VCName.enterCode,leftButtonAction: didTabBack)
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotch : Const.Height.notNotch
        headerViewOlt.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }
    
    //MARK: didTabBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
    
    //MARK: initViewModel.
    func initViewModel() {
        resendOTPModel.forgetPasswordDelegate = self
        verifyOTPViewModel.userDelegate = self
    }
    
    
    //MARK: submit.
    private func submit(){
        self.view.endEditing(true)
        if self.enteredOTP == "" {
            Utilities.sharedInstance.showToast(source: self, message: "")
        }else if Reachability.isConnectedToNetwork(){
            //TODO: Remove this code when using the API.
            self.pushVC(with: NewPasswordViewController.self, storyboardName: .onboardings)
            
            //TODO: Open this code when using the API.
//            DispatchQueue.main.async {
//                debugLog(self.enteredOTP)
//                SVProgressHUD.show()
//                let otpRequest = VerifyOtpRequest(email: self.email, code: Int(self.enteredOTP)!)
//                self.verifyOTPViewModel.verifyOTP(parameters: otpRequest)
//            }
        }else{
            Utilities.sharedInstance.showToast(source: self, message: "")
        }
    }
}


//MARK: UITableViewDelegate,UITableViewDataSource.
extension OtpViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OtpSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = OtpSection.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for OtpSection")
        }
        
        switch rowType {
        case .AppHeaderCell:
            let cell = otpTableView.dequeueCell(with: AppHeaderCell.self)
            cell.titleOlt.text = AppString.Header.enterCode
            return cell
        case .LabelCell:
            let cell = otpTableView.dequeueCell(with: LabelCell.self)
            cell.titleOlt.text = AppString.Description.enterCodeSent
            return cell
        case .otpCell:
            let cell = otpTableView.dequeueCell(with: TextFieldCell.self)
            cell.titleLblOlt.text = AppString.Title.code
            cell.setupTextField(placeHolder : AppString.Placeholder.enterCode,keyboardType : .numberPad,isEyeHidden : true)
            cell.imgIconOlt.image = UIImage(named: "ic_Shield")
            cell.entertext = { [weak self] text in
                self?.enteredOTP = text.text ?? ""
            }
            cell.selectionStyle = .none
            return cell
        case .tooManyAttemptLbl:
            let cell = otpTableView.dequeueCell(with: LabelCell.self)
            if isOtpCorrect == false{
                cell.titleOlt.text = ""
            }else{
                cell.titleOlt.text = AppString.Description.tooManyAttempt
                cell.txtColor = AppColor.danger ?? .danger
            }
            return cell
        case .SubmitCell:
            let cell = otpTableView.dequeueCell(with: SubmitCell.self)
            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.submit)
            cell.didTapSum = { [weak self] sender in
                guard let self = self else { return }
                self.submit()
            }
            return cell
        case .sendAgainBtnCell:
            let cell = otpTableView.dequeueCell(with: SecondBtnCell.self)
            cell.exitBtn.setupButton(title: AppString.BtnTitle.resendCode)
            cell.didTapExit = { [weak self] sender in
                guard let self = self  else { return }
                SVProgressHUD.show()
                
                //TODO: Open this code when using the API.
//                if self.isOtpCorrect == false {
//                    self.resendOTPModel.forgetPassword(parameters: ForgetRequest(email: self.email ?? ""))
//                }
                   
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = OtpSection.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for OtpSection")
        }
        
        switch rowType {
        case .AppHeaderCell:
            return Const.Height.header
        case .LabelCell:
            return Const.Height.AutomaticDimension
        case .otpCell:
            return Const.Height.otpCell
        case .tooManyAttemptLbl:
            return isOtpCorrect ? Const.Height.AutomaticDimension : Const.Height.zero
        case .SubmitCell:
            return Const.Height.submitBtn
        case .sendAgainBtnCell:
            return Const.Height.submitBtn
        }
    }
}

//MARK: - sucessForgetPassword.
extension OtpViewController: UserServices {
    func showError(error: String) {
        //handle error
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
    
    func reloadData() {
        //resendOTPModel
        if self.resendOTPModel.requestType == .forgetPassword {
            if let dict = self.resendOTPModel.forgetPasswordDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    SVProgressHUD.dismiss()
                    DispatchQueue.main.async {
                        Utilities.sharedInstance.showToast(source: self, message: Toast.Message.OTPResent )
                    }
                case .failure:
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.isOtpCorrect = true
                        self.otpTableView.reloadData()
                    }
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
        
        //verifyOTPViewModel
        if self.verifyOTPViewModel.requestType == .verifyOtp {
            if let dict = self.verifyOTPViewModel.OTPDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    SVProgressHUD.dismiss()
                    DispatchQueue.main.async {
                        //manage OTP Verify
                        self.pushVCWithValue(with: NewPasswordViewController.self, storyboardName: .onboardings) { vc in
                            vc.email = self.email
                        }
                    }
                case .failure:
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
    }
}







