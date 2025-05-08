//
//  AccountViewController.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 06/05/25.
//

import UIKit

//MARK: Account section
enum AccountSection : Int, CaseIterable {
    case profile
    case segment
    case creditAcc
    case profileDetails
    case paymentAcc
    case tab
    case detailsAcc
    case vacation
    
    func numberOfRows(data: [AccountSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

enum segmentAccount : String {
    case sellerHub
    case account
}

class AccountViewController: UIViewController {

    //MARK: IBOutlets
    
    @IBOutlet weak var tableViewOlt: UITableView!
    @IBOutlet weak var headerViewOlt: HeaderWithAppName!
    
    
    //MARK: Properties
    var sectionData : [AccountSection : Int ] = [
        .profile : 1,
        .segment : 1,
        .creditAcc: 0,
        .profileDetails : 1,
        .paymentAcc: 0,
        .tab : 1,
        .detailsAcc : 0,
        .vacation : 1
    ]
    var moreSection = ["About Us","Contact Us","Sales Tax Exemption","Terms & Conditions","Privacy Policy","F.A.Q"]
    
    var imageName = ["inventory","mic","orders","wallet","tag","tag","shipping","people","seller","shop","analysis","analysis"]
    var tabName = ["Inventory","Shows","My Orders","Wallet","Offers","Tips","Shipping","Affiliate Program","Seller Trainig","Premier Shop","Seller status","Seller Analytics"]
    
    var sellerItems = ["284","$5.2K","4.8"]
    var sellerItemsNAme = ["Items","Revenue","Rating"]
    
    var accPayImage = ["shipping","mic","shop","wallet","tag"]
    var AccountPayment = ["Payment & Shipping","Addresses","Trusted Buyer","Notifications","Preferences"]
    
    var creditName = ["Credits","Coupons"]
    var creditDate = ["284","$5.2K"]
    
    var segmentType: segmentAccount = .sellerHub
    
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureHeaderView()
        configureTableView()
    }

    func configureHeaderView(){
        self.headerViewOlt.headerViewSetup(rightButtonHidden: false,leftButtonHidden: false , headerName: "Account")
    }
    
    private func configureTableView(){
        self.tableViewOlt.delegate = self
        self.tableViewOlt.dataSource = self
        self.tableViewOlt.configTblView(bgColor:.bg)
        
       
        let cellIds = [LocationNameCell.identifier,
                       SegmentCell.identifier,
                       CollectionViewCell.identifier,
                       SwitchEditorAndPhotographerCell.identifier,
                       MenuCell.identifier
                       ]
        tableViewOlt.registerCells(for: cellIds)
        
    }
    func reloadSegmentData(){
        if segmentType == .sellerHub {
            self.sectionData = [
                .profile : 1,
                .segment : 1,
                .creditAcc: 0,
                .profileDetails : 1,
                .paymentAcc: 0,
                .tab : 1,
                .detailsAcc : 0,
                .vacation : 1
            ]
        }else{
            self.sectionData = [
                .profile : 1,
                .segment : 1,
                .creditAcc: 1,
                .profileDetails : 0,
                .paymentAcc: 1,
                .tab : 0,
                .detailsAcc : 6,
                .vacation : 0
            ]
        }
        self.tableViewOlt.reloadData()
    }
    func didTap(index:Int){
        switch index {
        case 0 :
            let vc = Utilities.sharedInstance.getVC(storyBoardName: "Main", vcId: "AboutUsViewController") as! AboutUsViewController
            self.navigationController?.pushViewController(vc, animated: true)
        case 1:
            let vc = Utilities.sharedInstance.getVC(storyBoardName: "Main", vcId: "ContactUsViewController") as! ContactUsViewController
            self.navigationController?.pushViewController(vc, animated: true)
        default:
            print("")
        }
    }
}
extension AccountViewController : UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return AccountSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = AccountSection(rawValue: section) else { return 0 }
       
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
//        switch segmentType{
//        case .sellerHub:
            guard let rowType = AccountSection.allCases[safe: indexPath.section] else {
                fatalError("Invalid index for LoginTableRow")
            }
            switch rowType {
                
            case .profile:
                let cell = tableViewOlt.dequeueCell(with: LocationNameCell.self)
                cell.innerViewOlt.addBorders(of: .black, width: 0.0)
                return cell
            case .segment:
                let cell = tableViewOlt.dequeueCell(with: SegmentCell.self)
                cell.configure(isNavFor: "MyAccountVC")
                cell.onSegmentChanged = { selectedIndex in
                    self.segmentType = selectedIndex == 0 ? .sellerHub : .account
                    self.reloadSegmentData()
                }
                cell.contentView.backgroundColor = .clear
                return cell
            case .creditAcc:
                let cell = tableViewOlt.dequeueCell(with: CollectionViewCell.self)
                cell.isForPayment = true
                cell.isForDetails = false
                cell.segmentType = .account
                cell.creditName = self.creditName
                cell.creditDate = self.creditDate
                cell.collectionViewOlt.reloadData()
                return cell
            case .profileDetails:
                let cell = tableViewOlt.dequeueCell(with: CollectionViewCell.self)
                cell.isForDetails = true
                cell.isForPayment = false
                cell.segmentType = .sellerHub
                cell.sellerItemsNAme = self.sellerItemsNAme
                cell.seller = self.sellerItems
                cell.collectionViewOlt.reloadData()
                return cell
            case .paymentAcc:
                let cell = tableViewOlt.dequeueCell(with: CollectionViewCell.self)
//                cell.onItemSelected = { [weak self] index in
//                    guard let self = self else { return }
//                    switch index {
//                    case 0:
//                        self.pushVC(with: InventoryViewController.self, storyboardName: .account)
//                    default:
//                        break
//                    }
//                }
                cell.isForDetails = false
                cell.isForPayment = false
                cell.segmentType = .account
                cell.accPayImage = self.accPayImage
                cell.AccountPayment = self.AccountPayment
                cell.configure(with: self.AccountPayment)
                return cell
            case .tab:
                let cell = tableViewOlt.dequeueCell(with: CollectionViewCell.self)
                cell.onItemSelected = { [weak self] index in
                    guard let self = self else { return }
                    switch index {
                    case 0:
                        self.pushVC(with: InventoryViewController.self, storyboardName: .account)
                    case 1 :
                        self.pushVC(with: ShowsViewController.self, storyboardName: .account)
                    case 2 :
                        self.pushVC(with: MyOrderViewController.self, storyboardName: .account)
                    case 4 :
                        self.pushVC(with: OfferViewController.self, storyboardName: .account)
                    case 5 :
                        self.pushVC(with: TipsViewController.self, storyboardName: .account)
                    default:
                        break
                    }
                }
                cell.isForDetails = false
                cell.isForPayment = false
                cell.segmentType = .sellerHub
                cell.imageName = self.imageName
                cell.titleName = self.tabName
                cell.configure(with: self.tabName)
                return cell
            case .detailsAcc:
                let cell = tableViewOlt.dequeueCell(with: MenuCell.self)
                cell.nextBtnOlt.tag = indexPath.row
                cell.didTapNext = { index in
                    self.didTap(index:index)
                }
                cell.labelOlt.text = moreSection[indexPath.row]
                return cell
            case .vacation:
                let cell = tableViewOlt.dequeueCell(with: SwitchEditorAndPhotographerCell.self)
                
                cell.titleOlt.text = "Vacation Mode"
                return cell
            
           
           
            }
//        case .account :
//            return UITableViewCell()
//            
//        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = AccountSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for LoginTableRow")
        }
        switch rowType {
        case .profile:
            return UITableView.automaticDimension
        case .segment:
            return Const.Height.segment
        case .profileDetails:
            return 110
        case .tab:
            return UITableView.automaticDimension
        case .vacation:
            return UITableView.automaticDimension
        case .creditAcc:
            return 110
        case .paymentAcc:
            return UITableView.automaticDimension
        case .detailsAcc:
            return UITableView.automaticDimension
        }
    }
}
