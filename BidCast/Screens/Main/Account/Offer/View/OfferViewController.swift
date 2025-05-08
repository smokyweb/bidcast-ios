//
//  OfferViewController.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//

import UIKit
import SVProgressHUD

enum OfferSection: Int, CaseIterable {
    case offerDetails
    case offerListing
    
    func numberOfRows(data: [OfferSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}



class OfferViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet var headerView: HeaderWithAppName!
    @IBOutlet weak var tblView: UITableView!
    
    var sectionData: [OfferSection: Int] = [
        .offerDetails : 1,
        .offerListing: 3
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
            ShowInventoryCell.identifier,MyOrderCollectionCell.identifier
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
        self.headerView.headerViewSetup(rightButtonHidden: false,leftButtonHidden: true,headerName: AppString.VCName.offer)
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension OfferViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return OfferSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = OfferSection(rawValue: section) else { return 0 }
        print("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = OfferSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for MyOrderSection")
        }
        switch rowType {
        case .offerDetails:
            let cell = tblView.dequeueCell(with: MyOrderCollectionCell.self)
            cell.orderName = self.orderName
            cell.collectionViewOlt.backgroundColor = AppColor.white
            cell.collectionViewOlt.reloadData()
            cell.selectionStyle = .none
            return cell
        case .offerListing:
            let cell = tblView.dequeueCell(with: MyOrderCell.self)
            cell.contentView.backgroundColor = AppColor.white
            cell.userNameOlt.text = "#ORD-2025-0123"
            cell.userbidDetail.text = "Jan 23, 2025, 14:30"
            cell.bidderImageOlt.image = UIImage(named: "ic_bidder")
            cell.bidderNameDetail.text = "John Anderson"
            cell.bidderBidDetails.text = "Los Angeles, CA"
            cell.orderAmountTitle.text = "Order Amount"
            cell.orderAmountTotal.text = "$189.99"
            if indexPath.row % 2 == 0{
                cell.userbidPrice.text = "Processing"
                cell.orderView.backgroundColor = .lightBlue
                cell.userbidPrice.textColor = .darkBlue
            }else{
                cell.userbidPrice.text = "Delivered"
                cell.userbidPrice.textColor = .darkGreen
                cell.orderView.backgroundColor = .lightGreen
            }
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = OfferSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for MyOrderSection")
        }
        switch rowType {
        case .offerDetails:
            return 100
        case .offerListing:
            return Const.Height.AutomaticDimension
        }
    }
}
