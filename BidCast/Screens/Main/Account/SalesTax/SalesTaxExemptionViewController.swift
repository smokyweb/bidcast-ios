//
//  SalesTaxExemptionViewController.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 09/05/25.
//

import UIKit
enum SalesSection : Int,CaseIterable{
    case profile
    case status
    case certificate
    
    func numberOfRows(data: [SalesSection: Int]) -> Int {
        return data[self] ?? 1
    }
}

class SalesTaxExemptionViewController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var btn2Olt: UIButton!
    @IBOutlet weak var btn1Olt: UIButton!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var headerView: HeaderView!
    
    //MARK: Properties
    var sectionData : [SalesSection : Int] = [
        .profile :1,
        .status :1,
        .certificate :1
    ]
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadInit()
        self.initViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setTabBarHidden(true)
        self.setNavigationBarHidden(true)
    }
    
    //MARK: - Configure view Method.
    private func loadInit(){
        self.configureTableView()
        self.configureHeaderView()
//        self.fetchApi()
    }
    
    //MARK: - configureTableView.
    private func configureTableView(){
        self.tblView.delegate = self
        self.tblView.dataSource = self
        let cellIds =  [
            LocationNameCell.identifier,
            TwoLabelTitleViewCell.identitfier,
            DownloadwithTitleCell.identifier
           
        ]
        
        tblView.registerCells(for: cellIds)
        self.tblView.separatorStyle = .none
//        tblView.configTblView(bgColor : .ultraLightGray)
        self.btn1Olt.makeCornerRounded(ofSize: 12)
        self.btn2Olt.makeCornerRounded(ofSize: 12)
        self.btn1Olt.backgroundColor = .secondary
        self.btn2Olt.backgroundColor = .white
        self.btn2Olt.addBorders(of: .secondary, width: 1.0)
        self.btn2Olt.setTitleColor(.secondary, for: .normal)
    }
    
    
    //MARK: configureView.
    private func configureHeaderView() {
        self.headerView.headerViewSetup(leftButtonHidden: false,
                                        headerName: "Sales Tax Exemption",
                                        leftButtonAction: didTabBack)
        self.headerView.bottomLbl.isHidden = true
        self.headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
      
    }
    
    //MARK: initViewModel.
    func initViewModel() {
//        self.viewModel.userDelegate = self
    }
    
    //MARK: fetch api .
    private func fetchApi(){
//        if Reachability.isConnectedToNetwork(){
//            SVProgressHUD.show()
//            self.viewModel.getAboutUsData()
//        }else{
//            DispatchQueue.main.async {
//                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
//            }
//        }
    }
    
    //MARK: - didtapBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension SalesTaxExemptionViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return SalesSection.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = SalesSection(rawValue: section) else { return 0 }
       
        return sectionType.numberOfRows(data: sectionData)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = SalesSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for AboutUsRows")
        }
        
        switch rowType {
      
        case .profile:
            let cell = tableView.dequeueCell(with: LocationNameCell.self)
            cell.contentView.backgroundColor = .pearl
            return cell
        case .status:
            let cell = tableView.dequeueCell(with: TwoLabelTitleViewCell.self)
            return cell
        case .certificate:
            let cell = tableView.dequeueCell(with: DownloadwithTitleCell.self)
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let rowType = SalesSection.allCases[safe: indexPath.section] else {
//            fatalError("Invalid index for AboutUsRows")
//        }
//        
//        switch rowType {
//     
//        }
//       
//    }
}
