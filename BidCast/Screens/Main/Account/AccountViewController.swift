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
    case profileDetails
    case tab
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
        .profileDetails : 1,
        .tab : 1,
        .vacation : 1
    ]
    var imageName = ["inventory","mic","orders","wallet","tag","tag","shipping","people","seller","shop","analysis","analysis"]
    var tabName = ["Inventory","Shows","My Orders","Wallet","Offers","Tips","Shipping","Affiliate Program","Seller Trainig","Premier Shop","Seller status","Seller Analytics"]
    var sellerItems = ["284","$5.2K","4.8"]
    var sellerItemsNAme = ["Items","Revenue","Rating"]
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
                       ]
        tableViewOlt.registerCells(for: cellIds)
        
    }
    
}
extension AccountViewController : UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return AccountSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = AccountSection(rawValue: section) else { return 0 }
        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch segmentType{
        case .sellerHub:
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
                cell.isNavFrom = "MyAccountVC"
                cell.setupforsegmentControl()
                cell.contentView.backgroundColor = .clear
                return cell
            case .profileDetails:
                let cell = tableViewOlt.dequeueCell(with: CollectionViewCell.self)
                cell.isForDetails = true
                cell.sellerItemsNAme = self.sellerItemsNAme
                cell.seller = self.sellerItems
                return cell
            case .tab:
                let cell = tableViewOlt.dequeueCell(with: CollectionViewCell.self)
                cell.imageName = self.imageName
                cell.titleName = self.tabName
                cell.configure(with: self.tabName)
                return cell
            case .vacation:
                let cell = tableViewOlt.dequeueCell(with: SwitchEditorAndPhotographerCell.self)
                
                cell.titleOlt.text = "Vacation Mode"
                return cell
            }
        case .account :
            return UITableViewCell()
            
        }
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
            return 140
        case .tab:
            return UITableView.automaticDimension
        case .vacation:
            return UITableView.automaticDimension
        }
    }
}
