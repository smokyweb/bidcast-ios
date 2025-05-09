//
//  MyAddressViewController.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 09/05/25.
//

import UIKit

enum AddressSection : Int,CaseIterable{
    case address
    func numberOfRows(data: [AddressSection: Int]) -> Int {
        return data[self] ?? 1
    }
}

class MyAddressViewController: UIViewController {

    @IBOutlet weak var tableViewOlt: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var headerView: HeaderView!
    
    var sectionData : [AddressSection : Int] = [
        .address : 2
        
    ]
    
    //MARK: ViewLife Cycle Method
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
        self.tableViewOlt.delegate = self
        self.tableViewOlt.dataSource = self
        let cellIds =  [
            LocationNameCell.identifier,
            SubmitCell.identifier,
            AppHeaderCell.identifier,
            AddressCell.identifier
         
        ]
        
        tableViewOlt.registerCells(for: cellIds)
        self.tableViewOlt.separatorStyle = .none
        tableViewOlt.configTblView(bgColor : .pearl)
    }
    
    
    //MARK: configureView.
    private func configureHeaderView() {
        self.headerView.headerViewSetup(rightButtonHidden: false,leftButtonHidden: false,
                                        headerName: "My Addresses",
                                        setRightImage: UIImage(systemName: "plus")?.withTintColor(.darkBlue, renderingMode: .alwaysOriginal),
                                        leftButtonAction: didTabBack)
        self.headerView.bottomLbl.isHidden = true
        self.headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
        self.submitBtn.setImage(UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
        self.submitBtn.setTitle("Add New Address", for: .normal)
        self.submitBtn.setTitleColor(.white, for: .normal)
        self.submitBtn.backgroundColor = .darkBlue
        self.submitBtn.addBorders(of: .darkBlue, width: 1.0)
        self.submitBtn.makeCornerRounded(ofSize: 8)
        
    }
    
    //MARK: initViewModel.
    func initViewModel() {
//        self.viewModel.userDelegate = self
    }
    
    //MARK: fetch api .
   
    //MARK: - didtapBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension MyAddressViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return AddressSection.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = AddressSection(rawValue: section) else { return 0 }
        
        return sectionType.numberOfRows(data: sectionData)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = AddressSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for AboutUsRows")
        }
        
        switch rowType {
        case .address:
            
            let cell = tableView.dequeueCell(with: AddressCell.self)
            
            cell.contentView.backgroundColor = .pearl
            cell.countryOlt.isHidden = false
            cell.phoneOlt.isHidden = false
            cell.centerConst.constant = -60
            cell.selectionStyle = .none
            return cell
        }
    }
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let rowType = AddressSection.allCases[safe: indexPath.section] else {
                fatalError("Invalid index for AboutUsRows")
            }
    
            switch rowType {
          
           
            case .address:
                return Const.Height.AutomaticDimension
           
            }
    
        }
    
}

