//
//  ActivityViewController.swift
//  BidCast
//
//  Created by Fazal-JAM-E-329 on 07/05/25.
//

import UIKit
import SVProgressHUD

enum ActivitySections: Int, CaseIterable {
    case activityCollection
    case messageDetails
    case bidDetails
    case offerDetails
    case purchasedDetails
    case savedItems
    
    func numberOfRows(data: [ActivitySections: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class ActivityViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet var headerView: HeaderWithAppName!
    @IBOutlet weak var tblView: UITableView!
    
    //MARK: sectionData
    var sectionData: [ActivitySections: Int] = [
        .activityCollection : 1,
        .messageDetails : 1,
        .bidDetails : 2,
        .offerDetails : 4,
        .purchasedDetails : 2
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
    }
    
    
    //MARK: - configureTableView.
    private func configureTableView(){
        self.tblView.dataSource = self
        self.tblView.delegate = self
        
        let cellIds =  [
            CategoryTableViewCell.identifier,
            NoDataTableViewCell.identifier,AcitivityCell.identifier
        ]
        tblView.registerCells(for: cellIds)
        tblView.configTblView()
        tblView.configTblView(bgColor : .pearl)
    }
    
    //MARK: - configureHeaderView.
    func configureHeaderView(){
        self.headerView.headerViewSetup(rightButtonHidden: false,leftButtonHidden: true,headerName: AppString.VCName.activity,setAppBtnImage: UIImage(named: "ic_back"),appButtonAction : didTabBack)
    }
    
    //MARK: didTabBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension ActivityViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return InventorySections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = ActivitySections(rawValue: section) else { return 0 }
        print("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = ActivitySections.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for ActivitySections")
        }
        
        switch rowType {
        case .activityCollection:
            let cell = tblView.dequeueCell(with: CategoryTableViewCell.self)
            cell.contentView.backgroundColor = AppColor.pearl
            cell.categoryCollectionView.reloadData()
            cell.selectionStyle = .none
            return cell
        case .messageDetails:
            let cell = tblView.dequeueCell(with: AcitivityCell.self)
            cell.contentView.backgroundColor = AppColor.pearl
            cell.userImageOlt.image = UIImage(named: "defaultUser")
            cell.userNameOlt.text = "William Jhonsn"
            cell.userbidDetail.text = "Testing Message"
            cell.userbidPrice.text = "2hr Ago"
            cell.bidderStack.isHidden = true
            cell.userStack.isHidden = false
            cell.acceptStack.isHidden = true
            cell.selectionStyle = .none
            return cell
        case .bidDetails:
            let cell = tblView.dequeueCell(with: AcitivityCell.self)
            cell.contentView.backgroundColor = AppColor.pearl
            cell.userImageOlt.image = UIImage(named: "defaultUser")
            cell.userNameOlt.text = "William"
            cell.userbidDetail.text = "Place a bit 2hr ago"
            cell.userbidPrice.text = "$45. 0"
            cell.bidderImageOlt.image = UIImage(named: "defaultUser")
            cell.bidderNameDetail.text = "Jhonson"
            cell.bidderPriceDetail.text = "Current Id #235"
            cell.bidderStack.isHidden = false
            cell.userStack.isHidden = false
            cell.acceptStack.isHidden = true
            cell.selectionStyle = .none
            return cell
        case .offerDetails:
            let cell = tblView.dequeueCell(with: AcitivityCell.self)
            cell.contentView.backgroundColor = AppColor.pearl
            cell.userImageOlt.image = UIImage(named: "defaultUser")
            cell.userNameOlt.text = "William"
            cell.userbidDetail.text = "Place a bit 2hr ago"
            cell.userbidPrice.text = "$45. 0"
            cell.bidderImageOlt.image = UIImage(named: "defaultUser")
            cell.bidderNameDetail.text = "Jhonson"
            cell.bidderPriceDetail.text = "Current Id #235"
            cell.bidderStack.isHidden = false
            cell.userStack.isHidden = false
            cell.acceptStack.isHidden = false
            cell.didTapAccept = { [weak self] sender in
                
            }
            cell.didTapReject = { [weak self] sender in
                
            }
            cell.selectionStyle = .none
            return cell
        case .purchasedDetails:
            let cell = tblView.dequeueCell(with: AcitivityCell.self)
            cell.contentView.backgroundColor = AppColor.pearl
            cell.bidderImageOlt.image = UIImage(named: "defaultUser")
            cell.bidderNameDetail.text = "Jhonson"
            cell.bidderPriceDetail.text = "Current Id #235"
            cell.bidderPriceDetail.text = "$45. 0"
            cell.bidderStack.isHidden = true
            cell.userStack.isHidden = false
            cell.acceptStack.isHidden = true
            cell.selectionStyle = .none
            return cell
        case .savedItems:
            let cell = tblView.dequeueCell(with: AcitivityCell.self)
            cell.contentView.backgroundColor = AppColor.pearl
            cell.bidderImageOlt.image = UIImage(named: "defaultUser")
            cell.bidderNameDetail.text = "Jhonson"
            cell.bidderPriceDetail.text = "Current Id #235"
            cell.bidderPriceDetail.text = "$45. 0"
            cell.bidderStack.isHidden = true
            cell.userStack.isHidden = false
            cell.acceptStack.isHidden = true
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = ActivitySections.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for ActivitySections")
        }
        
        switch rowType {
        case .activityCollection:
            return Const.Height.segment
        case .messageDetails:
            return Const.Height.AutomaticDimension
        case .bidDetails:
            return Const.Height.AutomaticDimension
        case .offerDetails:
            return Const.Height.AutomaticDimension
        case .purchasedDetails:
            return Const.Height.AutomaticDimension
        case .savedItems:
            return Const.Height.AutomaticDimension
        }
    }
}
