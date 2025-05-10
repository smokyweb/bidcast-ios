//
//  ForgetPasswordController.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//
import UIKit
import SVProgressHUD

enum ForgetPasswordSection: CaseIterable{
    case AppHeaderCell
    case LabelCell
    case TextFieldCell
    case SubmitCell
    case SecondBtnCell
}
enum OTPSentStatus {
    case otpSent
    case otpFailure
    case none
}

class ForgetPasswordViewController: UIViewController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var headerViewOlt: HeaderView!
    @IBOutlet weak var forgetTblOlt: UITableView!
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    
    
    //MARK: Properties.
    var isForgetPassword = false
    var email  = ""
    var optSentStatue: OTPSentStatus = .none
    var viewModel = ForgetPasswordViewModel()
    var errorMessage: String = ""
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.configureView()
        self.initViewModel()
    }
    
    //MARK: ViewLife Cycle Methods.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        optSentStatue = .none
        self.email = ""
        forgetTblOlt.reload()
    }
    
    //MARK: configureTableView.
    private func configureTableView(){
        self.forgetTblOlt.delegate = self
        self.forgetTblOlt.dataSource = self
        self.forgetTblOlt.configTblView(bgColor: .white)
        //register cell
        let cellIds = [ LabelCell.identifier,
                       AppHeaderCell.identifier,
                       TextFieldCell.identifier,
                       SubmitCell.identifier,
                       SecondBtnCell.identifier ]
        forgetTblOlt.registerCells(for: cellIds)
    }
    
    //MARK: configureView.
    private func configureView() {
        self.headerViewOlt.headerViewSetup(leftButtonHidden: false, headerName: AppString.VCName.forgotPassword,leftButtonAction: didTabBack)
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotch : Const.Height.notNotch
    }
   
    //MARK: initViewModel.
    func initViewModel() {
        viewModel.userDelegate = self
    }
    
    //MARK: didTabBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
    
    //MARK: submit.
    private func submit(){
        self.view.endEditing(true)
        if self.email == "" {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyEmail)
        }else if Reachability.isConnectedToNetwork(){
            DispatchQueue.main.async {
                print(self.email)
                SVProgressHUD.show()
                let forgetRequest = ForgetRequest(email: self.email)
                self.viewModel.forgetPassword(parameters: forgetRequest)
            }
        }else{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
        }
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource.
extension ForgetPasswordViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch optSentStatue{
        case .otpSent:
            return ForgetPasswordSection.allCases.count - 1
        case .otpFailure:
            return ForgetPasswordSection.allCases.count
        case .none:
            return ForgetPasswordSection.allCases.count - 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = ForgetPasswordSection.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for LoginTableRow")
        }
        
        switch rowType {
        case .AppHeaderCell:
            let cell = forgetTblOlt.dequeueCell(with: AppHeaderCell.self)
            cell.titleOlt.text = AppString.Header.forgotPassword
            cell.outerViewOlt.backgroundColor = .white
            return cell
        case .LabelCell:
            let cell = forgetTblOlt.dequeueCell(with: LabelCell.self)
            cell.contentView.backgroundColor = .white
            switch optSentStatue{
            case .otpSent:
                cell.titleOlt.text = AppString.Description.enterCodeSent
                cell.txtColor = AppColor.mediumGray ?? .mediumGray
            case .otpFailure:
                cell.titleOlt.text = errorMessage
                cell.txtColor = AppColor.danger ?? .danger
            case .none:
                print("None Case")
                cell.titleOlt.text = AppString.Description.enterEmailMessage
                cell.txtColor = AppColor.mediumGray ?? .mediumGray
            }
            return cell
        case .TextFieldCell:
            let cell = forgetTblOlt.dequeueCell(with: TextFieldCell.self)
            cell.titleLblOlt.text = AppString.Title.email
            if self.email.isEmpty {
                cell.textFieldOlt.text = nil
                cell.textFieldOlt.placeholder = AppString.Placeholder.email
            }
            else {
                cell.textFieldOlt.text = self.email
            }
            cell.setupTextField(placeHolder : AppString.Placeholder.emailAddress,keyboardType : .emailAddress,isEyeHidden : true)
            cell.entertext = { [weak self] text in
                self?.email = text.text ?? ""
            }
            return cell
        case .SubmitCell:
            let cell = forgetTblOlt.dequeueCell(with: SubmitCell.self)
            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.submit)
            cell.didTapSum = { sender in
                self.submit()
            }
            return cell
        case .SecondBtnCell:
            let cell = forgetTblOlt.dequeueCell(with: SecondBtnCell.self)
            cell.exitBtn.setupButton(title: AppString.BtnTitle.exit)
            cell.didTapExit = { [weak self] sender in
                guard let self = self else { return }
                self.goToBack()
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = ForgetPasswordSection.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for LoginTableRow")
        }
        switch rowType{
        case .AppHeaderCell:
            return Const.Height.header
        case .TextFieldCell,.LabelCell:
            return Const.Height.AutomaticDimension
        case .SubmitCell:
            return Const.Height.submitBtn
        case .SecondBtnCell:
            switch optSentStatue{
            case .otpSent:
                return Const.Height.zero
            case .otpFailure:
                return Const.Height.submitBtn
            case .none:
                return Const.Height.zero
            }
          
        }
    }
}

//MARK: sucessForgetPassword.
extension ForgetPasswordViewController {
    private func sucessForgetPassword() {
        if self.viewModel.requestType == .forgotPassword {
            if let dict = self.viewModel.forgetPasswordDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                self.errorMessage = dict.message ?? ""
                switch statusType {
                case .success:
                    //success API Response
                    print("success API Response")
                    optSentStatue = .otpSent
                    self.isForgetPassword = false
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.forgetTblOlt.reloadData()
                        self.pushVCWithValue(with: OtpViewController.self, storyboardName: .onboardings) { vc in
                            vc.email = self.email
                        }
                    }
                    self.viewModel.requestType = .none
                    self.forgetTblOlt.reload()
                case .failure:
                    optSentStatue = .otpFailure
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                        self.isForgetPassword = true
                        Utilities.sharedInstance.showToast(source: self, message: self.viewModel.forgetPasswordDict?.message ?? "")
                        self.forgetTblOlt.reloadData()
                    }
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
    }
}

//MARK: - Model Management
extension ForgetPasswordViewController: UserServices {
    func showError(error: String) {
        //handle error
        SVProgressHUD.dismiss()
        optSentStatue = .otpFailure
        self.email = ""
        self.errorMessage = error
        forgetTblOlt.reload()
    }
    
    func reloadData() {
        self.sucessForgetPassword()
    }
}
