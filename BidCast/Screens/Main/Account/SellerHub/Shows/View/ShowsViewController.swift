//
//  ShowsViewController.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//

import UIKit
import SVProgressHUD

enum ShowsTransactionSection: Int, CaseIterable {
    case segment
    case showDetails
    case pastDetails
    
    func numberOfRows(data: [ShowsTransactionSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

enum segmentType : String {
    case shows
    case pastShows
}

class ShowsViewController: UIViewController {


    //MARK: IBOutlets

    @IBOutlet var headerView: HeaderWithAppName!
    @IBOutlet weak var tblView: UITableView!
    
    //MARK: Properties
    var isPastShow = false
    var segmentType : segmentType = .shows
    
    var sectionData: [ShowsTransactionSection: Int] = [
        .segment : 1,
        .showDetails : 2,
        .pastDetails: 10
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
                        NoDataTableViewCell.identifier,SegmentCell.identifier,
                        ShowInventoryCell.identifier
                        ]
        tblView.registerCells(for: cellIds)
        tblView.configTblView()
        tblView.configTblView(bgColor : .pearl)
    }
    
    //MARK: - configureHeaderView.
    func configureHeaderView(){
        self.headerView.headerViewSetup(rightButtonHidden: false,leftButtonHidden: false,headerName: AppString.VCName.shows)
    }
    
    //MARK: didTabBack.
    @objc private func didTabBack(){
        self.goToBack()
    }

    //MARK: reloadDataForSelectedSegment.
    private func reloadDataForSelectedSegment() {
        switch segmentType {
        case .shows:
            sectionData = [
             .showDetails : 3,
             .pastDetails: 0
            ]
        case .pastShows:
            sectionData = [
                .showDetails : 0,
                .pastDetails: 10
            ]
        }
        tblView.reloadData()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension ShowsViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return ShowsTransactionSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = ShowsTransactionSection(rawValue: section) else { return 0 }
        print("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = ShowsTransactionSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for ShowsTransactionSection")
        }
      
        switch rowType {
        case .segment:
            let cell = tblView.dequeueCell(with: SegmentCell.self)
            cell.configure(isNavFor: "ShowVC")
            cell.onSegmentChanged = { selectedIndex in
                self.segmentType = selectedIndex == 0 ? .shows : .pastShows
                self.reloadDataForSelectedSegment()
            }
            cell.selectionStyle = .none
            return cell
        case .showDetails:
            let cell = tblView.dequeueCell(with: ShowInventoryCell.self)
            cell.imageOlt.image = UIImage(named: "IMG_2678")
            cell.titleOlt.text = "MTG Cards Sale"
            cell.descriptionOlt.text = "Feb 15, 2025"
            cell.priceDeatilOlt.text = "8:00 PM EST"
            cell.stockOlt.text = "156 RSVPs"
            cell.selectionStyle = .none
            return cell
        case .pastDetails:
            let cell = tblView.dequeueCell(with: ShowInventoryCell.self)
            cell.imageOlt.image = UIImage(named: "IMG_2678")
            cell.titleOlt.text = "MTG Cards Sale"
            cell.descriptionOlt.text = "Feb 15, 2025"
            cell.priceDeatilOlt.text = "8:00 PM EST"
            cell.stockOlt.text = "156 RSVPs"
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = ShowsTransactionSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for ShowsTransactionSection")
        }
        switch rowType {
        case .segment:
            return Const.Height.segment
        case .showDetails:
            return Const.Height.AutomaticDimension
        case .pastDetails:
            return Const.Height.AutomaticDimension
        }
    }
}
