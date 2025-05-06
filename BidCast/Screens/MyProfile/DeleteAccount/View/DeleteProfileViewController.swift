//
//  DeleteProfileViewController.swift
//  Hey MarketPlace App
//
//  Created by JAM-E-329 on 03/09/24.
//

import UIKit
import FittedSheets
import SVProgressHUD

enum DeleteAccoutSections: Int, CaseIterable {
    case deleteHeader
    case deleteReason
    case submitButton
    
    func numberOfRows(data: [DeleteAccoutSections: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class DeleteProfileViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var viewModel = DeleteProfileViewModel()
    var Deletemessage = ""
    var email : String = UserDefaults.userEmail
    var phone: String = UserDefaults.userPhone
    
    //MARK: Properties
    var sectionData: [DeleteAccoutSections: Int] = [
        .deleteHeader : 1,
        .deleteReason: 1,
        .submitButton : 1
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
    
    //MARK: loadInit.
    private func loadInit(){
        self.configureTableView()
        initViewModel()
    }
    
    //MARK: initViewModel.
    func initViewModel() {
        self.viewModel.userDelegate = self
    }
    
    //MARK: configureTableView.
    private func configureTableView(){
        self.tblView.delegate = self
        self.tblView.dataSource = self
        let cellIds =  [TextViewCell.identifier,LabelCell.identifier,SubmitCell.identifier]
        tblView.registerCells(for: cellIds)
        tblView.configTblView(bgColor: .white)
        configureHeaderView()
    }
    
    //MARK: configureHeaderView.
    private func configureHeaderView() {
        self.headerView.headerViewSetup(leftButtonHidden: false,
                                        headerName: AppString.VCName.deleteAccount,
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
        if Deletemessage == ""{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Validation.emptyDeleteMessage)
        }else if Reachability.isConnectedToNetwork(){
            DispatchQueue.main.async {
                let message = self.Deletemessage
                    let param  = DeleteProfileRequest(reason: self.Deletemessage)
                    self.viewModel.deleteAccount(parameters: param)
                }
        }else{
            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
        }
    }
    
    //MARK: enterText
    private  func enterText(text: String, index : Int){
        if index == 1 {
            self.Deletemessage = text
        }
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource.
extension DeleteProfileViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return DeleteAccoutSections.allCases.count
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = DeleteAccoutSections(rawValue: section) else { return 0 }
        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = DeleteAccoutSections.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for DeleteAccoutSections")
        }
        
        switch rowType {
        case .deleteHeader:
            let cell = tblView.dequeueCell(with: LabelCell.self)
            cell.titleOlt.text = AppString.Description.accountDeleteNote
            return cell
        case .deleteReason:
            let cell = tblView.dequeueCell(with: TextViewCell.self)
            cell.titleLabel.font = OutFitFont.defaultBold(size: 15.0).value
            cell.titleLabel.text = AppString.Title.reasonForDeletion
            //                cell.placeholderText = options[indexPath.row].placeHolder
            //                if self.serviceArea != "" {
            //                    cell.textViewOlt.text = self.serviceArea
            //                }
            //                else {
            //                    cell.textViewOlt.text = AppString.Placeholder.serviceArea
            //                }
            cell.enterText = { [weak self] text in
                guard let self = self else { return }
                self.Deletemessage = text.text ?? ""
            }
            cell.selectionStyle = .none
            return cell
            
        case .submitButton:
            let cell = tblView.dequeueCell(with: SubmitCell.self)
            cell.submitBtnOlt.setupButton(title: AppString.BtnTitle.submit,backgroundColor: .primary)
            cell.didTapSum = { [weak self] sender in
                guard let self = self else { return }
                self.didtapNext()
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = DeleteAccoutSections.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for DeleteAccoutSections")
        }
        
        switch rowType {
        case .deleteHeader:
            return Const.Height.AutomaticDimension
        case .deleteReason:
            return Const.Height.AutomaticDimension
        case .submitButton:
            return Const.Height.submitBtn
        }
    }
}

//MARK: - Model Management
extension DeleteProfileViewController : UserServices {
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
extension DeleteProfileViewController {
    private func showSuccessAlert() {
        if viewModel.deleteAccountDict?.status == "success" {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.showDeleteAccSuccessAlert()
            }
        }else{
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                Utilities.sharedInstance.showToast(source: self, message: self.viewModel.deleteAccountDict?.message ?? "")
            }
        }
    }
}


//showSuccessAlert
extension DeleteProfileViewController {
    func showDeleteAccSuccessAlert() {
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithSingleButtonViewController") as! AlertWithSingleButtonViewController
        vc.image = UIImage(named: "ic_Success")
        vc.content = AppString.Alert.deleteAccount
        vc.heading = AppString.Header.success
        vc.firstBtnTitle = AppString.BtnTitle.ok
        vc.isHiddenRequired = true
        var options = SheetOptions()
        options.shrinkPresentingViewController = false
        options.pullBarHeight = Height_30
        vc.firstBtnClosure = {
            self.dismiss(animated: true)
            //go to welcome page
            self.pushVC(with: SignInViewController.self, storyboardName: .onboardings)
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
