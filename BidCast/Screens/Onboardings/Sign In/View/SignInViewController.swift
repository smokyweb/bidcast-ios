//
//  SignInViewController.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//

import UIKit
import SVProgressHUD
import Security
import FittedSheets
import IQKeyboardManagerSwift
//import OneSignalFramework

//MARK: LoginTableRow
enum LoginTableRow: Int, CaseIterable {
    case banner
    case emailField
    case passwordField
    case rememberMe
    case SignInBtn
    case createAccTemOfService
    
    func numberOfRows(data: [LoginTableRow: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}


class SignInViewController: UIViewController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var signTblView: UITableView!
    
    //MARK: Properties.
   var SignInEmail = ""
    var SignInpassword = ""
    var firstName  = ""
    var lastName  = ""
    var address = ""
    var email  = ""
    var zipCode = ""
    var password  = ""
    var conFirmPassowrd  = ""
    var platform = "iOS"
    var isSignUpSelected = false
    var rememberMeSwitch:Bool?
    var signInviewModel = SignInViewModel()
    
    
    //MARK: sectionData.
    var signInSectionData: [LoginTableRow: Int] = [
        .banner : 1,
        .emailField : 1,
        .passwordField : 1,
        .rememberMe : 1,
        .SignInBtn : 1,
        .createAccTemOfService : 1
    ]
    
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViewModel()
        self.configureTableView()
        self.signTblView.reloadData()
        self.getUserDetails()

    }

    //MARK: initViewModel.
    func initViewModel() {
        signInviewModel.userDelegate = self
    }
    
    //MARK: configureTableView.
    private func configureTableView(){
        self.signTblView.delegate = self
        self.signTblView.dataSource = self
        self.signTblView.configTblView(bgColor: .white)
        
        //register cells
        let cellIds = [AppBannerCell.identifier,
                       AppHeaderCell.identifier,
                       TextFieldCell.identifier,
                       SubmitCell.identifier,
                       SignUpTodayCell.identifier,RemberMeCell.identifier,LabelCell.identifier,TextFieldWithLabelCell.identifier]
        signTblView.registerCells(for: cellIds)
        
    }
    
    //MARK: submit
    private func submit(){
        self.view.endEditing(true)
        if self.SignInEmail == "" {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyEmail)
        }else if self.SignInpassword == "" {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyPassword)
        }
        else{
            if Reachability.isConnectedToNetwork() {
                //sign in
                SVProgressHUD.show()
                let signParam = SignInRequest(email: self.SignInEmail, password: self.SignInpassword)
                self.signInviewModel.signIn(parameters: signParam)
            }
            else {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
            rememberUserCredentials()
            self.view.endEditing(true)
            
        }
    }

}

//MARK: UITableViewDelegate,UITableViewDataSource
extension SignInViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LoginTableRow.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = LoginTableRow.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for LoginTableRow")
        }
        
        switch rowType {
        case .banner:
            let cell = signTblView.dequeueCell(with: AppBannerCell.self)
            return cell
        case .emailField:
            let cell = signTblView.dequeueCell(with: TextFieldCell.self)
            cell.imgIconOlt.image = UIImage(named: "ic_mail")
            cell.textFieldOlt.text = nil
            if self.SignInEmail != "" {
                cell.textFieldOlt.text = SignInEmail
            }
            else  {
                cell.textFieldOlt.placeholder = AppString.Placeholder.emailAddress
            }
            //                cell.textFieldOlt.text = ""
            cell.textFieldOlt.isSecureTextEntry = false
            cell.titleLblOlt.text = AppString.Title.email
            cell.textFieldOlt.keyboardType = .emailAddress
            cell.eyeBtnOlt.isHidden = true
            if self.rememberMeSwitch ?? false{
                cell.textFieldOlt.text = self.SignInEmail
            }else{
                cell.textFieldOlt.placeholder = AppString.Placeholder.emailAddress
            }
            cell.entertext = {  [weak self] text in
                self?.SignInEmail = text.text ?? ""
            }
            return cell
            
        case .passwordField:
            let cell = signTblView.dequeueCell(with: TextFieldCell.self)
            cell.imgIconOlt.image = UIImage(named: "ic_lockClosed")
            cell.textFieldOlt.text = nil
            if self.SignInpassword != "" {
                cell.textFieldOlt.text = SignInpassword
            }
            else  {
                cell.textFieldOlt.placeholder = AppString.Placeholder.password
            }
            //                cell.textFieldOlt.text = ""
            cell.titleLblOlt.text = AppString.Title.password
            cell.eyeBtnOlt.isHidden = false
            cell.textFieldOlt.isSecureTextEntry = true
            if self.rememberMeSwitch ?? false{
                cell.textFieldOlt.text = self.SignInpassword
            }else{
                cell.textFieldOlt.placeholder = AppString.Placeholder.password
            }
            cell.didTapForgotPassClosure = { [weak self] sender in
                guard let self = self else { return }
                self.pushVC(with: ForgetPasswordViewController.self, storyboardName: .onboardings)
            }
            cell.entertext = { [weak self] text in
                self?.SignInpassword = text.text ?? ""
            }
            return cell
        case .rememberMe:
            let cell = signTblView.dequeueCell(with: RemberMeCell.self)
            if self.rememberMeSwitch ?? false{
                cell.isRemembered = self.rememberMeSwitch ?? false
            }
            cell.remmeber = { sender in
                self.rememberMeSwitch = sender
            }
            cell.didTapForgot = { sender in
                self.pushVC(with: ForgetPasswordViewController.self, storyboardName: .onboardings)
                
            }
            return cell
            
        case .SignInBtn:
            let cell = signTblView.dequeueCell(with: SubmitCell.self)
            cell.contentOuterViewoLt.backgroundColor = .white
            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.signIn)
            cell.didTapSum = { [weak self] sender in
                guard let self = self else { return }
                self.submit()
            }
            return cell
        case .createAccTemOfService:
            let cell = signTblView.dequeueCell(with: SignUpTodayCell.self)
            cell.didTapSignUpClosure = {  [weak self] sender in
                guard let self = self else { return }
                self.pushVC(with: SignUpViewController.self, storyboardName: .onboardings)
                
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let rowType = LoginTableRow.allCases[safe: indexPath.row] else {
                fatalError("Invalid index for LoginTableRow")
            }
            switch rowType {
            case .banner:
                return Const.Height.banner
            case .rememberMe:
                return Const.Height.rememberMe
            case .emailField:
                return Const.Height.AutomaticDimension
            case .passwordField:
                return Const.Height.AutomaticDimension
            case .SignInBtn:
                return Const.Height.submitBtn
            case .createAccTemOfService:
                return Const.Height.signUpNow
            }
        }
    }


//MARK: - Model Management
extension SignInViewController : UserServices {
    
    func showError(error: String) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
    
    func reloadData() {
        SVProgressHUD.dismiss()
        self.sucessSignInSignUp()
    }
}

//MARK: - success API Call
extension SignInViewController {
    private func sucessSignInSignUp() {
    
            //MARK: signInviewModel.
            if self.signInviewModel.requestType == .signIn {
                if let dict = self.signInviewModel.signInDict {
                    let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                    switch statusType {
                    case .success:
                        //success API Response
                        SVProgressHUD.dismiss()
                        IAPManager.shared.removeAllUnfinishedTransactions()
                        self.saveUserDetails(data: self.signInviewModel.signInDict?.data)
                        self.signInviewModel.requestType = .none
                        sceneDel.navigateToLandingScreen()
                    case .failure:
                        SVProgressHUD.dismiss()
                        Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                    default:
                        SVProgressHUD.dismiss()
                        Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                    }
                }
            }
    }
}

//MARK: SignInDataModel.
extension SignInViewController {
    func saveUserDetails(data: SignInDataModel?) {
        guard let userData = data else {
            debugLog("User Details not found")
            return
        }
        //name,
        UserDefaults.name = userData.name ?? ""
        //first name
        UserDefaults.firstName = userData.firstName ?? ""
        //last name
        UserDefaults.lastName = userData.lastName ?? ""
        //role_id
        UserDefaults.roleId = userData.roleID ?? 0
        //email
        UserDefaults.email = userData.email ?? ""
        
        UserDefaults.userId = userData.id ?? 0
        //token
        UserDefaults.accessToken = userData.token
        
        sceneDel.navigateToLandingScreen()
        
    }
    
    //MARK: remember me work
    func getUserDetails() {
        // Retrieve stored "Remember Me" preference
        rememberMeSwitch = UserDefaults.rememberMe
        // Retrieve and populate stored credentials
        self.SignInEmail = UserDefaults.username
        self.SignInpassword = UserDefaults.password //TODO: Password should not be save in userdefaults

        debugLog("email--", UserDefaults.username)
        debugLog("password--", UserDefaults.password)
    }
    

    func rememberUserCredentials() {
        if rememberMeSwitch ?? false {
            UserDefaults.rememberMe = true
            UserDefaults.username = self.SignInEmail
            UserDefaults.password = self.SignInpassword
        } else {
            UserDefaults.rememberMe = false
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.userName)
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.password)
        }
    }
}
