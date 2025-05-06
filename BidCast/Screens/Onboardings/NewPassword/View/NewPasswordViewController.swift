//
//  NewPasswordViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 02/09/24.
//

import UIKit
import FittedSheets
import SVProgressHUD

enum NewPassSection: Int,CaseIterable {
    case forgotHeader
    case passStatus
    case oldPassword
    case newPassword
    case confirmPassword
    case submitCell
    
    func numberOfRows(data: [NewPassSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class NewPasswordViewController: UIViewController {

    // MARK: IBOutlets.
    @IBOutlet weak var passWordTbl: UITableView!
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    
    @IBOutlet var submitBtn: UIButton!
    
    //MARK: Properties,
    var isComeFromUpdatePass = false
    var isOtpCorrect = false
    var oldPassword  = ""
    var password  = ""
    var conFirmPassowrd  = ""
    var email = ""
    var otp = ""
    var viewModel = NewPasswordViewModel()
    
    var sectionData: [NewPassSection: Int] = [
        .forgotHeader: 1, // Single row for the welcome header
        .oldPassword : 1,
        .passStatus: 1,
        .newPassword: 1,
        .confirmPassword : 1,
    ]
    
    //MARK: ViewLife Cycle Method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        initViewModel()
    }
    
    
    //MARK: Configure views Method.
    private func configureTableView(){
        self.passWordTbl.delegate = self
        self.passWordTbl.dataSource = self
        self.passWordTbl.configTblView(bgColor: .white)
        let cellIds = [LabelCell.identifier,AppHeaderCell.identifier,TextFieldCell.identifier,SubmitCell.identifier,SecondBtnCell.identifier,SignUpTodayCell.identifier]
        passWordTbl.registerCells(for: cellIds)
        self.configureView()
    }
    
    //MARK: configureView
    private func configureView() {
        self.headerView.headerViewSetup(leftButtonHidden: false,
                                        headerName: isComeFromUpdatePass ? AppString.VCName.updatePassword : AppString.VCName.newPassword,
                                        leftButtonAction: didTabBack)
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotch : Const.Height.notNotch
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }
    
    //MARK: initViewModel
    func initViewModel() {
        viewModel.userDelegate = self
    }

    
    //MARK: didTabBack
    @objc private func didTabBack(){
        //TODO: needed to check navigation stack
        self.goToBack()
    }
    
    //MARK: - validatePasswordInputs.
    private  func validatePasswordInputs() -> String? {
        if password.isEmpty {
            return AppString.Validation.enterPassword
        } else if conFirmPassowrd.isEmpty {
            return AppString.Validation.enterConfirmPassword
        } else if password != conFirmPassowrd {
            return AppString.Validation.passwordMismatch
        }
        return nil
    }
    
    //MARK: - submitUpdatePass.
    private func submitUpdatePass() {
        self.view.endEditing(true)
        
        if let validationError = validatePasswordInputs() {
            Utilities.sharedInstance.showToast(source: self, message: validationError)
            return
        }
        
        guard Reachability.isConnectedToNetwork() else {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            return
        }
        SVProgressHUD.show()
        let updatePassword = UpdatePasswordRequest(current_password: self.oldPassword, password: self.password, password_confirmation: self.conFirmPassowrd)
        self.viewModel.updatePassword(parameters: updatePassword)
    }
    
    //MARK: - submitNewPass.
    private func submitNewPass() {
        self.view.endEditing(true)
        
        if let validationError = validatePasswordInputs() {
            Utilities.sharedInstance.showToast(source: self, message: validationError)
            return
        }
        guard Reachability.isConnectedToNetwork() else {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            return
        }
        
        SVProgressHUD.show()
        let newPasswordRequest = newPasswordRequest(email: self.email, password: self.password, password_confirmation: self.conFirmPassowrd)
        self.viewModel.newPassword(parameters: newPasswordRequest)
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource.
extension NewPasswordViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return NewPassSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = NewPassSection(rawValue: section) else { return 0 }
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = NewPassSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for NewPassSection")
        }
        
        switch rowType {

        case .forgotHeader:
            let cell = passWordTbl.dequeueCell(with: AppHeaderCell.self)
            cell.titleOlt.text = isComeFromUpdatePass ? AppString.Title.updatePassword : AppString.Header.newPassword
            return cell
        case .passStatus:
            let cell = passWordTbl.dequeueCell(with: LabelCell.self)
            cell.titleOlt.text = isComeFromUpdatePass ? AppString.Description.successUpdatePassword : AppString.Description.successNewPassword
            return cell
        case .oldPassword:
            let cell = passWordTbl.dequeueCell(with: TextFieldCell.self)
            cell.imgIconOlt.image = UIImage(named: "ic_lockClosed")
            cell.titleLblOlt.text = AppString.Title.oldPassword
            cell.setupTextField(placeHolder : AppString.Placeholder.oldpassword,isEyeHidden : false,isSecureTextEntry: true)
            cell.entertext = { [weak self] text in
                self?.oldPassword = text.text ?? ""
            }
            return cell
        case .newPassword:
            let cell = passWordTbl.dequeueCell(with: TextFieldCell.self)
            cell.imgIconOlt.image = UIImage(named: "ic_lockClosed")
            cell.titleLblOlt.text = AppString.Title.password
            cell.setupTextField(placeHolder : AppString.Placeholder.password,isEyeHidden : false,isSecureTextEntry: true)
            cell.entertext = { [weak self] text in
                self?.password = text.text ?? ""
            }
            return cell
        case .confirmPassword:
            let cell = passWordTbl.dequeueCell(with: TextFieldCell.self)
            cell.titleLblOlt.text = AppString.Title.confirmPassword
            cell.imgIconOlt.image = UIImage(named: "ic_lockClosed")
            cell.setupTextField(placeHolder : AppString.Placeholder.confirmPassword,isEyeHidden : false,isSecureTextEntry: true)
            cell.entertext = { [weak self] text in
                self?.conFirmPassowrd = text.text ?? ""
            }
            return cell
        case .submitCell:
            let cell = passWordTbl.dequeueCell(with: SubmitCell.self)
            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.submit)
            cell.didTapSum = { sender in
                self.isComeFromUpdatePass ? self.submitUpdatePass() : self.submitNewPass()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType =  NewPassSection.allCases[safe: indexPath.section]  else {
            fatalError("Invalid index for NewPassSection")
        }
        switch rowType {
        case .forgotHeader:
            return Const.Height.header
        case .passStatus:
            return Const.Height.AutomaticDimension
        case .oldPassword:
            return isComeFromUpdatePass ? Const.Height.AutomaticDimension : Const.Height.zero
        case .newPassword:
            return Const.Height.AutomaticDimension
        case .submitCell:
            return Const.Height.submitBtn
        case .confirmPassword:
            return Const.Height.AutomaticDimension
        }
    }
}

//MARK: - Model Management
extension NewPasswordViewController: UserServices {
    func showError(error: String) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
    
    func reloadData() {
        //MARK: updatePassword.
        if self.viewModel.requestType == .updatePassword {
            if let dict = self.viewModel.updatePasswordDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    SVProgressHUD.dismiss()
                    self.sucessForgetPassword()
                    viewModel.requestType = .none
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }else{
            SVProgressHUD.dismiss()
        }
        
        //MARK: newPassword.
        if self.viewModel.requestType == .newPassword {
            if let dict = self.viewModel.newPasswordDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    SVProgressHUD.dismiss()
                    self.sucessForgetPassword()
                    viewModel.requestType = .none
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
        else{
            SVProgressHUD.dismiss()
        }
    }
}

//API Call Success
extension NewPasswordViewController {
    //MARK: - sucessForgetPassword.
    private func sucessForgetPassword() {
        let successMessage = isComeFromUpdatePass ? "Password Updated Successfully" : "Your password has been changed, you may now login with your new info."
        let errorMessage = isComeFromUpdatePass ? self.viewModel.updatePasswordDict?.message : self.viewModel.newPasswordDict?.message
        
        let status = isComeFromUpdatePass ? viewModel.updatePasswordDict?.status : viewModel.newPasswordDict?.status
        
        if status == status {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
                let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithSingleButtonViewController") as! AlertWithSingleButtonViewController
                vc.image = UIImage(named: "ic_Success")
                vc.content = successMessage
                vc.heading = AppString.Header.success
                vc.firstBtnTitle = AppString.BtnTitle.ok
            
                var options = SheetOptions()
                options.shrinkPresentingViewController = false
                options.pullBarHeight = Height_30

                vc.firstBtnClosure = {
                    self.dismiss(animated: true)
                    if self.isComeFromUpdatePass{
                        self.goToBack()
                    }else{
                        self.pushVC(with: SignInViewController.self, storyboardName: .onboardings)
                    }
                }
                let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.40) : .percent(0.50)], options: options)
                sheet.cornerRadius = Corner_32
                sheet.overlayColor = .black.withAlphaComponent(0.9)
                sheet.dismissOnPull = false
                sheet.dismissOnOverlayTap = true
                sheet.gripSize = CGSize(width: Width_50, height: Height_0)
                self.present(sheet, animated: true, completion: nil)
            }
        } else {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                Utilities.sharedInstance.showToast(source: self, message: errorMessage ?? "")
                self.isOtpCorrect = true
                self.passWordTbl.reloadData()
            }
        }
    }
}


