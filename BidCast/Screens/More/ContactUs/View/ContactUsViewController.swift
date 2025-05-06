//
//  ContactUsViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import UIKit
import FittedSheets
import SVProgressHUD
import IQKeyboardManagerSwift

enum ContactUsSections: Int, CaseIterable {
    case conatactHeader
    case contactForm
    
    func numberOfRows(data: [ContactUsSections: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

enum contactForm : Int,CaseIterable{
    case emailAddress
    case phoneNumber
    case message
    
    var title : String{
        switch self {
        case .emailAddress:
            return AppString.Title.email
        case .phoneNumber:
            return AppString.Title.phoneNumber
        case .message:
            return AppString.Title.message
        }
    }
    var placeHolder : String{
        switch self {
        case .emailAddress:
            return AppString.Placeholder.email
        case .phoneNumber:
            return AppString.Placeholder.phoneNumber
        case .message:
            return AppString.Placeholder.message
        }
    }
    var icon : String{
        switch self {
        case .emailAddress:
            return "mail"
        case .phoneNumber:
            return "ic_Phone"
        case .message:
            return ""
        }
    }
}

class ContactUsViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var contactUsTableView: UITableView!
    @IBOutlet var submitBtn: UIButton!
    
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var viewModel = ContactUsViewModel()
    var contactmessage = ""
    var email : String = UserDefaults.userEmail
    var phone: String = UserDefaults.userPhone
    
    //MARK: Properties
    var sectionData: [ContactUsSections: Int] = [
        .contactForm: 3
    ]
    
    //MARK: ViewLife Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadInit()
    }
    
    //MARK: ViewLife Cycle Method
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    //MARK: submitBtnTapped
    @IBAction func submitBtnTapped(_ sender: UIButton) {
        didtapNext()
    }
    
    //MARK: loadInit.
    private func loadInit(){
        self.configureTableView()
        submitBtn.makeCornerRounded(ofSize: Corner_26)
        submitBtn.titleLabel?.font = OutFitFont.defaultExtraBold(size: 15).value
        initViewModel()
    }
    
    //MARK: initViewModel.
    func initViewModel() {
        viewModel.userDelegate = self
    }
    
    //MARK: configureTableView.
    private func configureTableView(){
        self.contactUsTableView.delegate = self
        self.contactUsTableView.dataSource = self
        let cellIds =  [TextFieldCell.identifier,TextViewCell.identifier,AppHeaderCell.identifier]
        contactUsTableView.registerCells(for: cellIds)
        contactUsTableView.configTblView(bgColor : .ultraLightGray)
        configureHeaderView()
        
    }
    
    //MARK: configureHeaderView.
    private func configureHeaderView(){
        self.headerView.headerViewSetup(leftButtonHidden: false,
                                        headerName: AppString.VCName.contactUs,
                                        leftButtonAction: didTabBack)
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotch : Const.Height.notNotch
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }
    
    //MARK: IBActions
    @objc private func didTabBack(){
        self.goToBack()
    }
    
    //MARK: didtapNext
    private func didtapNext (){
        self.view.endEditing(true)
        if email == ""{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyEmail)
        }else if phone == ""{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyPhone)
        }else if contactmessage == ""{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyMessage)
        }else if Reachability.isConnectedToNetwork(){
            DispatchQueue.main.async {
                let emailAddress = self.email
                let phoneNumber = self.phone
                let message = self.contactmessage
                if !emailAddress.isEmpty || emailAddress.isValidEmail() && !phoneNumber.isEmpty && !message.isEmpty {
                    let param = ContactUsRequest(email: emailAddress, phone: phoneNumber, message: message)
                    self.viewModel.contactUs(parameters: param)
                }
            }
        }else{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
        }
    }
    
    //MARK: enterText
    private  func enterText(text: String, index : Int){
        if index == 3{
            self.email = text
        }else if index == 4 {
            self.phone = text
        }else if index == 5 {
            self.contactmessage = text
        }
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource.
extension ContactUsViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return ContactUsSections.allCases.count
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = ContactUsSections(rawValue: section) else { return 0 }
        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = ContactUsSections.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for ContactUsSections")
        }
        
        switch rowType {
        case .conatactHeader:
            let cell = contactUsTableView.dequeueCell(with: AppHeaderCell.self)
            cell.outerViewOlt.backgroundColor = .ultraLightGray
            cell.titleOlt.text = AppString.Header.contactUs
            return cell
        case .contactForm:
            guard let rowType = contactForm.allCases[safe: indexPath.row] else {
                fatalError("Invalid index for ContactUsSections")
            }
            let options : [contactForm] = contactForm.allCases
            switch rowType {
            case .emailAddress:
                let cell = contactUsTableView.dequeueCell(with: TextFieldCell.self)
                cell.contentView.backgroundColor = .ultraLightGray
                cell.titleLblOlt.text = options[indexPath.row].title
                cell.textFieldOlt.placeholder = options[indexPath.row].placeHolder
                cell.textFieldOlt.text = " "
                cell.imgIconOlt.image = UIImage(named: options[indexPath.row].icon)
//                cell.textFieldOlt.keyboardType = .emailAddress
                cell.eyeBtnOlt.isHidden = true
                cell.entertext = {  [weak self] text in
                    self?.email = text.text ?? ""
                }
                return cell
            case .phoneNumber:
                let cell = contactUsTableView.dequeueCell(with: TextFieldCell.self)
                cell.contentView.backgroundColor = .ultraLightGray
                cell.titleLblOlt.text = options[indexPath.row].title
                cell.textFieldOlt.placeholder = options[indexPath.row].placeHolder
                cell.imgIconOlt.image = UIImage(named: options[indexPath.row].icon)
                cell.textFieldOlt.keyboardType = .phonePad
                cell.eyeBtnOlt.isHidden = true
                cell.entertext = {  [weak self] text in
                    self?.phone = text.text ?? ""
                }
                return cell
            case .message:
                let cell = contactUsTableView.dequeueCell(with: TextViewCell.self)
                cell.contentView.backgroundColor = .ultraLightGray
                cell.titleLabel.text = options[indexPath.row].title
                if self.contactmessage != "" {
                    cell.textViewOlt.text = self.contactmessage
                }else{
                    cell.textViewOlt.text = "Type here..."
                }
//                cell.placeholderText = options[indexPath.row].placeHolder
                //                if self.serviceArea != "" {
                //                    cell.textViewOlt.text = self.serviceArea
                //                }
                //                else {
                //                    cell.textViewOlt.text = AppString.Placeholder.serviceArea
                //                }
                cell.enterText = { [weak self] text in
                    guard let self = self else { return }
                    self.contactmessage = text.text ?? ""
                }
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = ContactUsSections.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for ContactUsSections")
        }
        
        switch rowType {
        case .conatactHeader:
            return Const.Height.header
        case .contactForm:
            return Const.Height.AutomaticDimension
        }
    }
}

//MARK: - Model Management
extension ContactUsViewController : UserServices {
    func showError(error: String) {
        //handle error
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
    
    func reloadData() {
        self.showSuccessAlert()
    }
}

//MARK: - success API Call
extension ContactUsViewController {
    private func showSuccessAlert() {
        if viewModel.contactUs?.status == "success" {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.showContactSuccessAlert()
            }
        }else{
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                Utilities.sharedInstance.showToast(source: self, message: self.viewModel.contactUs?.message ?? "")
            }
        }
    }
}


//showSuccessAlert
extension ContactUsViewController {
    func showContactSuccessAlert() {
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithSingleButtonViewController") as! AlertWithSingleButtonViewController
        vc.image = UIImage(named: "ic_Success")
        vc.content = AppString.Alert.messageSent
        vc.heading = AppString.Header.success
        vc.firstBtnTitle = AppString.BtnTitle.ok
        vc.isHiddenRequired = true
        var options = SheetOptions()
        options.shrinkPresentingViewController = false
        options.pullBarHeight = Height_30
        vc.firstBtnClosure = {
            self.dismiss(animated: true)
            //go to welcome page
//            self.pushVC(with: HomeViewController.self, storyboardName: .main)
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
