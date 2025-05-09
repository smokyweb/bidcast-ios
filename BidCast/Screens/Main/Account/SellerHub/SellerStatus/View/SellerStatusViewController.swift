//
//  SellerStatusViewController.swift
//  BidCast
//
//  Created by JAM-E-329 06/05/25.
//

import UIKit
import SVProgressHUD

enum SellerSection: Int, CaseIterable {
    case sellerListing
    
    func numberOfRows(data: [SellerSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}


class SellerStatusViewController: UIViewController {
    

    //MARK: IBOutlets
    @IBOutlet var headerView: HeaderWithAppName!
    @IBOutlet weak var tblView: UITableView!
    
    var sectionData: [SellerSection: Int] = [
        .sellerListing: 6
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
            DownloadwithTitleCell.identifier]
        tblView.registerCells(for: cellIds)
        tblView.configTblView()
        tblView.configTblView(bgColor : .pearl)
    }
    
    //MARK: - configureHeaderView.
    func configureHeaderView(){
        self.headerView.headerViewSetup(rightButtonHidden: false,leftButtonHidden: true,headerName: AppString.VCName.sellerStatus)
    }
    
    //MARK: didTabBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
    
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension SellerStatusViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return SellerSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SellerSection(rawValue: section) else { return 0 }
        print("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = SellerSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for MyOrderSection")
        }
        switch rowType {
        case .sellerListing:
            let cell = tblView.dequeueCell(with: DownloadwithTitleCell.self)
            cell.downloadImgOlt.isHidden = true
            cell.imgOlt.image = UIImage(named: "ic_notification")
            cell.innerViewOlt.backgroundColor = .white
            cell.statusBtn.isHidden = false
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = SellerSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for MyOrderSection")
        }
        switch rowType {
        case .sellerListing:
            return Const.Height.AutomaticDimension
        }
    }
}
