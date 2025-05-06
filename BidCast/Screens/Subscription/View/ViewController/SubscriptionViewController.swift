//
//  SubscriptionViewController.swift
//  Well Genius App
//
//  Created by Fazal-JAM-E-329 on 11/12/24.
//

import UIKit
import SVProgressHUD
import FittedSheets
import StoreKit
//import StoreKitsubscriptionStatus

class SubscriptionViewController: UIViewController {
    
    // MARK: IBOutlets.
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var subscriptionTbl: UITableView!
    @IBOutlet var skip: UIButton!
    
    // MARK: Properties.
    var colorArray = [AppColor.primary,AppColor.primary,AppColor.turquoise]
    var selectedIndexPath: IndexPath?
    private var productsRequest: SKProductsRequest?
    private var availableProducts: [Product] = []
    var subscription = String()
    var isPurchasing = false
    var subscriptionDevice = "iOS"
    var latestTrxnId: String = ""
    var selectedSubscraptionType = ""
    var availableSubscription: [SubsProductModel] = []
    var subscriptionManager: IAPManager?
    var selectedProductPrice = String()
    var selectedPlanIndex: Int = 0
    var index = -1
    var isfor = ""
    var checksubscription = false // Fetch active subscription from the server (dismiss loader)
    var avaisubscription = false  // Fetch subscription from StoreKit (dismiss loader)
    var isActive = false
    var isPurchaseRequested: Bool = false
    
    // MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCellTableView()
    }
    
    // MARK: ViewLife Cycle Methods.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IAPManager.shared.presentingViewController = self
        IAPManager.shared.removeAllUnfinishedTransactions()
        if isfor == "SignIn" {
            ReceiptManager.shared.clearReceipt()
        }
        clearSubscriptionModel()
        self.subscriptionManager = IAPManager.shared
        self.subscriptionManager?.initialize()
        self.observeSubscription()
    }
    
    // MARK: clearSubscriptionModel.
    func clearSubscriptionModel() {
        self.availableSubscription = []
        self.selectedIndexPath = nil
        self.isPurchasing = false
    }
    
    // MARK: didTabBack.
    @objc private func didTabBack() {
        self.goToBack()
    }
   
    // MARK: registerCellTableView.
    private func registerCellTableView() {
        let cellIds = [AppHeaderCell.identifier, SubscriptionsCell.identifier, SubmitCell.identifier, NoDataTableViewCell.identifier, SecondBtnCell.identifier]
        subscriptionTbl.registerCells(for: cellIds)
        subscriptionTbl.delegate = self
        subscriptionTbl.dataSource = self
        subscriptionTbl.backgroundColor = AppColor.View.bgLightMist
        subscriptionTbl.separatorStyle = .none
        subscriptionTbl.showsVerticalScrollIndicator = false
        configureHeaderView()
    }
    
    //MARK: configureHeaderView.
    private func configureHeaderView() {
        self.headerView.headerViewSetup(leftButtonHidden: false, headerName: AppString.VCName.subscriptions,leftButtonAction: didTabBack)
        self.setupUI()
    }
    
    //MARK: configureHeaderView.
    private func setupUI(){
        skip.makeCornerRounded(ofSize: Corner_22)
        skip.setupButton(title: AppString.BtnTitle.skip, titleColor: AppColor.primary, borderWidth: Width_01, borderColor: AppColor.primary)
    }
    
    // MARK: reloadTbl
    private func reloadTbl() {
        if avaisubscription == true && checksubscription == true {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.subscriptionTbl.reloadData()
            }
        }
        if isfor != "" {
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.subscriptionTbl.reloadData()
            }
        }
    }
    
    // MARK: apiFetchSuccessGetSubscription.
    private func apiFetchSuccessGetSubscription() {
//        DispatchQueue.main.async {
//            SVProgressHUD.dismiss()
//            
//            if self.viewModel.subscriptionListDict?.status == "success" {
//                self.checksubscription = true
//                if let data = self.viewModel.subscriptionListDict?.data {
//                    if data.isExpired == "no" {
//                        UserDefaults.isSubscribe = true
//                        UserDefaults.subscribeType = data.subscriptionType ?? ""
//                        self.isActive = true
//                    } else {
//                        UserDefaults.isSubscribe = false
//                        UserDefaults.subscribeType = ""
//                        self.isActive = false
//                    }
//                }
//                self.reloadTbl()
//            } else {
//                SVProgressHUD.dismiss()
//                Utilities.sharedInstance.showAlertController(title: "Error", message: (self.viewModel.subscriptionListDict?.message ?? ""), sourceViewController: self)
//            }
//        }
    }
    
    // MARK: saveUserSubscription.
    private func saveUserSubscription() {
//        guard self.index != -1 else {
//            print("Not a valid subscription")
//            return
//        }
//        print(subscriptionDevice)
//        print(latestTrxnId)
//        guard let receipt = ReceiptManager.shared.getReceipt() else {
//            print("No receipt found")
//            return
//        }
//        
//        let selectedSubscription = self.availableSubscription[self.index]
//        let param = SaveSubscriptionParam(
//            subscription: selectedSubscription.name,
//            receipt: receipt,
//            platform: subscriptionDevice,
//            plan_type: "Paid"  //Free/Paid
//        )
//        
//        if Reachability.isConnectedToNetwork() {
//            Task(priority: .high) {
//                do {
//                    SVProgressHUD.show()
//                    try await self.viewModel.saveSubscraptionReceipt(param: param)
//                    apiFetchSuccessSaveSubscription()
//                } catch {
//                    DispatchQueue.main.async {
//                        SVProgressHUD.dismiss()
//                    }
//                    print("Error in saving subscription: \(error)")
//                    Utilities.sharedInstance.showToast(source: self, message: error.localizedDescription)
//                }
//            }
//        } else {
//            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
//        }
    }
    
    // MARK: apiFetchSuccessSaveSubscription.
    private func apiFetchSuccessSaveSubscription() {
//        DispatchQueue.main.async {
//            SVProgressHUD.dismiss()
//            if self.viewModel.subscriptionSaveDict?.status == "success" {
//                sceneDel.navigateToLandingScreen()
//            } else {
//                Utilities.sharedInstance.showAlertController(title: "Error", message: (self.viewModel.subscriptionSaveDict?.message ?? ""), sourceViewController: self)
//            }
//        }
    }
    
    // MARK: purchseRequest.
    private func purchseRequest() {
        if Reachability.isConnectedToNetwork() {
            if self.index != -1 {
                if ((self.subscriptionManager?.canMakePurchases()) != nil) && self.availableSubscription.count != 0  {
                    self.subscription = self.availableSubscription[index].identifier
                    self.isPurchasing = true
                    self.selectedProductPrice = self.availableSubscription[index].price
                    print("Purchase Started >>> \(self.subscription)")
                    self.subscriptionManager?.purchaseProduct(self.subscription)
                    self.observeSubscription()
                } else {
                    print("Purchase cannot be made.")
                }
            } else {
                Utilities.sharedInstance.showAlertController(title: "Alert", message: "Please select plan first.", sourceViewController: self)
            }
        } else {
            Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
        }
    }
    
    //MARK: changeSubscriptionAlert
//    func changeSubscriptionAlert(){
//        let storyBoard = UIStoryboard(name: "Alert", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "Alert2ViewController") as! Alert2ViewController
//        vc.image = UIImage(named: "newspaper")?.withTintColor(AppColor.Button.bgOrange ?? UIColor.orange)
//        vc.content =  AppString.Alert.switchSubscription
//        vc.heading =  AppString.Header.subscription
//        vc.firstBtnTitle = AppString.BtnTitle.yes
//        vc.secondBtnTitle = AppString.BtnTitle.no
//        vc.isHiddenRequired = false
//        
//        var options = SheetOptions()
//        options.shrinkPresentingViewController = false
//        options.pullBarHeight = Height_30
//        vc.firstBtnClosure = {
//            self.dismiss(animated: true)
//            IAPManager.shared.removeAllUnfinishedTransactions()
//            self.purchseRequest()
//        }
//        vc.secondBtnClosure = {
//            SVProgressHUD.dismiss()
//        }
//        let sheet = SheetViewController(controller: vc, sizes: [UIDevice.current.hasNotch ? .percent(0.45) : .percent(0.55)], options: options)
//        sheet.cornerRadius = Corner_32
//        sheet.overlayColor = .black.withAlphaComponent(1.0)
//        sheet.dismissOnPull = false
//        sheet.dismissOnOverlayTap = true
//        sheet.gripSize = CGSize(width: Width_50, height: Height_0)
//        self.present(sheet, animated: true, completion: nil)
//    }
    
    // MARK: observeSubscription
    private func observeSubscription() {
        self.subscriptionManager?.purchaseStatusBlock = { alert, transaction in
            switch alert {
            case .isPurchasing:
                SVProgressHUD.show()
            case .disabled:
                print("Purchase disabled")
                SVProgressHUD.dismiss()
                self.isPurchaseRequested = false
                self.subscriptionManager?.stopObserving()
            case .restored:
                print("Purchase restored")
                self.validateSubscription()
                self.isPurchaseRequested = false
                self.subscriptionManager?.stopObserving()
                SVProgressHUD.dismiss()
            case .purchased:
                print("Purchase successful")
                SVProgressHUD.dismiss()
                self.validateSubscription()
                self.isPurchaseRequested = false
                self.subscriptionManager?.stopObserving()
                self.isPurchasing = true
            case .failed, .invalid:
                print("Purchase failed or invalid")
                SVProgressHUD.dismiss()
                self.isPurchaseRequested = false
                Utilities.sharedInstance.showAlertController(title: "Error", message: "Transaction failed. Please try again.", sourceViewController: self)
                self.subscriptionManager?.stopObserving()
            case .initialized:
                print("Initialized")
                break
            case .productLoaded(let result):
                print("Products loaded")
                SVProgressHUD.dismiss()
                let subscriptionOrder = ["Bronze", "Silver", "Gold"]
                self.availableSubscription = result.sorted {
                    guard let firstIndex = subscriptionOrder.firstIndex(of: $0.name),
                          let secondIndex = subscriptionOrder.firstIndex(of: $1.name) else {
                        return false
                    }
                    return firstIndex < secondIndex
                }
                self.avaisubscription = true
                self.reloadTbl()
            }
        }
    }
    
    // MARK: validateSubscription
    private func validateSubscription() {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
           FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                ReceiptManager.shared.setReceipt(receiptString)
                self.saveUserSubscription()
            } catch {
                print("Couldn't read receipt data with error: " + error.localizedDescription)
            }
        } else {
            print("No receipt found.")
        }
    }
    
    // MARK: didTapBack
    @objc private func didTapBack(){
        self.goToBack()
    }
    
    // MARK: tappedSubmitBtn
    @objc private func tappedSubmitBtn(){
        print("Print succesfully")
    }
    
    // MARK: skipForNowbtnAction
    @IBAction func skipForNowbtnAction(_ sender: UIButton) {
        sceneDel.navigateToLandingScreen()
    }
    
    // MARK: subscribeBtnAction
    @IBAction func subscribeBtnAction(_ sender: Any) {
        print("subscribeBtnAction")
        
//        guard index >= 0 && index < availableSubscription.count else {
//            Utilities.sharedInstance.showAlertController(title: AppString.Header.alert, message: AppString.Alert.allReadySubscribed, sourceViewController: self)
//            return
//        }
//        resetPurchaseState()
//        self.selectedPlanIndex = index
//        self.subscriptionTbl.reloadData()
//        let currentSubscriptionType = self.viewModel.subscriptionListDict?.data?.subscriptionType
//        
//        if UserDefaults.isSubscribe {
//            if avaisubscription && checksubscription {
//                if self.availableSubscription[index].identifier == currentSubscriptionType {
//                    Utilities.sharedInstance.showAlertController(title: AppString.Header.alert, message: AppString.Alert.allReadySubscribed, sourceViewController: self)
//                } else {
//                    self.changeSubscriptionAlert()
//                }
//            } else {
//                SVProgressHUD.show()
//                IAPManager.shared.removeAllUnfinishedTransactions()
//                self.purchseRequest()
//            }
//        } else {
//            SVProgressHUD.show()
//            IAPManager.shared.removeAllUnfinishedTransactions()
//            self.purchseRequest()
//        }
    }
    
    private func resetPurchaseState() {
        self.isPurchasing = false
        self.isPurchaseRequested = false
        SVProgressHUD.dismiss()
        IAPManager.shared.removeAllUnfinishedTransactions()
        IAPManager.shared.initialize()
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource.
extension SubscriptionViewController: UITableViewDelegate, UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        if isfor != ""{
            return 2
        }else{
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = SectionType.section(for: section)
        switch sectionType {
        case .section0:
            return 1
        default:
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueCell(with: AppHeaderCell.self)
            cell.titleOlt.text = AppString.Header.subscriptions
            cell.outerViewOlt.backgroundColor = AppColor.View.bgLightMist
            cell.selectionStyle = .none
            return cell
        }
        else {
//            if self.availableSubscription.count == 0 {
//                let cell = tableView.dequeueCell(with: NoDataTableViewCell.self)
//                cell.labelOlt.text = AppString.NoData.noSubscriptionsAvailable
//                cell.selectionStyle = .none
//                return cell
//            }
            
//            else{
                let cell = tableView.dequeueCell(with: SubscriptionsCell.self)
                cell.outerViewOlt.backgroundColor = AppColor.View.bgLightMist
            cell.innerViewOlt.layer.borderWidth = Width_02
            cell.innerViewOlt.layer.borderColor = colorArray[indexPath.row]?.cgColor
            cell.learnMoreBtn.backgroundColor = colorArray[indexPath.row]
                cell.selectionStyle = .none
    
                
//                if self.viewModel.subscriptionListDict?.data?.subscriptionType == self.availableSubscription[indexPath.row].identifier {
//                    if self.viewModel.subscriptionListDict?.data?.isExpired == "no" {
//                        selectedIndexPath = indexPath
//                    }
//                }
                if indexPath == selectedIndexPath && isActive == true{
//                    cell.innerViewOlt.backgroundColor =  #colorLiteral(red: 0.1490196078, green: 0.2117647059, blue: 0.2588235294, alpha: 1)
//                    cell.titleOlt.textColor = UIColor.white
//                    cell.detailOlt.textColor = UIColor.white
//                    cell.amountOlt.textColor = UIColor.white
//                    cell.dollarOlt.textColor = UIColor.white
//                    cell.monthlyOlt.textColor = UIColor.white
//                    cell.activeOlt.isHidden = false
//                    cell.activeView.isHidden = false
                }else if indexPath == selectedIndexPath {
//                    cell.innerViewOlt.backgroundColor =  #colorLiteral(red: 0.1490196078, green: 0.2117647059, blue: 0.2588235294, alpha: 1)
//                    cell.titleOlt.textColor = UIColor.white
//                    cell.detailOlt.textColor = UIColor.white
//                    cell.amountOlt.textColor = UIColor.white
//                    cell.dollarOlt.textColor = UIColor.white
//                    cell.monthlyOlt.textColor = UIColor.white
//                    cell.activeOlt.isHidden = true
//                    cell.activeView.isHidden = true
                }
                else {
//                    cell.innerViewOlt.backgroundColor = UIColor.white
//                    cell.titleOlt.textColor = UIColor.black
//                    cell.detailOlt.textColor = UIColor.black
//                    cell.amountOlt.textColor = UIColor.black
//                    cell.dollarOlt.textColor = UIColor.lightGray
//                    cell.monthlyOlt.textColor = UIColor.lightGray
//                    cell.activeOlt.isHidden = true
//                    cell.activeView.isHidden = true
                }
                return cell
//            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let previouslySelectedIndexPath = selectedIndexPath, previouslySelectedIndexPath != indexPath {
            if let previousCell = tableView.cellForRow(at: previouslySelectedIndexPath) as? SubscriptionsCell {
//                previousCell.innerViewOlt.backgroundColor = UIColor.white
//                previousCell.titleOlt.textColor = UIColor.black
//                previousCell.detailOlt.textColor = UIColor.black
//                previousCell.amountOlt.textColor = UIColor.black
//                previousCell.dollarOlt.textColor = UIColor.lightGray
//                previousCell.monthlyOlt.textColor = UIColor.lightGray
            }
        }
        if let selectedCell = tableView.cellForRow(at: indexPath) as? SubscriptionsCell {
            let selectedSubscription = self.availableSubscription[indexPath.row]
//            let currentSubscriptionIdentifier = self.viewModel.subscriptionListDict?.data?.subscriptionType
            
//            selectedCell.innerViewOlt.backgroundColor =  #colorLiteral(red: 0.1490196078, green: 0.2117647059, blue: 0.2588235294, alpha: 1)
//            selectedCell.titleOlt.textColor = UIColor.white
//            selectedCell.detailOlt.textColor = UIColor.white
//            selectedCell.amountOlt.textColor = UIColor.white
//            selectedCell.dollarOlt.textColor = UIColor.white
//            selectedCell.monthlyOlt.textColor = UIColor.white
        }
        selectedIndexPath = indexPath
        self.index = indexPath.row
        
    }
}
