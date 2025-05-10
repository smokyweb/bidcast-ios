//
//  TermAndConditionViewController.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25. on 27/12/24.
//

import UIKit
import SVProgressHUD
import FittedSheets

enum TermConditionRow: Int, CaseIterable {
    case termAndConditionHeader
    case TermConditionView
    case acceptTerm
    
    func numberOfRows(data: [TermConditionRow: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class TermAndConditionViewController: UIViewController {

    // MARK: IBOutlets
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    @IBOutlet var agreeBtn: UIButton!
    @IBOutlet var submitBtn: UIButton!
    @IBOutlet weak var agreeVector: UIImageView!
    @IBOutlet var termAndCondtionView: UIView!
    @IBOutlet weak var acceptTermLbl: UILabel!
    @IBOutlet var termConditionHeightConstraint: NSLayoutConstraint!
    
    var signUpviewModel = SignUpViewModel()
    
    //Properties For SignUp
    var firstName  = ""
    var lastName  = ""
    var address = ""
    var email  = ""
    var phoneNumber = ""
    var zipCode = ""
    var password  = ""
    var conFirmPassowrd  = ""

    var isAcceptTerm: Bool = false {
        didSet {
            let imageName = isAcceptTerm ? "checkmark.square.fill" : "square"
            let image = UIImage(systemName: "\(imageName)")?.withRenderingMode(.alwaysTemplate)

                self.agreeVector.image = image
            self.agreeVector.tintColor = isAcceptTerm ? AppColor.secondary : .secondary
        }
    }
    
    
    // MARK: Properties.
    var isNavFrom : String?
    var viewModel = TermConditionViewModel()
    var textViewCellHeight: CGFloat = 0
    let lastCellHeight: CGFloat = 130
    
    // MARK: sectionData
    var sectionData: [TermConditionRow: Int] = [
        .TermConditionView: 1,
        .acceptTerm: 1
    ]

    // MARK: View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInit()
    }
    
    // MARK: View Life Cycle Method
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideAndShowView()
    }
    
    // MARK: viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setDynamicFirstCellHeight()
        adjustTableViewInsets()
        tblView.reloadData()
    }
    
    //MARK: - Configure view Method.
    private func loadInit(){
        self.initialViewModel()
        self.configureTableView()
        self.setDynamicFirstCellHeight()
        self.fetchApi()
        self.setupUI()
    }
    
    
    //MARK: hideAndShowView
    func hideAndShowView(){
        termAndCondtionView.isHidden = isNavFrom == AppString.navigateFrom.signUp ?  false :  true
        termConditionHeightConstraint.constant = isNavFrom == AppString.navigateFrom.signUp ?  100.0 : 0.0
    }
    
    //MARK: setupUI.
    func setupUI(){
        self.acceptTermLbl.font = AppFont.placeHolder
        self.submitBtn.titleLabel?.font = OutFitFont.defaultExtraBold(size: 15).value
        self.submitBtn.makeCornerRounded(ofSize: Corner_26)
    }
    
    // MARK: configureTableView
    private func configureTableView() {
        self.tblView.delegate = self
        self.tblView.dataSource = self
        let cellIds = [LabelCell.identifier, AgreeTermCell.identifier, SubmitCell.identifier,AppHeaderCell.identifier]
        tblView.registerCells(for: cellIds)
        tblView.configTblView(bgColor: .white)
        tblView.makeCornerRounded(ofSize: Corner_06)
        configureHeaderView()
        adjustTableViewInsets()
    }

    // MARK: configureHeaderView
    private func configureHeaderView() {
        self.headerView.headerViewSetup(
            leftButtonHidden: false,
            headerName: AppString.VCName.termsAndConditions,
            leftButtonAction: didTabBack
        )
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotch : Const.Height.notNotch
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }
    
    // MARK: initialViewModel
    func initialViewModel(){
        self.viewModel.userDelegate = self
        self.signUpviewModel.userDelegate = self
    }
    
    //MARK: fetch api .
    private func fetchApi(){
        if Reachability.isConnectedToNetwork(){
            SVProgressHUD.show()
            self.viewModel.getTermConditionData()
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    
    // MARK: agreeBtn.
    @IBAction func agreeBtn(_ sender: UIButton) {
        isAcceptTerm.toggle()
        UserDefaults.isAgreeTermAndCondition = isAcceptTerm ? true : false
    }
    
    // MARK: submitBtn.
    @IBAction func submitBtn(_ sender: UIButton) {
        if UserDefaults.isAgreeTermAndCondition{
//            self.signUpSubmit()
        }else{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.agreeTermAndCondition)
        }
    }
    
    //MARK: signUpSubmit.
//    func signUpSubmit(){
//        if Reachability.isConnectedToNetwork(){
//                let signUpParam = SignUpRequest(firstName: self.firstName,
//                                                lastName: self.lastName,
//                                                email: self.email,
//                                                zipCode: self.zipCode,
//                                                password: self.password,
//                                                passwordConf: self.conFirmPassowrd)
//                print(signUpParam)
//                SVProgressHUD.show()
//                self.signUpviewModel.signUp(parameters: signUpParam)
//        }else{
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
//        }
//    }

    // MARK: didTabBack
    @objc private func didTabBack() {
        self.goToBack()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TermAndConditionViewController: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // Single section
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TermConditionRow.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = TermConditionRow.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for TermConditionRow")
        }

        switch rowType {
        case .termAndConditionHeader:
            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
            cell.titleOlt.text = AppString.Header.termAndConditions
            return cell
        case .TermConditionView:
            let cell = tblView.dequeueCell(with: LabelCell.self)
            if let termCondition = self.viewModel.termConditionDict?.data{
                cell.titleOlt.attributedText = termCondition?.page_content?.htmlToAttributedString
            }
            cell.selectionStyle = .none
            return cell
        case .acceptTerm:
            let cell = tblView.dequeueCell(with: AgreeTermCell.self)
            cell.acceptTermClosure = { [weak self] sender in
                guard let self = self else { return }
                UserDefaults.isAgreeTermAndCondition =  cell.isAcceptTerm ? true : false
            }
            cell.didTapSum = { [weak self] sender in
                guard let self = self else { return }
                if UserDefaults.isAgreeTermAndCondition{
                    self.pushVCWithValue(with: OurSubscriptionViewController.self, storyboardName: .main) { value in
                         value.isNavFrom = AppString.navigateFrom.signUp
                     }
                 }else{
                     Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.agreeTermAndCondition)
                 }
                
            }
            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = TermConditionRow.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for TermConditionRow")
        }
        switch rowType {
        case .termAndConditionHeader:
            return Const.Height.header
        case .TermConditionView:
            return textViewCellHeight
        case .acceptTerm:
            return isNavFrom == "SignUp" ?  Const.Height.zero :  Const.Height.zero
        
        }
    }
}


//Dymaic Height
extension TermAndConditionViewController{
    private func setDynamicFirstCellHeight() {
        tblView.layoutIfNeeded()
        let headerViewHeight = 80.0
        let topInset = tblView.safeAreaInsets.top
        let bottomInset = tblView.safeAreaInsets.bottom
        let totalHeight = tblView.frame.height
        let availableHeight = totalHeight - topInset - bottomInset - headerViewHeight - lastCellHeight
        textViewCellHeight = availableHeight
    }
    
    private func adjustTableViewInsets() {
        var contentInset = tblView.contentInset
        contentInset.bottom = lastCellHeight
        tblView.contentInset = contentInset
        tblView.scrollIndicatorInsets = contentInset
    }
}

//MARK: API CALL.
extension TermAndConditionViewController: UserServices {
    func reloadData() {
        SVProgressHUD.dismiss()
        if let dict = self.viewModel.termConditionDict {
            let statusType = APIResponseStatus(rawValue: dict.status ?? "")
            switch statusType {
            case .success:
                //success API Response
                print("success API Response")
                SVProgressHUD.dismiss()
                self.viewModel.requestType = .none
                self.tblView.reload()
            case .failure:
                SVProgressHUD.dismiss()
                Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
            default:
                SVProgressHUD.dismiss()
                Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
            }
        }
        
        if let dict = self.signUpviewModel.signUpDict {
            let statusType = APIResponseStatus(rawValue: dict.status ?? "")
            switch statusType {
            case .success:
                //success API Response
                print("success API Response")
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.saveUserDetails()
                    self.signUpviewModel.requestType = .none
                    self.pushVCWithValue(with: OurSubscriptionViewController.self, storyboardName: .main) { value in
                        value.isNavFrom = AppString.navigateFrom.signUp
                    }
                }
            case .failure:
                SVProgressHUD.dismiss()
                Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
            default:
                SVProgressHUD.dismiss()
                Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
            }
        }
    }
    
    func showError(error: String) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
}


extension TermAndConditionViewController{
    func saveUserDetails(){
        let userData = self.signUpviewModel.signUpDict?.data
        //name,
        UserDefaults.name = userData?.name ?? ""
        //first name
        UserDefaults.firstName = userData?.firstName ?? ""
        //last name
        UserDefaults.lastName = userData?.lastName ?? ""
        //role_id
        UserDefaults.roleId = userData?.roleID ?? 0
        //email
        UserDefaults.email = userData?.email ?? ""
        
        UserDefaults.accessToken =  userData?.token ?? ""
        
        //Role
        //        UserDefaults.role = userData.role.name ?? ""
        //address
        //        UserDefaults.address = userData.address ?? ""
        //phone
        //        UserDefaults.phone = userData.phone ?? ""
        //userId
        UserDefaults.userId = userData?.id ?? 0
        //token
        UserDefaults.accessToken = userData?.token ?? ""
        
    }
    func succesuccessfullyAccCreatedAlert() {
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithSingleButtonViewController") as! AlertWithSingleButtonViewController
        vc.image = UIImage(named: "ic_Success")
        vc.content = AppString.Alert.successfullyAccCreated
        vc.heading = AppString.Header.success
        vc.firstBtnTitle = AppString.BtnTitle.ok
        vc.isHiddenRequired = true
        var options = SheetOptions()
        options.shrinkPresentingViewController = false
        options.pullBarHeight = Height_30
        vc.firstBtnClosure = {
            self.dismiss(animated: true)
            //go to welcome page
            self.pushVCWithValue(with: OurSubscriptionViewController.self, storyboardName: .main) { value in
                value.isNavFrom = AppString.navigateFrom.signUp
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

}






