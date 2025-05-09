//
//  TipsViewController.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//

import UIKit
import SVProgressHUD

enum TipsSection: Int, CaseIterable {
    case tipsDetails
    case tipsListing
    
    func numberOfRows(data: [TipsSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class TipsViewController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet var headerView: HeaderWithAppName!
    @IBOutlet weak var tblView: UITableView!
    
    var sectionData: [TipsSection: Int] = [
        .tipsDetails : 1,
        .tipsListing: 6
    ]
    var orderName : [OrderDetail] = []
    
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
    }
    
    
    //MARK: - configureTableView.
    private func configureTableView(){
        self.tblView.dataSource = self
        self.tblView.delegate = self
        let cellIds =  [
            NoDataTableViewCell.identifier,MyOrderCell.identifier,
            AcitivityCell.identifier,MyOrderCollectionCell.identifier,TipsCell.identifier
        ]
        tblView.registerCells(for: cellIds)
        tblView.configTblView()
        orderName.append(OrderDetail(orderName: "Pending", orderPrice: "24"))
        orderName.append(OrderDetail(orderName: "Accepted", orderPrice: "156"))
        orderName.append(OrderDetail(orderName: "Decline", orderPrice: "892"))
        tblView.configTblView(bgColor : .pearl)
    }
    
    //MARK: - configureHeaderView.
    func configureHeaderView(){
        self.headerView.headerViewSetup(rightButtonHidden: false,leftButtonHidden: true,headerName: AppString.VCName.tips)
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension TipsViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return TipsSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = TipsSection(rawValue: section) else { return 0 }
        print("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = TipsSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for MyOrderSection")
        }
        switch rowType {
        case .tipsDetails:
            let cell = tblView.dequeueCell(with: MyOrderCollectionCell.self)
            cell.orderName = self.orderName
            cell.collectionViewOlt.backgroundColor = AppColor.white
            cell.collectionViewOlt.reloadData()
            cell.selectionStyle = .none
            return cell
        case .tipsListing:
            let cell = tblView.dequeueCell(with: TipsCell.self)
            cell.imageOlt.image = UIImage(named: "user1")
            cell.titleOlt.text = "Testing"
            cell.descriptionOlt.text = "Jan 15, 2025 • 2:30 PM"
            cell.priceLbl.text = "$90.0"
            cell.contentView.backgroundColor = .clear
            cell.outerViewOlt.backgroundColor = .bg
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = TipsSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for MyOrderSection")
        }
        switch rowType {
        case .tipsDetails:
            return 100
        case .tipsListing:
            return Const.Height.AutomaticDimension
        }
    }
}
