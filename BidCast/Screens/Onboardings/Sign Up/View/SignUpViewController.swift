//
//  SignUpViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-328 on 31/08/24.
//

import UIKit
import SVProgressHUD
import FittedSheets

//enum SignUpSection: Int, CaseIterable {
//    case headingTitle
//    case formData
//    case continueBtn
//    
//    func numberOfRows(data: [SignUpSection: Int]) -> Int {
//        return data[self] ?? 1 // Default to 1 if no data provided
//    }
//}
//enum formData : Int,CaseIterable{
//    case firstName
//    case lastName
//    case email
//    case zipCode
//    case password
//    case confirmPass
//    var title : String{
//        switch self {
//        case .firstName:
//            return AppString.Title.firstName
//        case .lastName:
//            return  AppString.Title.lastName
//        case .email:
//            return AppString.Title.email
//        case .zipCode:
//            return AppString.Title.zipCode
//        case .password:
//            return AppString.Title.password
//        case .confirmPass:
//            return AppString.Title.confirmPass
//        }
//    }
//    var placeholder: String {
//        switch self {
//        case .firstName:
//            return AppString.Placeholder.firstName
//        case .lastName:
//            return AppString.Placeholder.lastName
//        case .email:
//            return AppString.Placeholder.email
//        case .zipCode:
//            return  AppString.Placeholder.zipCode
//        case .password:
//            return AppString.Placeholder.craetePassword
//        case .confirmPass:
//            return AppString.Placeholder.confirmPass
//        }
//    }
//}
//
//class SignUpViewController: UIViewController {
//    
//    // MARK: IBOutlets.
//    @IBOutlet weak var signUpTblView: UITableView!
//    @IBOutlet weak var headerView: HeaderView!
//    
//    //MARK: Properties.
//    var firstName  = ""
//    var lastName  = ""
//    var address = ""
//    var email  = ""
//    var zipCode = ""
//    var password  = ""
//    var conFirmPassowrd  = ""
// 
//    //MARK: sectionData.
//    var sectionData: [SignUpSection: Int] = [
//        .headingTitle : 1,
//        .formData : 6,
//        .continueBtn : 1
//    ]
//    
//    
//    var viewModel = SignUpViewModel()
//    var deviceDetailViewModel = DeviceDetailsViewModel()
//    
//    //MARK: ViewLife Cycle Methods -
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.configureTableView()
//        self.configureView()
//        initViewModel()
//    }
//    
//    //MARK: configureTableView.
//    private func configureTableView(){
//        self.signUpTblView.delegate = self
//        self.signUpTblView.dataSource = self
//        self.signUpTblView.configTblView()
//        //register cell
//        let cellIds = [AppBannerCell.identifier, AppHeaderCell.identifier, TextFieldCell.identifier, SubmitCell.identifier, SignUpTodayCell.identifier, SecondBtnCell.identifier,LabelCell.identifier,TextFieldWithLabelCell.identifier]
//        signUpTblView.registerCells(for: cellIds)
//    }
//    
//    //MARK: configureView.
//    private func configureView() {
//        self.headerView.headerViewSetup(leftButtonHidden: false, headerName: AppString.VCName.createYourAccount,leftButtonAction: didTabBack)
//    }
//    
//    //MARK: initViewModel.
//    func initViewModel() {
//        viewModel.signUpDelegate = self
//    }
//    
//    //MARK: didTabBack.
//    @objc func didTabBack() {
//        self.goToBack()
//    }
// 
//    //MARK: submit.
//    private func submit(){
//        self.view.endEditing(true)
//        if self.firstName == "" {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyFirstName)
//        }
//        else if self.lastName == "" {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyLastName)
//        }
//        else if self.email == "" {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyEmail)
//        }
//        else if self.zipCode == "" {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyZipCode)
//        }
//        else if self.password == "" {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyPassword)
//        }
//        else if self.conFirmPassowrd == "" {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyConfirmPassword)
//        }
//        else if self.password != self.conFirmPassowrd {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.passwordsDoNotMatch)
//        }
//        else
//        if Reachability.isConnectedToNetwork(){
//            DispatchQueue.main.async {
//                let signUpParam = SignUpRequest(firstName: self.firstName,
//                                                lastName: self.lastName,
//                                                email: self.email,
//                                                zipCode: self.zipCode,
//                                                password: self.password,
//                                                passwordConf: self.conFirmPassowrd)
//                debugLog(signUpParam)
//                SVProgressHUD.show()
//                self.viewModel.signUp(parameters: signUpParam)
//            }
//        }else{
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
//        }
//    }
//}
////MARK: UITableViewDelegate,UITableViewDataSource.
//extension SignUpViewController: UITableViewDelegate,UITableViewDataSource{
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return SignUpSection.allCases.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        guard let sectionType = SignUpSection(rawValue: section) else { return 0 }
//        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
//        return sectionType.numberOfRows(data: sectionData)
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        guard let secType = SignUpSection.allCases[safe: indexPath.section] else {
//            fatalError("Invalid index for SignUpSection")
//        }
//        switch secType {
//        case .headingTitle:
//            let cell = signUpTblView.dequeueCell(with: AppHeaderCell.self)
//            cell.titleOlt.text = AppString.Header.createYourAccount
//            return cell
//        case .formData:
//            guard let rowType = formData.allCases[safe: indexPath.row] else {
//                fatalError("Invalid index for SignUpSection")
//            }
//            let options : [formData] = formData.allCases
//            switch rowType{
//            case .firstName:
//                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
//                cell.titleOlt.text = options[indexPath.row].title
//                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
//                cell.eyeBtnOlt.isHidden = true
//                cell.entertext = { [weak self] text in
//                    guard let self = self else { return }
//                    self.firstName = text.text ?? ""
//                }
//                cell.selectionStyle = .none
//                return cell
//            case .lastName:
//                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
//                cell.titleOlt.text = options[indexPath.row].title
//                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
//                cell.eyeBtnOlt.isHidden = true
//                cell.entertext = { [weak self] text in
//                    guard let self = self else { return }
//                    self.lastName = text.text ?? ""
//                }
//                cell.selectionStyle = .none
//                return cell
//            case .email:
//                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
//                cell.titleOlt.text = options[indexPath.row].title
//                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
//                cell.eyeBtnOlt.isHidden = true
//                cell.entertext = { [weak self] text in
//                    guard let self = self else { return }
//                    self.email = text.text ?? ""
//                }
//                cell.selectionStyle = .none
//                return cell
//            case .zipCode:
//                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
//                cell.titleOlt.text = options[indexPath.row].title
//                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
//                cell.eyeBtnOlt.isHidden = true
//                cell.entertext = { [weak self] text in
//                    guard let self = self else { return }
//                    self.zipCode = text.text ?? ""
//                }
//                cell.selectionStyle = .none
//                return cell
//            case .password:
//                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
//                cell.titleOlt.text = options[indexPath.row].title
//                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
//                cell.eyeBtnOlt.isHidden = true
//                cell.entertext = { [weak self] text in
//                    guard let self = self else { return }
//                    self.password = text.text ?? ""
//                }
//                cell.selectionStyle = .none
//                return cell
//            case .confirmPass:
//                let cell = signUpTblView.dequeueCell(with: TextFieldWithLabelCell.self)
//                cell.titleOlt.text = options[indexPath.row].title
//                cell.textFieldOlt.placeholder = options[indexPath.row].placeholder
//                cell.eyeBtnOlt.isHidden = true
//                cell.entertext = { [weak self] text in
//                    guard let self = self else { return }
//                    self.conFirmPassowrd = text.text ?? ""
//                }
//                cell.selectionStyle = .none
//                return cell
//            }
//        case .continueBtn:
//            let cell = signUpTblView.dequeueCell(with: SubmitCell.self)
//            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.continues)
//            cell.didTapSum = { [weak self] sender in
//                guard let self = self else { return }
//                self.submit()
//            }
//            return cell
//            
//        }
//    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let secType = SignUpSection.allCases[safe: indexPath.section] else {
//            fatalError("Invalid index for LoginTableRow")
//        }
//        switch secType {
//        case .headingTitle:
//            return Const.Height.header
//        case .formData:
//            return Const.Height.AutomaticDimension
//        case .continueBtn:
//            return Const.Height.submitBtn
//        }
//    }
//    
//}
//
////succesuccessfullyAccCreatedAlert
//extension SignUpViewController {
//    func succesuccessfullyAccCreatedAlert() {
//        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithSingleButtonViewController") as! AlertWithSingleButtonViewController
//        vc.image = UIImage(named: "ic_Circle")
//        vc.content = AppString.Alert.successfullyAccCreated
//        vc.heading = AppString.Header.success
//        vc.firstBtnTitle = AppString.BtnTitle.home
//        vc.isHiddenRequired = true
//        var options = SheetOptions()
//        options.shrinkPresentingViewController = false
//        options.pullBarHeight = Height_30
//        vc.firstBtnClosure = {
//            self.dismiss(animated: true)
//            //go to welcome page
//            self.pushVC(with: SignInViewController.self, storyboardName: .onboardings)
//        }
//        let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.40) : .percent(0.50)], options: options)
//        sheet.cornerRadius = Corner_32
//        sheet.overlayColor = .black.withAlphaComponent(0.9)
//        sheet.dismissOnPull = false
//        sheet.dismissOnOverlayTap = true
//        sheet.gripSize = CGSize(width: Width_50, height: Height_0)
//        self.present(sheet, animated: true, completion: nil)
//    }
//}
//
//// APi Delegate management
//extension SignUpViewController: UserServices {
//    func reloadData() {
//        debugLog("reload data")
//        sucessSignUp()
//    }
//    
//    func showError(error: String) {
//        DispatchQueue.main.async {
//            SVProgressHUD.dismiss()
//            Utilities.sharedInstance.showToast(source: self, message: error)
//        }
//    }
//}
//
////MARK: - Api Call and its success response
//extension SignUpViewController {
//    
//    //MARK: sucessSignUp.
//    private func sucessSignUp() {
//        SVProgressHUD.dismiss()
//        if viewModel.signUpDict?.status == "success" {
//            DispatchQueue.main.async {
//                //show success alert
//                self.succesuccessfullyAccCreatedAlert()
//                //save user details
////                self.saveUserDetails(data: self.viewModel.signUpDict?.data)
//                //navigate to welcome page
//                self.pushVC(with: SignInViewController.self, storyboardName: .onboardings)
//            }
//            
//            
//        }else{
//            DispatchQueue.main.async {
//                Utilities.sharedInstance.showToast(source: self, message: self.viewModel.signUpDict?.message ?? "")
//            }
//        }
//    }
//}
