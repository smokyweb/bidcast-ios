//
//  InventoryViewController.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//

import UIKit
import SVProgressHUD

enum InventorySections: Int, CaseIterable {
    case segment
    case searchBar
    case details
    
    func numberOfRows(data: [InventorySections: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class InventoryViewController: UIViewController {
    
    //MARK: IBOutlets

    @IBOutlet var headerView: HeaderWithAppName!
    @IBOutlet weak var tblView: UITableView!
    
    //MARK: Properties
    var isInactiveSelected = false
    var isDraftSelected = false
    
    var sectionData: [InventorySections: Int] = [
        .segment : 1,
        .searchBar: 1,
        .details: 10
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
                        SearchTextfieldCell.identifier,
                        NoDataTableViewCell.identifier,SegmentCell.identifier,
                        LocationNameCell.identifier
                        ]
        tblView.registerCells(for: cellIds)
        tblView.configTblView()
    }
    
    //MARK: - configureHeaderView.
    func configureHeaderView(){
        self.headerView.headerViewSetup(rightButtonHidden: false,leftButtonHidden: false,headerName: AppString.VCName.Inventory)
    }

    
    //MARK: reloadDataForSelectedSegment.
    private func reloadDataForSelectedSegment() {
        if isDraftSelected {
            sectionData = [
                .searchBar: 1,
                .details: 3
            ]
        } else if isInactiveSelected {
            sectionData = [
                .searchBar: 1,
                .details: 2
            ]
        }else {
           sectionData = [
               .searchBar: 1,
               .details: 10
           ]
       }
        tblView.reloadData()
    }

    //MARK: didTabBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension InventoryViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return InventorySections.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = InventorySections(rawValue: section) else { return 0 }
        print("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = InventorySections.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for InventorySections")
        }
      
        switch rowType {
        case .segment:
            let cell = tblView.dequeueCell(with: SegmentCell.self)
            cell.isNavFrom = "InventoryVC"
            cell.setupforsegmentControl()
            cell.onSegmentChanged = { [weak self] selectedIndex in
                self?.isDraftSelected = (selectedIndex == 1)
                self?.isInactiveSelected = (selectedIndex == 2)
                self?.reloadDataForSelectedSegment()
            }
            return cell
            
        case .searchBar:
            let cell = tblView.dequeueCell(with: SearchTextfieldCell.self)
            cell.contentView.backgroundColor = .white
            cell.filterHistoryBtnTapped = {[weak self] sender in
                guard let self  = self else { return }
            }
            cell.selectionStyle = .none
            return cell
            
        case .details:
            let cell = tblView.dequeueCell(with: LocationNameCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.selectionStyle = .none
            return cell
    
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = InventorySections.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for InventorySections")
        }
      
        switch rowType {
        case .segment:
            return Const.Height.segment
        case .searchBar:
            return Const.Height.search
        case .details:
            return 104
        }
    }
}
