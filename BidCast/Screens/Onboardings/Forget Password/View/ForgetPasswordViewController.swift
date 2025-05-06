//
//  ForgetPasswordController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 26/12/24.
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
        headerViewOlt.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }
   
    //MARK: initViewModel.
    func initViewModel() {
        viewModel.forgetPasswordDelegate = self
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
                debugLog(self.email)
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
            return cell
        case .LabelCell:
            let cell = forgetTblOlt.dequeueCell(with: LabelCell.self)
            switch optSentStatue{
            case .otpSent:
                cell.titleOlt.text = AppString.Description.enterEmailMessage
                cell.txtColor = AppColor.mediumGray ?? .mediumGray
            case .otpFailure:
                cell.titleOlt.text = AppString.Description.emailNotAssociatedMessage
                cell.txtColor = AppColor.danger ?? .danger
            case .none:
                cell.titleOlt.text = AppString.Description.enterEmailMessage
                cell.txtColor = AppColor.mediumGray ?? .mediumGray
            }
            return cell
        case .TextFieldCell:
            let cell = forgetTblOlt.dequeueCell(with: TextFieldCell.self)
            cell.textFieldOlt.text = ""
            cell.textFieldOlt.text = nil
            cell.titleLblOlt.text = AppString.Title.email
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
        if viewModel.forgetPasswordDict?.status == "success" {
            optSentStatue = .otpSent
            self.isForgetPassword = false
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.forgetTblOlt.reloadData()
                self.pushVCWithValue(with: OtpViewController.self, storyboardName: .onboardings) { vc in
                    vc.email = self.email
                }
            }
        }else{
            optSentStatue = .otpFailure
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.isForgetPassword = true
                Utilities.sharedInstance.showToast(source: self, message: self.viewModel.forgetPasswordDict?.message ?? "")
                self.forgetTblOlt.reloadData()
            }
        }
    }
}

//MARK: - Model Management
extension ForgetPasswordViewController: UserServices {
    func showError(error: String) {
        //handle error
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
        optSentStatue = .otpFailure
        self.email = ""
        forgetTblOlt.reload()
    }
    func reloadData() {
        self.sucessForgetPassword()
    }
}
