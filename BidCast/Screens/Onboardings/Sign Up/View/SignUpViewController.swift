//
//  SignUpViewController.swift
//  BidCast
//
//  Created by JAM-E-328 on 31/08/24.
//

import UIKit
import SVProgressHUD
import FittedSheets

enum SignUpSection: Int, CaseIterable {
    case headingTitle
    case formData
    case continueBtn
    
    func numberOfRows(data: [SignUpSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

enum formData : Int,CaseIterable{
    case firstName
    case lastName
    case email
    case password
    case confirmPass
    case referralCode
    var title : String{
        switch self {
        case .firstName:
            return AppString.Title.firstName
        case .lastName:
            return  AppString.Title.lastName
        case .email:
            return AppString.Title.email
        case .password:
            return AppString.Title.password
        case .confirmPass:
            return AppString.Title.confirmPass
        case .referralCode:
            return "Referral code (optional)"
        }
    }
    var placeholder: String {
        switch self {
        case .firstName:
            return AppString.Placeholder.firstName
        case .lastName:
            return AppString.Placeholder.lastName
        case .email:
            return AppString.Placeholder.email
        case .password:
            return AppString.Placeholder.password
        case .confirmPass:
            return AppString.Placeholder.confirmPass
        case .referralCode:
            return "Enter referral code"
        }
    }
}

class SignUpViewController: UIViewController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var signUpTblView: UITableView!
    @IBOutlet weak var headerView: HeaderView!
    
    //MARK: Properties.
    var firstName  = ""
    var lastName  = ""
    var email  = ""
    var password  = ""
    var conFirmPassowrd  = ""
    /// iOS Parity P0.5 (2026-04-23): optional referral code that gets
    /// forwarded as `referral_code` multipart in the register request.
    /// Can be pre-filled by `DeepLinkRouter` when the user taps a
    /// `/invite/<code>` universal link.
    var referralCode = ""
    var roleID  = 2
 
    //MARK: sectionData.
    var sectionData: [SignUpSection: Int] = [
        .headingTitle : 1,
        .formData : 6,
        .continueBtn : 1
    ]

    var viewModel = SignUpViewModel()
    var deviceDetailViewModel = DeviceDetailsViewModel()
    
    //MARK: ViewLife Cycle Methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.configureView()
        initViewModel()
    }
    
    //MARK: configureTableView.
    private func configureTableView(){
        self.signUpTblView.delegate = self
        self.signUpTblView.dataSource = self
        self.signUpTblView.configTblView(bgColor : .pearl)
        //register cell
        let cellIds = [AppBannerCell.identifier, AppHeaderCell.identifier, TextFieldCell.identifier, SubmitCell.identifier, SignUpTodayCell.identifier, SecondBtnCell.identifier,LabelCell.identifier,TextFieldWithLabelCell.identifier]
        signUpTblView.registerCells(for: cellIds)
    }
    
    //MARK: configureView.
    private func configureView() {
        self.headerView.headerViewSetup(leftButtonHidden: false, headerName: AppString.VCName.createYourAccount,leftButtonAction: didTabBack)
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }
    
    //MARK: initViewModel.
    func initViewModel() {
        viewModel.userDelegate = self
    }
    
    //MARK: didTabBack.
    @objc func didTabBack() {
        self.goToBack()
    }
 
    //MARK: submit.
    private func submit(){
        
        self.view.endEditing(true)
        if self.firstName == "" {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyFirstName)
        }
        else if self.lastName == "" {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyLastName)
        }
        else if self.email == "" {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyEmail)
        }
        else if self.password == "" {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyPassword)
        }
        else if self.conFirmPassowrd == "" {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyConfirmPassword)
        }
        else if self.password != self.conFirmPassowrd {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.passwordsDoNotMatch)
        }
        else if Reachability.isConnectedToNetwork(){
            DispatchQueue.main.async {
                // iOS Parity P0.5: forward the optional referral_code.
                let trimmedReferral = self.referralCode
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let signUpParam = SignUpRequest(
                    firstName: self.firstName,
                    lastName: self.lastName,
                    email: self.email,
                    password: self.password,
                    passwordConf: self.conFirmPassowrd,
                    roleID: self.roleID,
                    referralCode: trimmedReferral.isEmpty ? nil : trimmedReferral
                )
                debugLog(signUpParam)
                SVProgressHUD.show()
                self.viewModel.signUp(parameters: signUpParam)
            }
        }else{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
        }
    }
}


//MARK: UITableViewDelegate,UITableViewDataSource.
extension SignUpViewController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return SignUpSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SignUpSection(rawValue: section) else { return 0 }
        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let secType = SignUpSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for SignUpSection")
        }
        switch secType {
        case .headingTitle:
            let cell = signUpTblView.dequeueCell(with: AppHeaderCell.self)
            cell.titleOlt.text = AppString.Header.createYourAccount
            cell.outerViewOlt.backgroundColor = .white
            return cell
        case .formData:
            guard let rowType = formData.allCases[safe: indexPath.row] else {
                fatalError("Invalid index for SignUpSection")
            }
            let options : [formData] = formData.allCases
            switch rowType{
            case .firstName:
                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
                cell.titleOlt.text = options[indexPath.row].title
                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
                cell.eyeBtnOlt.isHidden = true
                cell.entertext = { [weak self] text in
                    guard let self = self else { return }
                    self.firstName = text.text ?? ""
                }
                cell.selectionStyle = .none
                return cell
            case .lastName:
                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
                cell.titleOlt.text = options[indexPath.row].title
                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
                cell.eyeBtnOlt.isHidden = true
                cell.entertext = { [weak self] text in
                    guard let self = self else { return }
                    self.lastName = text.text ?? ""
                }
                cell.selectionStyle = .none
                return cell
            case .email:
                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
                cell.titleOlt.text = options[indexPath.row].title
                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
                cell.eyeBtnOlt.isHidden = true
                cell.entertext = { [weak self] text in
                    guard let self = self else { return }
                    self.email = text.text ?? ""
                }
                cell.selectionStyle = .none
                return cell
            case .password:
                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
                cell.titleOlt.text = options[indexPath.row].title
                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
                cell.eyeBtnOlt.isHidden = true
                cell.entertext = { [weak self] text in
                    guard let self = self else { return }
                    self.password = text.text ?? ""
                }
                cell.selectionStyle = .none
                return cell
            case .confirmPass:
                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
                cell.titleOlt.text = options[indexPath.row].title
                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
                cell.eyeBtnOlt.isHidden = true
                cell.entertext = { [weak self] text in
                    guard let self = self else { return }
                    self.conFirmPassowrd = text.text ?? ""
                }
                cell.selectionStyle = .none
                return cell
            case .referralCode:
                // iOS Parity P0.5: optional referral code input. May be
                // pre-filled by a deep-link into this VC.
                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
                cell.titleOlt.text = options[indexPath.row].title
                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
                cell.textFieldOlt.text = self.referralCode
                cell.textFieldOlt.autocapitalizationType = .allCharacters
                cell.textFieldOlt.autocorrectionType = .no
                cell.eyeBtnOlt.isHidden = true
                cell.entertext = { [weak self] text in
                    guard let self = self else { return }
                    self.referralCode = text.text ?? ""
                }
                cell.selectionStyle = .none
                return cell
            }
        case .continueBtn:
            let cell = signUpTblView.dequeueCell(with: SubmitCell.self)
            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.continues)
            cell.didTapSum = { [weak self] sender in
                guard let self = self else { return }
                self.submit()
            }
            return cell
            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let secType = SignUpSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for LoginTableRow")
        }
        switch secType {
        case .headingTitle:
            return Const.Height.header
        case .formData:
            return Const.Height.AutomaticDimension
        case .continueBtn:
            return Const.Height.submitBtn
        }
    }
    
}

//MARK: succesuccessfullyAccCreatedAlert
extension SignUpViewController {
    func succesuccessfullyAccCreatedAlert() {
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithSingleButtonViewController") as! AlertWithSingleButtonViewController
        vc.image = UIImage(named: "ic_Success")
        vc.content = AppString.Alert.successfullyAccCreated
        vc.heading = AppString.Header.success
        vc.firstBtnTitle = AppString.BtnTitle.login
        vc.isHiddenRequired = true
        var options = SheetOptions()
        options.shrinkPresentingViewController = false
        options.pullBarHeight = Height_30
        vc.firstBtnClosure = {
            self.dismiss(animated: true)
            //go to welcome page
            sceneDel.navigateToLandingScreen()
        }
        let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.40) : .percent(0.50)], options: options)
        sheet.cornerRadius = Corner_32
        sheet.overlayColor = .black.withAlphaComponent(0.9)
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = true
        sheet.gripSize = CGSize(width: Width_50, height: Height_0)
        self.present(sheet, animated: true, completion: nil)
    }
}

// APi Delegate management
extension SignUpViewController: UserServices {
    func reloadData() {
        debugLog("reload data")
        sucessSignUp()
    }
    
    func showError(error: String) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()

            // QA-FIX (deleted-account signup): branch on error_type / message
            // so known failure modes get friendly, actionable copy instead of
            // raw backend strings in a toast.
            let apiError = self.viewModel.lastSignUpApiError
            let errType = apiError?.error_type.uppercased() ?? ""
            let rawMsg = (apiError?.message ?? error).trimmingCharacters(in: .whitespacesAndNewlines)
            let lowerMsg = rawMsg.lowercased()

            if errType == "ACCOUNT_DELETED"
                || lowerMsg.contains("account was deleted")
                || lowerMsg.contains("account has been deleted") {
                Utilities.sharedInstance.showAlertController(
                    title: "Account Deleted",
                    message: "This account was previously deleted and cannot be reused. Please contact support to restore it, or sign up with a different email.",
                    sourceViewController: self)
                return
            }

            if errType == "EMAIL_TAKEN"
                || lowerMsg.contains("has already been taken")
                || lowerMsg.contains("already been registered")
                || lowerMsg.contains("email already") {
                Utilities.sharedInstance.showAlertController(
                    title: "Email Already Registered",
                    message: "An account with this email already exists. Try logging in or use \"Forgot Password\" to reset it.",
                    sourceViewController: self)
                return
            }

            // Fallback: show whatever the backend sent, or a friendly signup
            // fallback instead of the original silent toast with an empty message.
            let finalMessage = rawMsg.isEmpty
                ? "Signup failed. Please try again or contact support if the problem continues."
                : rawMsg
            Utilities.sharedInstance.showToast(source: self, message: finalMessage)
        }
    }
}

//MARK: - Api Call and its success response
extension SignUpViewController {
    
    //MARK: sucessSignUp.
    private func sucessSignUp() {
        SVProgressHUD.dismiss()
        if viewModel.signUpDict?.status == "success" {
            DispatchQueue.main.async {
                self.viewModel.requestType = .none
                // QA-FIX (MC task cmolwmp0i00f64315lqq37lv3): Android
                // CreateAccountFragment auto-logs the user in after a
                // successful signup and navigates straight to interest
                // selection. Mirror that here when the API returns a token.
                let data = self.viewModel.signUpDict?.data
                if let token = data?.token, !token.isEmpty {
                    self.persistSignedUpUser(data: data)
                    self.navigateToInterestsAfterSignup()
                } else {
                    // No token in response — fall back to the legacy success
                    // alert that prompts login.
                    self.succesuccessfullyAccCreatedAlert()
                }
            }
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: self.viewModel.signUpDict?.message ?? "")
            }
        }
    }

    /// QA-FIX (MC task cmolwmp0i00f64315lqq37lv3): persist the freshly-signed-up
    /// user to UserDefaults so subsequent authenticated APIs (interests,
    /// profile) hit the wire with the new token. Mirrors
    /// SignInViewController.saveUserDetails minus the landing-screen swap.
    private func persistSignedUpUser(data: SignUpDataModel?) {
        guard let userData = data else { return }
        UserDefaults.name = userData.name ?? ""
        UserDefaults.firstName = userData.firstName ?? ""
        UserDefaults.lastName = userData.lastName ?? ""
        UserDefaults.roleId = userData.roleID ?? 0
        UserDefaults.email = userData.email ?? ""
        UserDefaults.userId = userData.id ?? 0
        UserDefaults.accessToken = userData.token
    }

    /// QA-FIX (MC task cmolwmp0i00f64315lqq37lv3): land the user directly on
    /// the Interests screen after signup, then promote it to the root once
    /// they finish. Until a dedicated first-time-login flag exists, we just
    /// push the existing InterestsViewController onto the current nav.
    private func navigateToInterestsAfterSignup() {
        let interests = InterestsViewController()
        if let nav = self.navigationController {
            nav.pushViewController(interests, animated: true)
        } else {
            // Defensive fallback: if there's no nav stack, swap to the main
            // tab bar via the scene delegate so the user lands somewhere
            // reasonable.
            sceneDel.navigateToLandingScreen()
        }
    }
}
