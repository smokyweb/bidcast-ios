//
//  OurSubscriptionViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import UIKit
import StoreKit
import SVProgressHUD
import FittedSheets

enum ourSubscriptionSection: Int,CaseIterable {
    case ourSubscriptionHeader
    case getSubscriptionDescription
    case appleSubscriptionList
    
    func numberOfRows(data: [ourSubscriptionSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class OurSubscriptionViewController: UIViewController, UIAdaptivePresentationControllerDelegate {
    
    // MARK: IBOutlets.
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var subscribeBtn: UIButton!
    @IBOutlet weak var skipForNow: UIButton!
    @IBOutlet weak var heightConstraintSkipForNow: NSLayoutConstraint!
    
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    
    //MARK: sectionData
    lazy var sectionData: [ourSubscriptionSection: Int] = [
        .ourSubscriptionHeader: 1,
        .getSubscriptionDescription : 0,
        .appleSubscriptionList: 1
    ]
    
    
    

    // MARK: Properties
    var isNavFrom = ""
    var index = 2
    var selectedID = 0
    var selectedIndexPath : IndexPath?
    
    var tittleArr = [String]()
    private var productsRequest : SKProductsRequest?
    private var availableProducts : [Product] = []
    var isPurchasing = false
    var receipt = String()
    var subscriptionDevice = "iOS"
    var latestTrxnId: String = ""
    var selectedSubscraptionType = ""
    var subscription = String()
    var selectedProductPrice = String()
   
    var subscriptionManager: IAPManager?
    var viewModel = SubscriptionViewModel()
    var getAPISubscriptionList : [SubscriptionsListModel] = []{
        didSet {
            if getAPISubscriptionList.count <= 0 {
                SVProgressHUD.show()
            }
        }
    }
    var availableSubscription: [SubsProductModel] = [] {
        didSet {
            if availableSubscription.count > 0 {
                fetchApi()
            }
        }
    }
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initialViewModel()
        self.loadInitialSetup()
        self.configureHeaderView()
        self.navigationController?.presentationController?.delegate = self
    }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("did dismiss")
//        self.cancel?()
    }
    
    // MARK: Life Cycle
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        IAPManager.shared.removeAllUnfinishedTransactions()
        self.loadInitialSetup()
//        self.fetchApi()
//        self.sectionData[.appleSubscriptionList] = self.getAPISubscriptionList.count
        
    }
    
    func updateSubscriptionUI() {
        SVProgressHUD.show()
        let sub = self.viewModel.validateSubscriptionDict?.data??.subscription
        
        if let sub = sub, sub.isExpired == "no" {
            // If the subscription type exists and is not nil
            let subscriptionType = sub.subscriptionType
            if subscriptionType != nil{
                // Find the index of the subscription type in the list
                if let subscriptionIndex = getAPISubscriptionList.firstIndex(where: { $0.planIDIos == subscriptionType }) {
                    selectedIndexPath = IndexPath(row: subscriptionIndex, section: 2)
                }
            }
        } else {
            // If no active subscription or it's expired, set to free plan (index 3)
            selectedIndexPath = IndexPath(row: 2, section: 2)
        }
        SVProgressHUD.dismiss()
        tblView.reloadData()
    }

    
    //MARK: loadInitialSetup.
    func loadInitialSetup(){
        self.subscriptionManager = IAPManager.shared
        self.subscriptionManager?.initialize()
        self.observeSubscription()
        if getAPISubscriptionList.count <= 0 {
            SVProgressHUD.show()
        }else{
            SVProgressHUD.dismiss()
        }
    }
    
    //MARK: configureHeaderView.
    private func configureHeaderView() {
        self.headerView.headerViewSetup(rightButtonHidden: isNavFrom == AppString.navigateFrom.signUp ? true : false,
                                        leftButtonHidden: isNavFrom == AppString.navigateFrom.signUp ? true : false,
                                        headerName: AppString.VCName.subscriptions,rightButtonAction: didTapSideMenu,leftButtonAction: didTabBack)
        tblView.configTblView()
        subscribeBtn.makeCornerRounded(ofSize: Corner_26)
        skipForNow.makeCornerRounded(ofSize: Corner_26)
        
        if isNavFrom == AppString.navigateFrom.signUp {
            self.heightConstraintSkipForNow.constant = 50
        } else {
            self.heightConstraintSkipForNow.constant = 0
        }
        self.configureTblView()
    }
    
    @objc private func didTapSideMenu(){
        self.openSideMenu()
    }
    
    //MARK: configureTblView.
    func configureTblView(){
        let cellIds = [AppHeaderCell.identifier, SubscriptionsCell.identifier, SubmitCell.identifier, NoDataTableViewCell.identifier, SecondBtnCell.identifier,LabelCell.identifier]
        tblView.registerCells(for: cellIds)
        tblView.delegate = self
        tblView.dataSource = self
        tblView.configTblView()
        subscribeBtn.makeCornerRounded(ofSize: Corner_26)
        skipForNow.makeCornerRounded(ofSize: Corner_26)
        subscribeBtn.titleLabel?.font = OutFitFont.defaultExtraBold(size: 15).value
        skipForNow.titleLabel?.font = OutFitFont.defaultExtraBold(size: 15).value
    }
    
    // MARK: didTabBack.
    @objc private func didTabBack() {
        self.goToBack()
    }
    
    // MARK: skipForNowbtnAction
    @IBAction func skipForNowbtnAction(_ sender: UIButton) {
        sceneDel.navigateToLandingScreen()
    }
    
// MARK: subscribeBtnAction
    @IBAction func subscribeBtnAction(_ sender: UIButton) {
        if index == 2{
            if UserDefaults.isSubscriptionExpired || UserDefaults.subscribeType == "Free"{
                self.alreadySubscribedThisPlan()
            }else{
                self.alreadyPaidSubscribedPlan()
            }
        }else{
            let selectedPlan = getAPISubscriptionList[self.index]
            if !UserDefaults.isSubscriptionExpired{
                if UserDefaults.subscribeType == selectedPlan.planIDIos{
                    self.alreadySubscribedThisPlan()
                }else{
                    let selectedProductIdentifier = getAPISubscriptionList[self.index].planIDIos
                    if let manager = subscriptionManager, manager.canMakePurchases() {
                        SVProgressHUD.show()
                        IAPManager.shared.removeAllUnfinishedTransactions()
                        self.subscriptionManager?.startObserving()
                        manager.purchaseProduct(selectedProductIdentifier ?? "")
                    }
                }
            }else{
                let selectedProductIdentifier = getAPISubscriptionList[self.index].planIDIos
                if let manager = subscriptionManager, manager.canMakePurchases() {
                    SVProgressHUD.show()
                    IAPManager.shared.removeAllUnfinishedTransactions()
                    self.subscriptionManager?.startObserving()
                    manager.purchaseProduct(selectedProductIdentifier ?? "")
                }
            }
        }
    }
    
    //MARK: fetch api .
    private func fetchApi(){
        if Reachability.isConnectedToNetwork(){
            SVProgressHUD.show()
            self.viewModel.getSubscriptionData()
            self.viewModel.validateSubscriptionRequest()
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    
    // MARK: initialViewModel
    func initialViewModel(){
        self.viewModel.userDelegate = self
    }
    
//    private func getSubscriptionIndex() -> Int? {
//        let subscription = self.viewModel.validateSubscriptionDict?.data??.subscription
//        let subscriptionType = subscription?.subscriptionType
//        let subscriptionExpired = subscription?.isExpired
//        if subscriptionExpired == "no" {
//            
//        }
//        else {
//            //subscription expired: Manage Free plan
//        }
//        if !self.availableSubscription.isEmpty {
//            let sub = self.availableSubscription.filter({$0.identifier == subscriptionType})
//            if !sub.isEmpty, let data = sub.first, subscriptionExpired == "no" {
//                
//            }
//            if subscriptionType == self.availableSubscription[indexPath.row].identifier {
//                if subscriptionExpired == "no" {
//                    selectedIndexPath = indexPath
//                }
//            }
//        }
//        return nil
//    }
}

// MARK: UITableViewDataSource,UITableViewDelegate.
extension OurSubscriptionViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return ourSubscriptionSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = ourSubscriptionSection(rawValue: section) else { return 0 }
        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = ourSubscriptionSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for ourSubscriptionSection")
        }
        switch rowType {
        case .ourSubscriptionHeader:
            let cell = tableView.dequeueCell(with: AppHeaderCell.self)
            cell.titleOlt.text = AppString.Title.ourSubscription
            cell.outerViewOlt.backgroundColor = .ultraLightGray
            return cell
        case .getSubscriptionDescription:
            let cell = tableView.dequeueCell(with: LabelCell.self)
            cell.titleOlt.text = AppString.Title.getSubscription
            cell.contentView.backgroundColor = .ultraLightGray
            cell.innerViewOlt.backgroundColor = .ultraLightGray
            return cell
        case .appleSubscriptionList:
            if self.getAPISubscriptionList.count == 0 {
                let cell = tableView.dequeueCell(with: NoDataTableViewCell.self)
                cell.labelOlt.text = AppString.Description.noSubscriptionsAvailable
                cell.selectionStyle = .none
                return cell
            }
            else{
                let cell = tableView.dequeueCell(with: SubscriptionsCell.self)
                let subscription = self.getAPISubscriptionList[indexPath.row]
                cell.titleOlt.text = subscription.title
                cell.detailOlt.text = subscription.benefits
                cell.discountViewOlt.isHidden = subscription.isBestOffer == 1 ? false : true
                let sub = self.viewModel.validateSubscriptionDict?.data??.subscription
                let subscriptionType = sub?.subscriptionType
                let subscriptionExpired = sub?.isExpired
                if sub != nil && subscriptionExpired == "no"{
                    if subscriptionType == subscription.planIDIos {
                        cell.selctedSubOlt.image = UIImage(named: "ic_radio_checked")
                        cell.innerViewOlt.addBorders(of: AppColor.primary ?? .primary, width: Width_01)
                        cell.activeOlt.isHidden = false
                        cell.activeView.isHidden = false
                    }else {
                        cell.selctedSubOlt.image = UIImage(named: "ic_radio_unchecked")
                        cell.innerViewOlt.addBorders(of: .clear, width: Width_0)
                        cell.activeOlt.isHidden = true
                        cell.activeView.isHidden = true
                    }
                }else {
                    //free plan
                    if subscription.planType == "free" {
                        cell.selctedSubOlt.image = UIImage(named: "ic_radio_checked")
                        cell.innerViewOlt.addBorders(of: AppColor.primary ?? .primary, width: Width_01)
                        cell.activeOlt.isHidden = false
                        cell.activeView.isHidden = false
                    }else {
                        cell.selctedSubOlt.image = UIImage(named: "ic_radio_unchecked")
                        cell.innerViewOlt.addBorders(of: .clear, width: Width_0)
                        cell.activeOlt.isHidden = true
                        cell.activeView.isHidden = true
                    }
                }
                
                if selectedIndexPath == indexPath {
                    cell.selctedSubOlt.image = UIImage(named: "ic_radio_checked")
                    cell.innerViewOlt.addBorders(of: AppColor.primary ?? .primary, width: Width_01)
                } else {
                    cell.selctedSubOlt.image = UIImage(named: "ic_radio_unchecked")
                    cell.innerViewOlt.addBorders(of: .clear, width: Width_0)
                }
                cell.outerViewOlt.backgroundColor = .ultraLightGray
                cell.selectionStyle = .none
                return cell
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = ourSubscriptionSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for HomeSection")
        }
        switch rowType {
        case .ourSubscriptionHeader:
            return Const.Height.header
        case .appleSubscriptionList:
//            if indexPath.row == 2{
//                return  175
//            }else{
                return 115
//            }
        default:
            return Const.Height.AutomaticDimension
        }
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowType = ourSubscriptionSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for HomeSection")
        }
        switch rowType {
        case .appleSubscriptionList:
            if selectedIndexPath != indexPath {
                let oldIndex = selectedIndexPath
                selectedIndexPath = indexPath
                self.index = indexPath.row
                // Reload only the old and new selected rows to update the selection state
                var indexPathsToReload = [indexPath]
                if let oldIndex = oldIndex {
                    indexPathsToReload.append(oldIndex)
                }
                
                tableView.reloadRows(at: indexPathsToReload, with: .automatic)
               }
        default:
            break
        }
    }
}

//!!!: - Subscription Handler Starts Here
extension OurSubscriptionViewController {
    
    //MARK: Subscription Observer
    func observeSubscription() {
        self.subscriptionManager?.purchaseStatusBlock = {
            alert, transaction in
            switch alert {
            case .isPurchasing:
                SVProgressHUD.show()
            case .disabled:
                debugLog("Disabled")
                SVProgressHUD.dismiss()
                self.subscriptionManager?.stopObserving()
                return
            case .restored:
                debugLog("Restored")
                SVProgressHUD.dismiss()
                self.validateSubscription()
                self.subscriptionManager?.stopObserving()
                return
            case .purchased:
                debugLog("Purchased")
                SVProgressHUD.dismiss()
                self.validateSubscription()
                self.subscriptionManager?.stopObserving()
                return
            case .failed, .invalid:
                debugLog("Failed or Invalid")
                SVProgressHUD.dismiss()
                self.subscriptionManager?.stopObserving()
                return
            case .initialized:
                debugLog("Initialized")
                SVProgressHUD.show()
                break
            case .productLoaded(let result):
                SVProgressHUD.show()
                // Sort the products based on your predefined order
                let productOrder = ["io.annually","io.monthly"]
                self.availableSubscription = result.sorted { productOrder.firstIndex(of: $0.identifier) ?? Int.max < productOrder.firstIndex(of: $1.identifier) ?? Int.max }
                DispatchQueue.main.async {
                    debugLog(">>>>>>>>>\(result)")
//                    self.sectionData[.appleSubscriptionList] = self.availableSubscription.count
                    self.tblView.reloadData()
                    self.subscriptionManager?.stopObserving()
//                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    
    
    //MARK: Subscription Validation
    func validateSubscription() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                self.receipt = receiptString
                self.saveUserSubscription()
            }
            catch {
                debugLog("Couldn't read receipt data with error: " + error.localizedDescription)
            }
        }
    }
    
    func saveUserSubscription() {
        debugLog(selectedProductPrice)
        debugLog(receipt)
        debugLog(subscriptionDevice)
        debugLog(latestTrxnId)
        if index == 2{
            selectedID = index + 3
        }else if index == 0{
            selectedID = index + 2
        }else if index == 1{
            selectedID = index
        }
        SVProgressHUD.show()
        let param = AddSubscriptionsRequest(plan_id: selectedID, receipt: self.receipt, platform: subscriptionDevice)
        debugLog(param)
        self.viewModel.addSubscription(parameters: param)
        
    }
}

//MARK: OurSubscriptionViewController.
extension OurSubscriptionViewController : UserServices{
    func reloadData() {
        //MARK: getSubscription Success.
        if self.viewModel.requestType == .getSubscription {
            if let dict = self.viewModel.getSubscriptionDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success API Response11")
                    self.getAPISubscriptionList = (dict.data ?? []) ?? []
                    self.sectionData[.appleSubscriptionList] = self.getAPISubscriptionList.count > 0 ? self.getAPISubscriptionList.count : 0
//                    SVProgressHUD.dismiss()
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
        }
        
        
        //MARK: addSubscription Success.
        if self.viewModel.requestType == .addSubscription {
            if let dict = self.viewModel.addSubscriptionDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success API Response11")
                    SVProgressHUD.dismiss()
                    self.viewModel.requestType = .none
                    sceneDel.navigateToLandingScreen()
                    self.tblView.reload()
                case .failure:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
                default:
                    SVProgressHUD.dismiss()
                    Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
                }
            }
        }
        
        //MARK: validateSubscription Success.
        if self.viewModel.requestType == .validateSubscriptions {
            if let dict = self.viewModel.validateSubscriptionDict {
                let statusType = APIResponseStatus(rawValue: dict.status ?? "")
                switch statusType {
                case .success:
                    //success API Response
                    debugLog("success API Response")
//                    SVProgressHUD.dismiss()
                    if let subscriptionData = dict.data {
                        UserDefaults.isSubscribe = subscriptionData?.isSubscribed ?? false
                        UserDefaults.isSubscriptionExpired = (subscriptionData?.subscription?.isExpired ?? "") == "yes" ? true : false
                        UserDefaults.subscribeType = subscriptionData?.subscription?.subscriptionType ?? ""
//                        UserDefaults.subscriptionMessage = viewModel.validateSubscriptionDict?.message ?? ""
                        self.updateSubscriptionUI()
                    }
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
        }
    }
    
    func showError(error: String) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }
}

//succesuccessfullyAccCreatedAlert
extension OurSubscriptionViewController{
    func succesuccessfullyAccCreatedAlert() {
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithSingleButtonViewController") as! AlertWithSingleButtonViewController
        vc.image = UIImage(named: "ic_Success")
        vc.content = AppString.Alert.successfullyAccCreated
        vc.heading = AppString.Header.success
        vc.firstBtnTitle = AppString.BtnTitle.home
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
    func freeSubscriptionAlert() {
        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "AlertWithSingleButtonViewController") as! AlertWithSingleButtonViewController
        vc.image = UIImage(named: "ic_Success")
        vc.content = AppString.Alert.freeSubscription
        vc.heading = AppString.Header.alert
        vc.firstBtnTitle = AppString.BtnTitle.ok
        vc.isHiddenRequired = true
        var options = SheetOptions()
        options.shrinkPresentingViewController = false
        options.pullBarHeight = Height_30
        vc.firstBtnClosure = {
            self.dismiss(animated: true)
        }
        let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.40) : .percent(0.50)], options: options)
        sheet.cornerRadius = Corner_32
        sheet.overlayColor = .black.withAlphaComponent(0.9)
        sheet.dismissOnPull = false
        sheet.dismissOnOverlayTap = true
        sheet.gripSize = CGSize(width: Width_50, height: Height_0)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func alreadySubscribedThisPlan(){
        let alert = UIAlertController(title: "Alert",
                                      message: AppString.Alert.allReadySubscribed,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alreadyPaidSubscribedPlan(){
        let alert = UIAlertController(title: "Alert",
                                      message: AppString.Alert.alreadyPaidSubscribedPlan,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}







