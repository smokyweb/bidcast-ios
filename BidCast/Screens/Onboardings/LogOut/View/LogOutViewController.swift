//
//  LogOutViewController.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25. on 27/12/24.
//

import UIKit
import SVProgressHUD
import Security

enum LogOutSection: Int,CaseIterable {
    case imageHeader
    case twoButton
    
    func numberOfRows(data: [LogOutSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class LogOutViewController: UIViewController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var headerView: HeaderView!
    
    // MARK: Properties
    var logoutViewModel = LogoutViewModel()
    var sectionData: [LogOutSection: Int] = [
        .imageHeader: 1,
        .twoButton: 1
    ]
    
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initViewModel()
        self.configureTableView()
        self.tblView.reloadData()
    }
    
    //MARK: initViewModel.
    func initViewModel() {
        self.logoutViewModel.userDelegate = self
    }
    
    //MARK: configureTableView.
    private func configureTableView(){
        
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.configTblView()
        
        //register cells
        let cellIds = [TwoButtonCell.identifier,
                       ImageWithTitleCell.identifier]
        tblView.registerCells(for: cellIds)
        configureHeaderView()
        
    }
    
    private func configureHeaderView() {
        self.headerView.headerViewSetup(
            leftButtonHidden: false,
            headerName: AppString.VCName.logOut,
            leftButtonAction: didTabBack
        )
    }
    
    @objc private func didTabBack() {
        self.goToBack()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension LogOutViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return LogOutSection.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = LogOutSection(rawValue: section) else { return 0 }
        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = LogOutSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for LogOutSection")
        }
        
        switch rowType {
        case .imageHeader:
            let cell = tblView.dequeueCell(with: ImageWithTitleCell.self)
            cell.imageOlt.contentMode = .scaleAspectFill
            cell.imageOlt.image = UIImage(named: "ic_banner")
            cell.titleOlt.text = AppString.Title.sureYouWantLogout
            cell.selectionStyle = .none
            return cell
        case .twoButton:
            let cell = tblView.dequeueCell(with: TwoButtonCell.self)
            cell.selectionStyle = .none
            cell.didTapFirst = { [weak self] sender in
                guard let self = self else { return }
//                self.pushVC(with: HomeViewController.self, storyboardName: .main)
            }
            cell.didTapSeconde = { [weak self] sender in
                guard let self = self else { return }
                let param = UserDefaults.accessToken
                self.logoutViewModel.logout(parameters: LogoutRequest(device_token: param))
            }
           
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = LogOutSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for LogOutSection")
        }
        switch rowType {
        case .imageHeader:
            return 380
        case .twoButton:
            return Const.Height.twoButton
        }
    }
}

//MARK:- API Delegate management
extension LogOutViewController: UserServices {
    
    func reloadData() {
        debugLog("reload data")
        sucessLogout()
    }
    
    func showError(error: String) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
}

//MARK:- logout success
extension LogOutViewController  {
    func sucessLogout() {
        if logoutViewModel.logoutDict?.status == "success" || logoutViewModel.logoutDict?.error_type == "unauthorized" {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                //toDo: clear User Details
                // login cred, details, remember me from userdefaults
                Utilities.sharedInstance.clearUserDetails()
                sceneDel.navigateToLandingScreen()
            }
        }else{
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                Utilities.sharedInstance.showToast(source: self, message: self.logoutViewModel.logoutDict?.message ?? "")
            }
        }
    }
}
