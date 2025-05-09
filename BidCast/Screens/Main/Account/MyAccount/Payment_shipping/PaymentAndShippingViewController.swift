//
//  ViewController.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 09/05/25.
//

import UIKit

enum PaymentSection : Int,CaseIterable{
    case header
    case card
    case addButton
    case addressHeader
    case address
    case addAddressButton
    
    func numberOfRows(data: [PaymentSection: Int]) -> Int {
        return data[self] ?? 1
    }
}
class PaymentAndShippingViewController: UIViewController {

    @IBOutlet weak var tableViewOlt: UITableView!
    @IBOutlet weak var headerView: HeaderView!
    
    var sectionData : [PaymentSection : Int] = [
        .header :1,
        .card :2,
        .addButton:1,
        .addressHeader:1,
        .address :2,
        .addAddressButton : 1
        
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
        self.headerView.headerViewSetup(leftButtonHidden: false,
                                        headerName: "Payment & Shipping",
                                        leftButtonAction: didTabBack)
        self.headerView.bottomLbl.isHidden = true
        self.headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
      
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
extension PaymentAndShippingViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return PaymentSection.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = PaymentSection(rawValue: section) else { return 0 }
        
        return sectionType.numberOfRows(data: sectionData)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = PaymentSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for AboutUsRows")
        }
        
        switch rowType {
            
      
            
        case .header:
            let cell = tableView.dequeueCell(with: AppHeaderCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.titleOlt.text = "Payment Methods"
            
            cell.selectionStyle = .none
            return cell
        case .card:
            let cell = tableView.dequeueCell(with: LocationNameCell.self)
            cell.outerViewOlt.backgroundColor = .pearl
            cell.imageOlt.makeCornerRounded(ofSize: 8)
            cell.imageOlt.image = UIImage(named: "cardImg")
            cell.titleOlt.text = "**** 4543"
            cell.descriptionOlt.text = "Expire 11/25"
            let img = "ellipsis"
            cell.rightButtonOlt.setImage(UIImage(systemName: img), for: .normal)
            cell.rightButtonOlt.transform =  cell.rightButtonOlt.transform.rotated(by: Double.pi/2)
            return cell
        case .addButton:
            let cell = tableView.dequeueCell(with: SubmitCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.submitBtnOlt.setImage(UIImage(systemName: "plus")?.withTintColor(.darkBlue, renderingMode: .alwaysOriginal), for: .normal)
            cell.submitBtnOlt.setTitle("Add Payment Method", for: .normal)
            cell.submitBtnOlt.setTitleColor(.darkBlue, for: .normal)
            cell.submitBtnOlt.backgroundColor = .pearl
            cell.submitBtnOlt.addBorders(of: .darkBlue, width: 1.0)
            cell.selectionStyle = .none
            return cell
        case .addressHeader:
            let cell = tableView.dequeueCell(with: AppHeaderCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.titleOlt.text = "Shipping Address"
            
            cell.selectionStyle = .none
            return cell
        case .address:
            
            let cell = tableView.dequeueCell(with: AddressCell.self)
           
            cell.contentView.backgroundColor = .pearl
            cell.countryOlt.isHidden = true
            cell.phoneOlt.isHidden = true
            
            cell.selectionStyle = .none
            return cell
        case .addAddressButton:
            let cell = tableView.dequeueCell(with: SubmitCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.submitBtnOlt.setImage(UIImage(systemName: "plus")?.withTintColor(.darkBlue, renderingMode: .alwaysOriginal), for: .normal)
            cell.submitBtnOlt.setTitle("Add New Address", for: .normal)
            cell.submitBtnOlt.setTitleColor(.darkBlue, for: .normal)
            cell.submitBtnOlt.backgroundColor = .pearl
            cell.submitBtnOlt.addBorders(of: .darkBlue, width: 1.0)
            cell.selectionStyle = .none
            return cell
        }
    }
    
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            guard let rowType = PaymentSection.allCases[safe: indexPath.section] else {
                fatalError("Invalid index for AboutUsRows")
            }
    
            switch rowType {
          
            case .header:
                return Const.Height.AutomaticDimension
            case .card:
                return Const.Height.AutomaticDimension
            case .addButton:
                return Const.Height.submitBtn
            case .addressHeader:
                return Const.Height.AutomaticDimension
            case .address:
                return Const.Height.AutomaticDimension
            case .addAddressButton:
                return Const.Height.submitBtn
            }
    
        }
    
}

