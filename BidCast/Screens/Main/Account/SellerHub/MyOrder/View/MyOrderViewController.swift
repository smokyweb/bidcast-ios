//
//  MyOrderViewController.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//

import UIKit
import SVProgressHUD

enum MyOrderSection: Int, CaseIterable {
    case orderDetails
    case orderListing
    
    func numberOfRows(data: [MyOrderSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class MyOrderViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet var headerView: HeaderWithAppName!
    @IBOutlet weak var tblView: UITableView!
    
    var sectionData: [MyOrderSection: Int] = [
        .orderDetails : 1,
        .orderListing: 10
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
        orderName.append(OrderDetail(orderName: "New Order", orderPrice: "24"))
        orderName.append(OrderDetail(orderName: "Processing", orderPrice: "156"))
        orderName.append(OrderDetail(orderName: "Completed", orderPrice: "892"))
        tblView.configTblView(bgColor : .pearl)
    }
    
    //MARK: - configureHeaderView.
    func configureHeaderView(){
        self.headerView.headerViewSetup(
            rightButtonHidden: false,
            leftButtonHidden: false,
            headerName: AppString.VCName.myOrders,
            setAppBtnImage: UIImage(named: "ic_back"),
            appButtonAction: didTabBack
        )
    }

    //MARK: - didTabBack.
    @objc private func didTabBack() {
        self.goToBack()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension MyOrderViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return MyOrderSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = MyOrderSection(rawValue: section) else { return 0 }
        print("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = MyOrderSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for MyOrderSection")
        }
        switch rowType {
        case .orderDetails:
            let cell = tblView.dequeueCell(with: MyOrderCollectionCell.self)
            cell.orderName = self.orderName
            cell.collectionViewOlt.backgroundColor = AppColor.white
            cell.collectionViewOlt.reloadData()
            cell.selectionStyle = .none
            return cell
        case .orderListing:
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
        guard let rowType = MyOrderSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for MyOrderSection")
        }
        switch rowType {
        case .orderDetails:
            return 100
        case .orderListing:
            return Const.Height.AutomaticDimension
        }
    }
}
