//
//  PrivacyPolicyViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import UIKit
import SVProgressHUD

enum PrivacyPolicyRow: Int, CaseIterable {
    case privacyPolicyHeader
    case privacyView
    case acceptTerm
    
    func numberOfRows(data: [PrivacyPolicyRow: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class PrivacyAndPolicyViewController: UIViewController {
    
    //MARK: Properties.
    var viewModel = PrivacyPolicyViewModel()
    var isNavFrom : String?
    var textViewCellHeight: CGFloat = 0
    let lastCellHeight: CGFloat = 130
    
    //Properties For SignUp
    var firstName  = ""
    var lastName  = ""
    var address = ""
    var email  = ""
    var phoneNumber = ""
    var zipCode = ""
    var password  = ""
    var conFirmPassowrd  = ""
    
    //MARK: IBOutlets
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    @IBOutlet var agreeBtn: UIButton!
    @IBOutlet var submitBtn: UIButton!
    @IBOutlet weak var agreeVector: UIImageView!
    @IBOutlet var termAndCondtionView: UIView!
    @IBOutlet weak var acceptTermLbl: UILabel!
    @IBOutlet var termConditionHeightConstraint: NSLayoutConstraint!
    
    var isAcceptTerm: Bool = false {
        didSet {
            let imageName = isAcceptTerm ? "checkmark.square.fill" : "square"
            let image = UIImage(systemName: "\(imageName)")?.withRenderingMode(.alwaysTemplate)

                self.agreeVector.image = image
            self.agreeVector.tintColor = isAcceptTerm ? AppColor.secondary : .secondary
        }
    }
    
    
    // MARK: Properties
    var sectionData: [PrivacyPolicyRow: Int] = [
        .privacyView: 1,
        .acceptTerm: 1
    ]
    
    // MARK: View Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadInit()
    }
    
    // MARK: View Life Cycle Method
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideAndShowView()
    }
    
    
    // MARK: View Life Cycle Methods
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setDynamicFirstCellHeight()
        adjustTableViewInsets()
        tblView.reloadData()
    }
    
    //MARK: - Configure view Method.
    private func loadInit(){
        self.initViewModel()
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
    }
    
    // MARK: configureHeaderView
    private func configureHeaderView() {
        self.headerView.headerViewSetup(
            leftButtonHidden: false,
            headerName: AppString.VCName.privacyPolicy,
            leftButtonAction: didTabBack
        )
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotch : Const.Height.notNotch
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }
    
    //MARK: initViewModel.
    func initViewModel() {
        self.viewModel.userDelegate = self
    }
    
    //MARK: fetch api .
    private func fetchApi(){
        if Reachability.isConnectedToNetwork(){
            SVProgressHUD.show()
            self.viewModel.getPrivacyPolicyData()
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    
    // MARK: agreeBtn.
    @IBAction func agreeBtn(_ sender: UIButton) {
        isAcceptTerm.toggle()
        UserDefaults.isAgreePrivacyPolicy = isAcceptTerm ? true : false
    }
    
    // MARK: submitBtn.
    @IBAction func submitBtn(_ sender: UIButton) {
        print("hello")
        if UserDefaults.isAgreePrivacyPolicy{
            self.pushVCWithValue(with: TermAndConditionViewController.self, storyboardName: .more) { value in
                value.isNavFrom = AppString.navigateFrom.signUp
                value.firstName = firstName
                value.lastName = lastName
                value.email = email
                value.zipCode = zipCode
                value.password = password
                value.conFirmPassowrd = conFirmPassowrd
            }
        }else{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.agreeTermPrivacyPolicy)
        }
    }
    
    // MARK: didTabBack
    @objc private func didTabBack() {
        self.goToBack()
    }
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension PrivacyAndPolicyViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PrivacyPolicyRow.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = PrivacyPolicyRow.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for PrivacyPolicyRow")
        }
        
        switch rowType {
        case .privacyPolicyHeader:
            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
            cell.titleOlt.text = AppString.Header.privacyPolicy
            return cell
        case .privacyView:
            let cell = tblView.dequeueCell(with: LabelCell.self)
            if let data =  self.viewModel.privacyPolicyDict?.data {
                cell.titleOlt.attributedText = data?.page_content?.htmlToAttributedString
            }
            cell.selectionStyle = .none
            return cell
        case .acceptTerm:
            let cell = tblView.dequeueCell(with: AgreeTermCell.self)
            cell.acceptTermClosure = { [weak self] sender in
                guard let self = self else { return }
                UserDefaults.isAgreePrivacyPolicy =  cell.isAcceptTerm ? true : true
            }
            cell.didTapSum = { [weak self] sender in
                guard let self = self else { return }
                if UserDefaults.isAgreePrivacyPolicy{
                    self.pushVCWithValue(with: TermAndConditionViewController.self, storyboardName: .more) { value in
                        value.isNavFrom = "SignUp"
                    }
                 }else{
                     Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.agreeTermPrivacyPolicy)
                 }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = PrivacyPolicyRow.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for PrivacyPolicyRow")
        }
        
        switch rowType {
        case .privacyPolicyHeader:
            return Const.Height.header
        case .privacyView:
            return textViewCellHeight
        case .acceptTerm:
            return isNavFrom == "SignUp" ?  Const.Height.zero :  Const.Height.zero
        }
    }
}
//Dymaic Height
extension PrivacyAndPolicyViewController{
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
extension PrivacyAndPolicyViewController: UserServices {
    func reloadData() {
        SVProgressHUD.dismiss()
        if let dict = self.viewModel.privacyPolicyDict {
            let statusType = APIResponseStatus(rawValue: dict.status ?? "")
            switch statusType {
            case .success:
                //success API Response
                debugLog("success API Response")
                self.tblView.reload()
            case .failure:
                Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
            default:
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






