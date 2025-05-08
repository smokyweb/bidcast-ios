//
//  AboutUsViewController.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25. on 27/12/24.
//

import UIKit
import SVProgressHUD

enum AboutUsRows: Int, CaseIterable {
    case BidSwipe
    case seperator
    case missionHeader
    case missionLabel
    case seperator2
    case key
    case impact
    case team
    case support
    case shareSocial
    
    func numberOfRows(data: [AboutUsRows: Int]) -> Int {
        return data[self] ?? 1
    }
}

class AboutUsViewController: UIViewController {
    
    
    //MARK: IBOutlets
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var tblView: UITableView!
    
    //MARK: Properties
    var viewModel = AboutUsViewModel()
    var sectionData : [AboutUsRows : Int] = [
        .BidSwipe : 1,
        .seperator : 1 ,
        .missionHeader : 1,
        .missionLabel : 1,
        .seperator2 : 1,
        .key : 1,
        .impact : 1,
        .team : 1,
        .support : 2,
        .shareSocial : 1
    ]
    var impactTitle = ["50K+","100K+","$2M+"]
    var keySubLabel = ["Real-Time auction Broadcasting","Instant Bid Placement","Real-Time Communication","Safe Transaction Statement"]
    var keyImage = ["stream","live","chat","help"]
    var KeyName = ["Live Streaming","Live Bidding","Live Chat","Secure Payment"]
    var impactSublabel = ["Users","Auctions","Sales"]
    var support = ["support@bidswipe.com","+1 (555) 123-4567"]
    var supportImg = ["mail","phone"]
    
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
        self.tblView.delegate = self
        self.tblView.dataSource = self
        let cellIds =  [
            LabelCell.identifier,
            ImageWithTitleCell.identifier,
            AppHeaderCell.identifier,
            SeperatorCell.identifier,
            ColelctionWithLabelCell.identifier,
            ShareCell.identifier,
            MenuCell.identifier
        ]
        
        tblView.registerCells(for: cellIds)
        self.tblView.separatorStyle = .none
        tblView.configTblView(bgColor : .ultraLightGray)
    }
    
    
    //MARK: configureView.
    private func configureHeaderView() {
        self.headerView.headerViewSetup(leftButtonHidden: false,
                                        headerName: AppString.VCName.aboutUs,
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
        if Reachability.isConnectedToNetwork(){
            SVProgressHUD.show()
            self.viewModel.getAboutUsData()
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    
    //MARK: - didtapBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource
extension AboutUsViewController: UITableViewDelegate,UITableViewDataSource{
    func numberOfSections(in tableView: UITableView) -> Int {
        return AboutUsRows.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = AboutUsRows(rawValue: section) else { return 0 }
       
        return sectionType.numberOfRows(data: sectionData)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = AboutUsRows.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for AboutUsRows")
        }
        
        switch rowType {
            
        case .BidSwipe:
            let cell = tableView.dequeueCell(with: ImageWithTitleCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.selectionStyle = .none
            return cell
        case .seperator:
            let cell = tableView.dequeueCell(with: SeperatorCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.selectionStyle = .none
            return cell
        case .missionHeader:
            let cell = tableView.dequeueCell(with: AppHeaderCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.titleOlt.text = "Our Mission"
            
            cell.selectionStyle = .none
            return cell
        case .missionLabel:
            let cell = tableView.dequeueCell(with: LabelCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.titleOlt.text = "BidSwipe revolutionizes online auctions by connecting sellers and buyers through live streaming technology. We make bidding exciting, transparent, and accessible to everyone."
            cell.selectionStyle = .none
            return cell
        case .seperator2:
            let cell = tableView.dequeueCell(with: SeperatorCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.selectionStyle = .none
            return cell
        case .key:
            let cell = tableView.dequeueCell(with: ColelctionWithLabelCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.selectionStyle = .none
            cell.titleLabelOlt.text = "Key Features"
            cell.keyImage = self.keyImage
            cell.KeyName = self.KeyName
            cell.keySubLabel = self.keySubLabel
            cell.isForKey = true
            cell.isForTeam = false
            cell.isForImpact = false
            cell.configure(with: [""])
            cell.collectionViewOlt.isScrollEnabled = false
            cell.collectionDirection(direction: 0)
            cell.collectionViewOlt.reloadData()
            return cell
        case .impact:
            let cell = tableView.dequeueCell(with: ColelctionWithLabelCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.selectionStyle = .none
            cell.isForKey = false
            cell.isForTeam = false
            cell.isForImpact = true
            cell.impactTitle = self.impactTitle
            cell.impactSublabel = self.impactSublabel
            cell.titleLabelOlt.text = "Our Impact"
            cell.collectionDirection(direction: 1)
            cell.collectionViewOlt.isScrollEnabled = false
            cell.collectionViewOlt.reloadData()
            return cell
        case .team:
            let cell = tableView.dequeueCell(with: ColelctionWithLabelCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.selectionStyle = .none
            cell.isForKey = false
            cell.isForTeam = true
            cell.isForImpact = false
            cell.titleLabelOlt.text = "Our Team"
            cell.collectionDirection(direction: 1)
            cell.collectionViewOlt.isScrollEnabled = true
            cell.collectionViewOlt.reloadData()
            return cell
        case .support:
            let cell = tableView.dequeueCell(with: MenuCell.self)
            cell.contentOuterViewOlt.backgroundColor = .pearl
            cell.labelOlt.text = self.support[indexPath.row]
            cell.imgOlt.image = UIImage(named: self.supportImg[indexPath.row])
            cell.selectionStyle = .none
           
            return cell
        case .shareSocial:
            let cell = tableView.dequeueCell(with: ShareCell.self)
            cell.contentView.backgroundColor = .pearl
            cell.selectionStyle = .none
            
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = AboutUsRows.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for AboutUsRows")
        }
        
        switch rowType {
        case .BidSwipe:
            return UITableView.automaticDimension
        case .seperator:
            return UITableView.automaticDimension
        case .missionHeader:
            return UITableView.automaticDimension
        case .missionLabel:
            return UITableView.automaticDimension
        case .seperator2:
            return UITableView.automaticDimension
        case .key:
            return UITableView.automaticDimension
        case .impact:
            return 150
        case .team:
            return UITableView.automaticDimension
        case .support:
            return UITableView.automaticDimension
        case .shareSocial:
            return UITableView.automaticDimension
        }
       
    }
}

////MARK: API CALL.
//extension AboutUsViewController: UserServices {
//    func reloadData() {
//        SVProgressHUD.dismiss()
//        if let dict = self.viewModel.aboutUsDict {
//            let statusType = APIResponseStatus(rawValue: dict.status ?? "")
//            switch statusType {
//            case .success:
//                //success API Response
//                debugLog("success API Response")
//                self.tblView.reload()
//            case .failure:
//                Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
//            default:
//                Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
//            }
//        }
//    }
//    
//    func showError(error: String) {
//        SVProgressHUD.dismiss()
//        DispatchQueue.main.async {
//            Utilities.sharedInstance.showToast(source: self, message: error)
//        }
//    }
//
//}
//
//
//
//
//
