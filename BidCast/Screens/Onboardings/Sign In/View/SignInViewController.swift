//
//  SignInViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 26/12/24.
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
    case segment
    case emailField
    case passwordField
    case rememberMe
    case SignInBtn
    case createAccTemOfService
    
    func numberOfRows(data: [LoginTableRow: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}
//MARK: SignUpSection
enum SignUpSection: Int, CaseIterable {
    case banner
    case segment
    case formData
    case continueBtn
    
    func numberOfRows(data: [SignUpSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

enum formDataEnum : Int,CaseIterable{
    case firstName
    case lastName
    case email
    case zipCode
    case password
    case confirmPass
    var title : String{
        switch self {
        case .firstName:
            return AppString.Title.firstName
        case .lastName:
            return  AppString.Title.lastName
        case .email:
            return AppString.Title.email
        case .zipCode:
            return AppString.Title.zipCode
        case .password:
            return AppString.Title.password
        case .confirmPass:
            return AppString.Title.confirmPass
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
        case .zipCode:
            return  AppString.Placeholder.zipCode
        case .password:
            return AppString.Placeholder.password
        case .confirmPass:
            return AppString.Placeholder.confirmPass
        }
    }
    var image : String{
        switch self {
        case .firstName:
            return "ic_user"
        case .lastName:
            return "ic_user"
        case .email:
            return "mail"
        case .zipCode:
            return "ic_location"
        case .password:
            return "ic_lockClosed"
        case .confirmPass:
            return "ic_lockClosed"
        }
    }
}

enum segmentType : String {
    case signIn
    case signUp
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
    var signUpviewModel = SignUpViewModel()
    var signInviewModel = SignInViewModel()
    var segmentType: segmentType = .signIn
    
    //MARK: signUpSectionData.
    var signUpSectionData: [SignUpSection: Int] = [
        .banner : 1,
        .segment : 1,
        .formData : 6,
        .continueBtn : 1
    ]
    
    //MARK: sectionData.
    var signInSectionData: [LoginTableRow: Int] = [
        .banner : 1,
        .segment : 1,
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
        signUpviewModel.userDelegate = self
        reloadDataForSelectedSegment()
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
                       SignUpTodayCell.identifier,SegmentCell.identifier,RemberMeCell.identifier,LabelCell.identifier,TextFieldWithLabelCell.identifier]
        signTblView.registerCells(for: cellIds)
        
    }
    
    //MARK: submit
    private func submit(){
        switch segmentType {
        case .signIn:
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
        case .signUp:
            self.view.endEditing(true)
            if self.firstName == "" {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyFirstName)
            }
            else if self.lastName == "" {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyLastName)
            }
            else if self.lastName.count <= 2 {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.lastNameThreeChar)
            }
            else if self.email == "" {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyEmail)
            }
            else if self.zipCode == "" {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyZipCode)
            }
            else if self.password == "" {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyPassword)
            }
            else if self.conFirmPassowrd == "" {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyConfirmPassword)
            }
            else if self.password != self.conFirmPassowrd {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.passwordsDoNotMatch)
            }else{
                self.pushVCWithValue(with: PrivacyAndPolicyViewController.self, storyboardName: .more) { vc in
                    vc.isNavFrom = AppString.navigateFrom.signUp
                    vc.firstName = firstName
                    vc.lastName = lastName
                    vc.email = email
                    vc.zipCode = zipCode
                    vc.password = password
                    vc.conFirmPassowrd = conFirmPassowrd
                    UserDefaults.isAgreePrivacyPolicy = false
                    UserDefaults.isAgreeTermAndCondition = false
                }
            }
//            else
//            if Reachability.isConnectedToNetwork(){
//                DispatchQueue.main.async {
//                    let signUpParam = SignUpRequest(firstName: self.firstName,
//                                                    lastName: self.lastName,
//                                                    email: self.email,
//                                                    zipCode: self.zipCode,
//                                                    password: self.password,
//                                                    passwordConf: self.conFirmPassowrd)
//                    debugLog(signUpParam)
//                    SVProgressHUD.show()
//                    self.signUpviewModel.signUp(parameters: signUpParam)
//                }
//            }else{
//                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
//            }
        }
    }
    
    //MARK: reloadDataForSelectedSegment.
    private func reloadDataForSelectedSegment() {
        switch segmentType {
        case .signIn:
            signInSectionData = [
                .banner : 1,
                .segment : 1,
                .emailField : 1,
                .passwordField : 1,
                .rememberMe : 1,
                .SignInBtn : 1,
                .createAccTemOfService : 1
            ]
        case .signUp:
            signUpSectionData = [
                .banner : 1,
                .segment : 1,
                .formData : 6,
                .continueBtn : 1
            ]
        }
        // Reload the table view to reflect the changes
        signTblView.reload()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension SignInViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch segmentType{
        case .signIn:
            return 1
        case .signUp:
            return SignUpSection.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch segmentType{
        case .signIn:
            return LoginTableRow.allCases.count
        case .signUp:
            guard let sectionType = SignUpSection(rawValue: section) else { return 0 }
            debugLog("Rows in section:\(sectionType.numberOfRows(data: signUpSectionData))")
            return sectionType.numberOfRows(data: signUpSectionData)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch segmentType{
            
        case .signIn:
            guard let rowType = LoginTableRow.allCases[safe: indexPath.row] else {
                fatalError("Invalid index for LoginTableRow")
            }
            
            switch rowType {
            case .banner:
                let cell = signTblView.dequeueCell(with: AppBannerCell.self)
                return cell
            case .segment:
                let cell = signTblView.dequeueCell(with: SegmentCell.self)
                cell.segment.selectedIndex = 0
                cell.selectionStyle = .none
                cell.onSegmentChanged = { [weak self] selectedIndex in
                    debugLog("Selected Index Changed: \(selectedIndex)")
                    self?.segmentType = selectedIndex == 0 ? .signIn : .signUp
                    self?.reloadDataForSelectedSegment()
                }
                return cell
            case .emailField:
                let cell = signTblView.dequeueCell(with: TextFieldCell.self)
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
                    let storyboard = UIStoryboard(name: "Onboardings", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "ForgetPasswordViewController") as! ForgetPasswordViewController
                    self.navigationController?.pushViewController(vc, animated: true)
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
                    self.segmentType = .signUp
                    self.reloadDataForSelectedSegment()
                    
                }
                return cell
            }
        case .signUp:
            guard let secType = SignUpSection.allCases[safe: indexPath.section] else {
                fatalError("Invalid index for SignUpSection")
            }
//            firstName  = ""
//           lastName  = ""
//            address = ""
//            email  = ""
//            zipCode = ""
//            password  = ""
//            conFirmPassowrd  = ""
            switch secType {

            case .banner:
                let cell = signTblView.dequeueCell(with: AppBannerCell.self)
                return cell
            case .segment:
                let cell = signTblView.dequeueCell(with: SegmentCell.self)
                cell.segment.selectedIndex = 1
                debugLog("isSignUpSelected: \(isSignUpSelected)")
                cell.onSegmentChanged = { [weak self] selectedIndex in
                    debugLog("Selected Index Changed: \(selectedIndex)")
                    self?.segmentType = selectedIndex == 1 ? .signUp : .signIn
                    self?.reloadDataForSelectedSegment()
                }
                return cell
            case .formData:
                guard let rowType = formDataEnum.allCases[safe: indexPath.row] else {
                    fatalError("Invalid index for SignUpSection")
                }
                let options : [formDataEnum] = formDataEnum.allCases
                let signUp = options[indexPath.row]
                switch rowType{
                case .firstName:
                    let cell = signTblView.dequeueCell(with: TextFieldCell.self)
                    cell.textFieldOlt.text = nil
                    if self.firstName != "" {
                        cell.textFieldOlt.text = firstName
                    }
                    else  {
                        cell.textFieldOlt.placeholder = signUp.placeholder
                    }
                    cell.textFieldOlt.text = ""
                    cell.titleLblOlt.text = signUp.title
                    cell.imgIconOlt.image = UIImage(named: signUp.image)
                    cell.textFieldOlt.keyboardType = .alphabet
                    cell.textFieldOlt.autocapitalizationType = .sentences
                    cell.eyeBtnOlt.isHidden = true
                    cell.textFieldOlt.isSecureTextEntry = false
                    cell.entertext = {  [weak self] text in
                        self?.firstName = text.text ?? ""
                    }
                    return cell
                case .lastName:
                    let cell = signTblView.dequeueCell(with: TextFieldCell.self)
                    cell.textFieldOlt.text = nil
                    if self.lastName != "" {
                        cell.textFieldOlt.text = lastName
                    }
                    else  {
                        cell.textFieldOlt.placeholder = signUp.placeholder
                    }
                    cell.textFieldOlt.text = ""
                    cell.textFieldOlt.placeholder = signUp.placeholder
                    cell.titleLblOlt.text = signUp.title
                    cell.imgIconOlt.image = UIImage(named: signUp.image)
                    cell.textFieldOlt.keyboardType = .alphabet
                    cell.textFieldOlt.autocapitalizationType = .sentences
                    cell.textFieldOlt.isSecureTextEntry = false
                    cell.eyeBtnOlt.isHidden = true
                    cell.entertext = {  [weak self] text in
                        self?.lastName = text.text ?? ""
                    }
                    return cell
                case .email:
                    let cell = signTblView.dequeueCell(with: TextFieldCell.self)
                    cell.textFieldOlt.text = nil
                    if self.email != "" {
                        cell.textFieldOlt.text = email
                    }
                    else  {
                        cell.textFieldOlt.placeholder = signUp.placeholder
                    }
                    cell.textFieldOlt.text = ""
                    cell.titleLblOlt.text = signUp.title
                    cell.imgIconOlt.image = UIImage(named: signUp.image)
                    cell.textFieldOlt.keyboardType = .emailAddress
                    cell.textFieldOlt.isSecureTextEntry = false
                    cell.eyeBtnOlt.isHidden = true
                    cell.entertext = {  [weak self] text in
                        self?.email = text.text ?? ""
                        
                    }
                    return cell
                case .zipCode:
                    let cell = signTblView.dequeueCell(with: TextFieldCell.self)
                    cell.textFieldOlt.text = nil
                    if self.zipCode != "" {
                        cell.textFieldOlt.text = zipCode
                    }
                    else  {
                        cell.textFieldOlt.placeholder = signUp.placeholder
                    }
                    cell.textFieldOlt.text = ""
                    cell.textFieldOlt.placeholder = signUp.placeholder
                    cell.titleLblOlt.text = signUp.title
                    cell.imgIconOlt.image = UIImage(named: signUp.image)
                    cell.textFieldOlt.keyboardType = .numberPad
                    cell.textFieldOlt.isSecureTextEntry = false
                    cell.eyeBtnOlt.isHidden = true
                    cell.entertext = {  [weak self] text in
                        self?.zipCode = text.text ?? ""
                    }
                    return cell
                case .password:
                    let cell = signTblView.dequeueCell(with: TextFieldCell.self)
                    cell.textFieldOlt.text = nil
                    if self.password != "" {
                        cell.textFieldOlt.text = password
                    }
                    else  {
                        cell.textFieldOlt.placeholder = signUp.placeholder
                    }
                    cell.textFieldOlt.text = ""
                    cell.titleLblOlt.text = signUp.title
                    cell.imgIconOlt.image = UIImage(named: signUp.image)
                    cell.textFieldOlt.keyboardType = .default
                    cell.eyeBtnOlt.isHidden = false
                    cell.textFieldOlt.isSecureTextEntry = true
                    cell.entertext = {  [weak self] text in
                        self?.password = text.text ?? ""
                    }
                    return cell
                case .confirmPass:
                    let cell = signTblView.dequeueCell(with: TextFieldCell.self)
                    cell.textFieldOlt.text = nil
                    if self.conFirmPassowrd != "" {
                        cell.textFieldOlt.text = conFirmPassowrd
                    }
                    else  {
                        cell.textFieldOlt.placeholder = signUp.placeholder
                    }
                    cell.textFieldOlt.text = ""
                    cell.textFieldOlt.placeholder = signUp.placeholder
                    cell.titleLblOlt.text = signUp.title
                    cell.imgIconOlt.image = UIImage(named: signUp.image)
                    cell.textFieldOlt.keyboardType = .default
                    cell.eyeBtnOlt.isHidden = false
                    cell.textFieldOlt.isSecureTextEntry = true
                    cell.entertext = {  [weak self] text in
                        self?.conFirmPassowrd = text.text ?? ""
                    }
                    return cell
                }
            case .continueBtn:
                let cell = signTblView.dequeueCell(with: SubmitCell.self)
                cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.continues)
                cell.didTapSum = { [weak self] sender in
                    guard let self = self else { return }
                    self.submit()
                }
                return cell
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch segmentType{
            
        case .signIn:
            guard let rowType = LoginTableRow.allCases[safe: indexPath.row] else {
                fatalError("Invalid index for LoginTableRow")
            }
            switch rowType {
            case .banner:
                return Const.Height.banner
            case .segment:
                return Const.Height.segment
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
        case .signUp:
            guard let secType = SignUpSection.allCases[safe: indexPath.section] else {
                fatalError("Invalid index for LoginTableRow")
            }
            switch secType {
            case .banner:
                return Const.Height.banner
            case .segment:
                return Const.Height.segment
            case .formData:
                return Const.Height.AutomaticDimension
            case .continueBtn:
                return Const.Height.submitBtn
            }
        }
    }
}


//MARK: - Model Management
extension SignInViewController : UserServices {
    
    func showError(error: String) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            switch self.segmentType{
            case .signIn:
                SVProgressHUD.dismiss()
                Utilities.sharedInstance.showToast(source: self, message: error)
            case .signUp:
                SVProgressHUD.dismiss()
                Utilities.sharedInstance.showToast(source: self, message: error)
            
            }
           
        }
    }
    
    func reloadData() {
        SVProgressHUD.dismiss()
        switch segmentType{
        case .signIn:
            self.sucessSignInSignUp()
        case .signUp:
            self.sucessSignInSignUp()
        }
    }
}

//MARK: - success API Call
extension SignInViewController {
    private func sucessSignInSignUp() {
        switch segmentType{
        case .signIn:
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
            
        case .signUp:
            SVProgressHUD.dismiss()
            //MARK: signUpviewModel.
            if self.signUpviewModel.requestType == .signUp {
                if let dict = self.signUpviewModel.signUpDict {
                    let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                    switch statusType {
                    case .success:
                        //success API Response
                        SVProgressHUD.dismiss()
                        self.saveUserDetails(data: self.signInviewModel.signInDict?.data)
                        UserDefaults.accessToken = self.signUpviewModel.signUpDict?.data?.token ?? ""
                        self.pushVCWithValue(with: PrivacyAndPolicyViewController.self, storyboardName: .more) { vc in
                            vc.isNavFrom = "SignUp"
                        }
                        self.signUpviewModel.requestType = .none
                        self.signTblView.reload()
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
        
        //Role
//        UserDefaults.role = userData.role?.name ?? ""
        //address
//        UserDefaults.address = userData.address ?? ""
        //phone
//        UserDefaults.phone = userData.phone ?? ""
        //userId
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
