//
//  WalletViewController.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//

import UIKit
import SVProgressHUD

enum WalletSections: Int, CaseIterable {
    case segment
    case availableBalance
    case availablePayOut
    case earlyPayOut
    case payOutHeader
    case payOutList
    case allTransactionColl
    case transactionList
    
    func numberOfRows(data: [WalletSections: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

enum Wallet{
    case Wallet
    case Transactions
}

struct TransCategory{
    var name : String?
}

class WalletViewController: UIViewController {

    
    //MARK: IBOutlets
    
    @IBOutlet var headerView: HeaderWithAppName!
    @IBOutlet weak var tblView: UITableView!
    
    //MARK: Properties
    var segmentType : Wallet = .Wallet
    var orderName : [OrderDetail] = []
    var transCategory : [TransCategory] = []
    
    var sectionData: [WalletSections: Int] = [
        .segment : 1,
        .availableBalance : 1,
        .availablePayOut : 1,
        .earlyPayOut : 1,
        .payOutHeader : 1,
        .payOutList : 4,
        .allTransactionColl : 1,
        .transactionList : 7
    ]
    
    //MARK: ViewLife Cycle Method.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadInit()
    }
    
    //MARK: ViewLife Cycle Method.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
       
    }
    
    //MARK: - Configure view Method.
    private func loadInit(){
        self.configureTableView()
        self.configureHeaderView()
        self.reloadDataForSelectedSegment()
    }
    
    
    //MARK: - configureTableView.
    private func configureTableView(){
        self.tblView.dataSource = self
        self.tblView.delegate = self
        
        let cellIds =  [
            TotalEarningTblCell.identifier,
            NoDataTableViewCell.identifier,SegmentCell.identifier,
            MyOrderCollectionCell.identifier,LabelCell.identifier,LocationNameCell.identifier,TipsCell.identifier,CategoryTableViewCell.identifier
        ]
        tblView.registerCells(for: cellIds)
        tblView.configTblView()
        tblView.configTblView(bgColor : .pearl)
        transCategory.append(TransCategory(name: "All"))
        transCategory.append(TransCategory(name: "Pending"))
        transCategory.append(TransCategory(name: "Processing"))
        transCategory.append(TransCategory(name: "Compeleted"))
        orderName.append(OrderDetail(orderName: "24", orderPrice: "Available for Payout"))
        orderName.append(OrderDetail(orderName: "156", orderPrice: "Processing"))
       
        
    }
    
    //MARK: - configureHeaderView.
    func configureHeaderView(){
        self.headerView.headerViewSetup(rightButtonHidden: false,leftButtonHidden: true,headerName: AppString.VCName.wallet,appButtonAction : didTabBack)
    }
    
    //MARK: didTabBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
    
    
    //MARK: reloadDataForSelectedSegment.
    private func reloadDataForSelectedSegment() {
        switch segmentType {
        case .Wallet:
            sectionData = [
                .segment : 1,
                .availableBalance : 1,
                .availablePayOut : 1,
                .earlyPayOut : 1,
                .payOutHeader : 1,
                .payOutList : 4,
                .allTransactionColl : 0,
                .transactionList : 0
            ]
        case .Transactions:
            sectionData = [
                .segment : 1,
                .availableBalance : 0,
                .availablePayOut : 0,
                .earlyPayOut : 0,
                .payOutHeader : 0,
                .payOutList : 0,
                .allTransactionColl : 1,
                .transactionList : 7
            ]
        }
        tblView.reloadData()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension WalletViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return WalletSections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = WalletSections(rawValue: section) else { return 0 }
        print("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = WalletSections.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for WalletSections")
        }
        switch rowType {
        case .segment:
            let cell = tblView.dequeueCell(with: SegmentCell.self)
            cell.configure(isNavFor: "WalletVC")
            cell.onSegmentChanged = { selectedIndex in
                self.segmentType = selectedIndex == 0 ? .Wallet : .Transactions
                self.reloadDataForSelectedSegment()
            }
            cell.contentView.backgroundColor = .clear
            cell.selectionStyle = .none
            return cell
        case .availableBalance:
            let cell = tblView.dequeueCell(with: TotalEarningTblCell.self)
            cell.contentView.backgroundColor = .white
            cell.titleOltFirst.text = AppString.Title.availableBalance
            cell.titleOltSec.text = "$5,280.50"
            return cell
        case .availablePayOut:
            let cell = tblView.dequeueCell(with: MyOrderCollectionCell.self)
            cell.orderName = self.orderName
            cell.itemsPerRow = 2
            cell.collectionViewOlt.backgroundColor = AppColor.pearl
            cell.collectionViewOlt.reloadData()
            cell.selectionStyle = .none
            return cell
        case .earlyPayOut:
            let cell = tblView.dequeueCell(with: LocationNameCell.self)
            cell.titleOlt.text = "Early PayOut"
            cell.descriptionOlt.text = "You are eligible for early payout"
            cell.rightButtonOlt.isHidden = false
            cell.rightButtonOlt.setImage(UIImage(systemName: "chevron.right")?.withTintColor(.black, renderingMode: .alwaysTemplate), for: .normal)
            cell.outerViewOlt.backgroundColor = .pearl
            return cell
        case .payOutHeader:
            let cell = tblView.dequeueCell(with: LabelCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.titleOlt.setupLabel(title: AppString.Title.payOutHistory,txtColor: AppColor.Label.Black ?? .black, fontSize : AppFont.placeHolder)
            return cell
        case .payOutList:
            let cell = tblView.dequeueCell(with: TipsCell.self)
            cell.hideImage()
            cell.isNavFrom = "Wallet"
            cell.titleOlt.text = "Testing"
            cell.descriptionOlt.text = "Jan 15, 2025 • 2:30 PM"
            cell.priceLbl.text = "$90.0"
            cell.seprator.isHidden = false
            cell.contentView.backgroundColor = .white
            return cell
        case .allTransactionColl:
            let cell = tblView.dequeueCell(with: CategoryTableViewCell.self)
            cell.transCategoryArr = transCategory
            cell.contentView.backgroundColor = AppColor.white
            cell.categoryCollectionView.backgroundColor = AppColor.white
            cell.onItemSelected = { [weak self] index in
                guard let self = self else { return }
                cell.selectedIndex = index
                cell.categoryCollectionView.reloadData()
//                switch index {
//                case 0:
//    
//                default:
//                    break
//                }
                self.tblView.reloadData()
            }
            cell.categoryCollectionView.reloadData()
            cell.selectionStyle = .none
            return cell

        case .transactionList:
            let cell = tblView.dequeueCell(with: TipsCell.self)
            cell.showImage()
            cell.isNavFrom = "Wallet"
            cell.titleOlt.text = "Testing"
            cell.descriptionOlt.text = "Jan 15, 2025 • 2:30 PM"
            cell.priceLbl.text = "$90.0"
            cell.priceLbl.textColor = .black
            cell.seprator.isHidden = false
            cell.contentView.backgroundColor = .white
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = WalletSections.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for WalletSections")
        }
        switch rowType {
        case .segment:
            return Const.Height.segment
        case .availableBalance:
            return 120
        case .availablePayOut:
            return 100
        case .earlyPayOut:
            return Const.Height.AutomaticDimension
        case .payOutHeader:
            return Const.Height.AutomaticDimension
        case .payOutList:
            return Const.Height.AutomaticDimension
        case .allTransactionColl:
            return 65
        case .transactionList:
            return Const.Height.AutomaticDimension
        }
    }
}
