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
        .bidDetails : 1,
        .offerDetails : 1,
        .purchasedDetails : 1
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
        self.reloadDataForFirstTimeSegment()
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
        self.headerView.headerViewSetup(rightButtonHidden: false,leftButtonHidden: true,headerName: AppString.VCName.activity,setRightImage: UIImage(named: "ic_notification"))
        self.headerView.containerView.backgroundColor = .white
    }
    
    //MARK: didTabBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
    
    private func reloadDataForFirstTimeSegment() {
        sectionData[.messageDetails] = 1
        sectionData[.bidDetails] = 0
        sectionData[.offerDetails] = 0
        sectionData[.purchasedDetails] = 0
        sectionData[.savedItems] = 0
        self.tblView.reloadData()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension ActivityViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return ActivitySections.allCases.count
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
            cell.contentView.backgroundColor = AppColor.white
            cell.categoryCollectionView.backgroundColor = AppColor.white
            cell.onItemSelected = { [weak self] index in
                guard let self = self else { return }
                switch index {
                case 0:
                    self.sectionData[.messageDetails] = 1
                    self.sectionData[.bidDetails] = 0
                    self.sectionData[.offerDetails] = 0
                    self.sectionData[.purchasedDetails] = 0
                    self.sectionData[.savedItems] = 0
                case 1:
                    self.sectionData[.messageDetails] = 0
                    self.sectionData[.bidDetails] = 1
                    self.sectionData[.offerDetails] = 0
                    self.sectionData[.purchasedDetails] = 0
                    self.sectionData[.savedItems] = 0
                case 2:
                    self.sectionData[.messageDetails] = 0
                    self.sectionData[.bidDetails] = 0
                    self.sectionData[.offerDetails] = 2
                    self.sectionData[.purchasedDetails] = 0
                    self.sectionData[.savedItems] = 0
                case 3:
                    self.sectionData[.messageDetails] = 0
                    self.sectionData[.bidDetails] = 0
                    self.sectionData[.offerDetails] = 0
                    self.sectionData[.purchasedDetails] = 3
                    self.sectionData[.savedItems] = 0
                case 4 :
                    self.sectionData[.messageDetails] = 0
                    self.sectionData[.bidDetails] = 0
                    self.sectionData[.offerDetails] = 0
                    self.sectionData[.purchasedDetails] = 0
                    self.sectionData[.savedItems] = 2
                default:
                    break
                }
                self.tblView.reloadData()
            }
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
            cell.userbidPrice.textColor = AppColor.mediumGray
            cell.hideShowUserView(stackHidden: false)
            cell.hideShowBidderView(stackHidden: true)
            cell.hideShowAcceptView(stackHidden: true)
            cell.selectionStyle = .none
            return cell
        case .bidDetails:
            let cell = tblView.dequeueCell(with: AcitivityCell.self)
            cell.contentView.backgroundColor = AppColor.pearl
            cell.userImageOlt.image = UIImage(named: "defaultUser")
            cell.userNameOlt.text = "William"
            cell.userbidDetail.text = "Place a bit 2hr ago"
            cell.userbidPrice.text = "$45. 0"
            cell.userbidPrice.textColor = AppColor.successGreen
            cell.bidderImageOlt.image = UIImage(named: "ic_bidder")
            cell.bidderNameDetail.text = "Current Id #235"
            cell.bidderBidDetails.text = "Current bid: 2:45"
            cell.bidderPriceDetail.isHidden = true
            cell.bidderDate.isHidden = true
            cell.hideShowUserView(stackHidden: false)
            cell.hideShowBidderView(stackHidden: false)
            cell.hideShowAcceptView(stackHidden: true)
            cell.selectionStyle = .none
            return cell
        case .offerDetails:
            let cell = tblView.dequeueCell(with: AcitivityCell.self)
            cell.contentView.backgroundColor = AppColor.pearl
            cell.userImageOlt.image = UIImage(named: "defaultUser")
            cell.userNameOlt.text = "William"
            cell.userbidDetail.text = "Place a bit 2hr ago"
            cell.userbidPrice.text = "$45. 0"
            cell.userbidPrice.textColor = AppColor.successGreen
            cell.bidderImageOlt.image = UIImage(named: "ic_bidder")
            cell.bidderNameDetail.text = "Current Id #235"
            cell.bidderBidDetails.text = "Current bid: 2:45"
            cell.bidderPriceDetail.isHidden = true
            cell.bidderDate.isHidden = true
            cell.hideShowUserView(stackHidden: false)
            cell.hideShowBidderView(stackHidden: false)
            cell.hideShowAcceptView(stackHidden: false)
            cell.didTapAccept = { [weak self] sender in
                
            }
            cell.didTapReject = { [weak self] sender in
                
            }
            cell.selectionStyle = .none
            return cell
        case .purchasedDetails:
            let cell = tblView.dequeueCell(with: AcitivityCell.self)
            cell.contentView.backgroundColor = AppColor.pearl
            cell.bidderImageOlt.image = UIImage(named: "ic_bidder")
            cell.bidderNameDetail.text = "Current Id #235"
            cell.bidderBidDetails.text = "Current bid: 2:45"
            cell.bidderPriceDetail.text = "$45. 0"
            cell.bidderDate.text = "Date: \("04/12/25")"
            cell.bidderPriceDetail.isHidden = false
            cell.bidderPriceDetail.textColor = AppColor.successGreen
            cell.hideShowUserView(stackHidden: true)
            cell.bidderDate.isHidden = false
            cell.hideShowBidderView(stackHidden: false)
            cell.hideShowAcceptView(stackHidden: true)
            cell.selectionStyle = .none
            return cell
        case .savedItems:
            let cell = tblView.dequeueCell(with: AcitivityCell.self)
            cell.contentView.backgroundColor = AppColor.pearl
            cell.bidderImageOlt.image = UIImage(named: "ic_bidder")
            cell.bidderNameDetail.text = "Current Id #235"
            cell.bidderBidDetails.text = "Current bid: 2:45"
            cell.bidderPriceDetail.text = "$45. 0"
            cell.bidderDate.text = "Date: \("04/12/25")"
            cell.bidderPriceDetail.isHidden = false
            cell.bidderDate.isHidden = false
            cell.bidderPriceDetail.textColor = AppColor.successGreen
            cell.hideShowUserView(stackHidden: true)
            cell.hideShowBidderView(stackHidden: false)
            cell.hideShowAcceptView(stackHidden: true)
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
            return 50
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
