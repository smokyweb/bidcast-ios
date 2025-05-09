//
//  ShippingViewController.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//

import UIKit
import SVProgressHUD

enum ShippingSection: Int, CaseIterable {
    case shippingDetails
    case shippingListing
    
    func numberOfRows(data: [ShippingSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}


class ShippingViewController: UIViewController {
    
   
    //MARK: IBOutlets
    @IBOutlet var headerView: HeaderWithAppName!
    @IBOutlet weak var tblView: UITableView!
    
    var sectionData: [ShippingSection: Int] = [
        .shippingDetails : 1,
        .shippingListing: 6
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
            NoDataTableViewCell.identifier,MyOrderCollectionCell.identifier,LocationNameCell.identifier
        ]
        tblView.registerCells(for: cellIds)
        tblView.configTblView()
        orderName.append(OrderDetail(orderName: "Pending", orderPrice: "24"))
        orderName.append(OrderDetail(orderName: "Delivered", orderPrice: "156"))
        orderName.append(OrderDetail(orderName: "Return", orderPrice: "892"))
        tblView.configTblView(bgColor : .pearl)
    }
    
    //MARK: - configureHeaderView.
    func configureHeaderView(){
        self.headerView.headerViewSetup(rightButtonHidden: false,leftButtonHidden: true,headerName: AppString.VCName.shipping,setRightImage: UIImage(named: "ic_back"),leftButtonAction: didTabBack)
    }
    
    //MARK: didTabBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
    
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension ShippingViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return ShippingSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = ShippingSection(rawValue: section) else { return 0 }
        print("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = ShippingSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for MyOrderSection")
        }
        switch rowType {
        case .shippingDetails:
            let cell = tblView.dequeueCell(with: MyOrderCollectionCell.self)
            cell.orderName = self.orderName
            cell.collectionViewOlt.backgroundColor = AppColor.white
            cell.collectionViewOlt.reloadData()
            cell.selectionStyle = .none
            return cell
        case .shippingListing:
            let cell = tblView.dequeueCell(with: LocationNameCell.self)
            cell.imageOlt.image = UIImage(named: "IMG_1340")
            cell.imageOlt.makeCircular()
            cell.titleOlt.text = "Free Pickup"
            cell.descriptionOlt.text = "Local Pickup setting"
            cell.rightButtonOlt.isHidden = false
            cell.rightButtonOlt.setImage(UIImage(systemName: "chevron.right")?.withTintColor(.black, renderingMode: .alwaysTemplate), for: .normal)
            cell.contentView.backgroundColor = .pearl
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = ShippingSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for MyOrderSection")
        }
        switch rowType {
        case .shippingDetails:
            return 100
        case .shippingListing:
            return Const.Height.AutomaticDimension
        }
    }
}
