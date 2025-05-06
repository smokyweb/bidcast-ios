//
//  MoreViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import UIKit
import SideMenu
import FittedSheets
import SVProgressHUD

enum MoreRows: Int, CaseIterable {
    case profile
    case Home
    case myAccount
    case AboutUs
    case ContactUs
    case FAQ
    case PrivacyPolicy
    case TermOfService
    case Logout
    case closeTab
    
    func numberOfRows(data: [MoreRows: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
    
    var title : String{
        switch self {
        case .profile:
            return ""
        case .Home:
            return AppString.Title.home
        case .myAccount:
            return AppString.Title.myAccount
        case .AboutUs:
            return AppString.Title.AboutUs
        case .ContactUs:
            return AppString.Title.contactUS
        case .FAQ:
            return AppString.Title.faq
        case .PrivacyPolicy:
            return AppString.Title.privacyPolicy
        case .TermOfService:
            return AppString.Title.termOfService
        case .Logout:
            return AppString.Title.logOut
        case .closeTab:
            return ""
        }
    }
}

class MoreViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tblView: UITableView!
    var logoutViewModel = LogoutViewModel()
    @IBOutlet var headerView: MoreHeaderView!
    @IBOutlet var mainView: UIView!
    @IBOutlet var moreHeaderHeight: NSLayoutConstraint!
    
    // MARK: Properties
    private var isForgetPassword = false
    var password  = ""
    var image = ""
    var email = ""
    
    var sectionData: [MoreRows: Int] = [
        .profile: 1,
        .Home: 1,
        .myAccount : 1,
        .AboutUs : 1,
        .ContactUs: 1,
        .FAQ : 1,
        .PrivacyPolicy : 1,
        .TermOfService : 1,
        .Logout : 1,
        .closeTab : 1
    ]
    
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
        self.initViewModel()
        self.setupHeader()
    }
    
    //MARK: ViewLife Cycle Methods.
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        self.addTapGestureToDismissMenu()
    }
    
    //MARK: Configure views Method.
    private func configureTableView(){
        self.tblView.delegate = self
        self.tblView.dataSource = self
        let cellIds = [MenuCell.identifier,ProfileDetailCell.identifier,CloseTabBarCell.identifier]
        tblView.registerCells(for: cellIds)
        tblView.configTblView(bgColor : .clear)
        headerView.midLbl.text = AppString.VCName.more
        SideMenuManager.default.addPanGestureToPresent(toView: self.mainView)
    }
    
    //MARK: setupHeader.
    func setupHeader(){
        moreHeaderHeight.constant = UIDevice.current.hasNotch ? 115 : Const.Height.notNotch
    }
    
    //MARK: initViewModel.
    func initViewModel() {
        self.logoutViewModel.userDelegate = self
    }
    
    //MARK: - didTap.
    func didTap(index:Int){
        if index == 0{
            self.pushVC(with: OurSubscriptionViewController.self, storyboardName: .main)
        }else if index == 1{
            sceneDel.navigateToLandingScreen()
        }else if index == 2{
            self.pushVC(with: ProfileViewController.self, storyboardName: .main)
        }else if index == 3{
            self.pushVC(with: AboutUsViewController.self, storyboardName: .more)
        }else if index == 4{
            self.pushVC(with: ContactUsViewController.self, storyboardName: .more)
        }else if index == 5{
            self.pushVC(with: FrequentlyAskedQuestionViewController.self, storyboardName: .more)
        }else if index == 6{
            self.pushVC(with: PrivacyAndPolicyViewController.self, storyboardName: .more)
        }else if index == 7{
            self.pushVC(with: TermAndConditionViewController.self, storyboardName: .more)
        }else if index == 8{
            logout()
        }else if index == 9{
            
        }
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource.
extension MoreViewController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MoreRows.allCases.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = MoreRows.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for MoreRows")
        }
        let options : [MoreRows] = MoreRows.allCases
        switch rowType {
        case .profile:
            let cell = tblView.dequeueCell(with: ProfileDetailCell.self)
            cell.titleOlt.text = UserDefaults.name
            if UserDefaults.isSubscribe{
                if !UserDefaults.isSubscriptionExpired{
                    cell.descriptionOlt.text = UserDefaults.getReadableSubscriptionType()
                    cell.descriptionOlt.textColor = AppColor.yellow
                }
            }else{
                cell.descriptionOlt.textColor = AppColor.white
                cell.descriptionOlt.text = AppString.Description.noSubscriptionsAvailable
            }
            Utilities.sharedInstance.setImageWithUrl(imgStr: UserDefaults.profileImage, imgView: cell.imageOlt)
            cell.didTapNext = { sender in
                self.didTap(index: sender.tag)
            }
            cell.selectionStyle = .none
            return cell
            
        case .Home:
            let cell = tblView.dequeueCell(with: MenuCell.self)
            cell.labelOlt.text = options[indexPath.row].title
            cell.selectionStyle = .none
            cell.nextBtnOlt.tag = indexPath.row
            cell.didTapNext = { sender in
                self.didTap(index: sender.tag)
            }
            return cell
        case .myAccount:
            let cell = tblView.dequeueCell(with: MenuCell.self)
            cell.labelOlt.text = options[indexPath.row].title
            cell.selectionStyle = .none
            cell.nextBtnOlt.tag = indexPath.row
            cell.didTapNext = { sender in
                self.didTap(index: sender.tag)
            }
            return cell
            
        case .AboutUs:
            let cell = tblView.dequeueCell(with: MenuCell.self)
            cell.labelOlt.text = options[indexPath.row].title
            cell.selectionStyle = .none
            cell.nextBtnOlt.tag = indexPath.row
            cell.didTapNext = { sender in
                
                self.didTap(index: sender.tag)
            }
            return cell
        case .ContactUs:
            let cell = tblView.dequeueCell(with: MenuCell.self)
            cell.labelOlt.text = options[indexPath.row].title
            cell.selectionStyle = .none
            cell.nextBtnOlt.tag = indexPath.row
            cell.didTapNext = { sender in
                
                self.didTap(index: sender.tag)
            }
            return cell
        case .FAQ:
            let cell = tblView.dequeueCell(with: MenuCell.self)
            cell.labelOlt.text = options[indexPath.row].title
            cell.selectionStyle = .none
            cell.nextBtnOlt.tag = indexPath.row
            cell.didTapNext = { sender in
                
                self.didTap(index: sender.tag)
            }
            return cell
        case .PrivacyPolicy:
            let cell = tblView.dequeueCell(with: MenuCell.self)
            cell.labelOlt.text = options[indexPath.row].title
            cell.selectionStyle = .none
            cell.nextBtnOlt.tag = indexPath.row
            cell.didTapNext = { sender in
                self.didTap(index: sender.tag)
            }
            return cell
        case .TermOfService:
            let cell = tblView.dequeueCell(with: MenuCell.self)
            cell.labelOlt.text = options[indexPath.row].title
            cell.selectionStyle = .none
            cell.nextBtnOlt.tag = indexPath.row
            cell.didTapNext = { sender in
                self.didTap(index: sender.tag)
            }
            return cell
        case .Logout:
            let cell = tblView.dequeueCell(with: MenuCell.self)
            cell.labelOlt.text = options[indexPath.row].title
            cell.selectionStyle = .none
            cell.nextBtnOlt.tag = indexPath.row
            cell.addBottomLeftCorner(to: cell.OuterView,radius: Corner_26)
            cell.borderWidth.isHidden = true
            cell.didTapNext = { sender in
                self.didTap(index: sender.tag)
            }
            return cell
        case .closeTab:
            let cell = tblView.dequeueCell(with: CloseTabBarCell.self)
            cell.didTapSum = { [weak self] sender in
                guard let self = self else { return }
                self.closeSideMenu()
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = MoreRows.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for MoreRows")
        }
        switch rowType {
        case .Home,.AboutUs,.ContactUs,.PrivacyPolicy,.TermOfService,.FAQ,.Logout,.myAccount:
            return 60
        case .profile:
            return 90
        case .closeTab:
            return 110
        }
    }
}

//MARK: logout.
extension MoreViewController{
    private  func logout(){
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithDoubleButtonViewController") as! AlertWithDoubleButtonViewController
        vc.image = UIImage(named: "ic_logOut")
        vc.content = AppString.Alert.confirmLogout
        vc.heading = AppString.Header.logOut
        vc.firstBtnTitle = AppString.BtnTitle.yes
        vc.isHiddenRequired = false
        vc.secondBtnTitle = AppString.BtnTitle.no
        vc.titleColor2 = AppColor.warning ?? .orange
        vc.borderColor2 = AppColor.warning ?? .orange
        vc.firstBackColor =  AppColor.warning ?? .orange
        vc.secondBackColor =  .white
        
        var options = SheetOptions()
        options.shrinkPresentingViewController = false
        options.pullBarHeight = Height_30
        vc.firstBtnClosure = {
            if Reachability.isConnectedToNetwork(){
                let token = UserDefaults.accessToken
                let param = LogoutRequest(device_token: token)
                self.logoutViewModel.logout(parameters: param)
                self.dismiss(animated: true)
                SVProgressHUD.show()
            }
            else {
                DispatchQueue.main.async {
                    Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
                }
            }
        }
        
        let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.40) : .percent(0.50)], options: options)
        
        sheet.cornerRadius = Corner_32
        //sheet.overlayColor = .black.withAlphaComponent(0.9)
        sheet.dismissOnPull = true
        sheet.dismissOnOverlayTap = true
        sheet.gripSize = CGSize(width: Width_50, height: Height_0)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func clearUserDetails() {
        UserDefaults.accessToken = ""
        UserDefaults.userId = 0
        UserDefaults.isSubscribe = false
        UserDefaults.subscribeType = ""
        UserDefaults.isSubscriptionExpired = false
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        IAPManager.shared.removeAllUnfinishedTransactions()
        ReceiptManager.shared.clearReceipt()
    }
}


//MARK:- API Delegate management
extension MoreViewController: UserServices{
    func reloadData() {
        debugLog("reload data")
        debugLog("userDefault token \(UserDefaults.accessToken )")
        
        //For Logout
        if self.logoutViewModel.requestType == .logout {
            if let dict = self.logoutViewModel.logoutDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    debugLog("success API Response")
                    SVProgressHUD.dismiss()
                    //login cred, details, remember me from userdefaults
                    Utilities.sharedInstance.clearUserDetails()
//                    self.clearUserDetails()
                    sceneDel.navigateToLandingScreen()
                    self.logoutViewModel.requestType = .none
                    self.tblView.reload()
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: self.logoutViewModel.logoutDict?.message ?? "")
                default:
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
    }
    
    func showError(error: String) {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
}

