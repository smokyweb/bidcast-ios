//
//  AboutUsViewController.swift
//  Rise Shine Swing
//
//  Created by JAM-E-329 on 27/12/24.
//

import UIKit
import SVProgressHUD

enum AboutUsRows: Int, CaseIterable {
    case AboutUsHeader
    case sliderImg
    case description
}

class AboutUsViewController: UIViewController {
    
    
    //MARK: IBOutlets
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    //MARK: Properties
    var viewModel = AboutUsViewModel()
    
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
        self.fetchApi()
    }
    
    //MARK: - configureTableView.
    private func configureTableView(){
        self.tblView.delegate = self
        self.tblView.dataSource = self
        let cellIds =  [LabelCell.identifier,SliderCell.identifier,AppHeaderCell.identifier]
        tblView.registerCells(for: cellIds)
        tblView.configTblView(bgColor : .ultraLightGray)
    }
    
    
    //MARK: configureView.
    private func configureHeaderView() {
        self.headerView.headerViewSetup(leftButtonHidden: false,
                                        headerName: AppString.VCName.aboutUs,
                                        leftButtonAction: didTabBack)
        self.headerView.bottomLbl.isHidden = false
        self.headerView.bottomLbl.text = AppString.VCName.riseShineSwing
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchWithLabel : Const.Height.notNotch
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.notNotchCenter : 0
    }
    
    //MARK: initViewModel.
    func initViewModel() {
        self.viewModel.userDelegate = self
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
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AboutUsRows.allCases.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = AboutUsRows.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for AboutUsRows")
        }
        
        switch rowType {
        case .AboutUsHeader:
            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
            cell.outerViewOlt.backgroundColor = .ultraLightGray
            cell.titleOlt.text = AppString.Header.aboutUs
            return cell
            
        case .sliderImg:
            let cell = tblView.dequeueCell(with: SliderCell.self)
            cell.contentView.backgroundColor = .ultraLightGray
            if let imageData =  self.viewModel.aboutUsDict?.data?.images {
                cell.imgArr = imageData
            }
            cell.collectionViewOlt.reloadData()
            cell.selectionStyle = .none
            return cell
            
        case .description:
            let cell = tblView.dequeueCell(with: LabelCell.self)
            cell.innerViewOlt.backgroundColor = .ultraLightGray
            cell.titleOlt.textColor = AppColor.Label.lightBlack
            if let data =  self.viewModel.aboutUsDict?.data {
                cell.titleOlt.attributedText = data.pageContent?.htmlToAttributedString
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = AboutUsRows.allCases[safe: indexPath.row] else {
            fatalError("Invalid index for AboutUsRows")
        }
        switch rowType {
        case .AboutUsHeader:
            return Const.Height.header
        case .sliderImg:
            return Const.Height.sliderImg
        case .description:
            return Const.Height.AutomaticDimension
        }
    }
}

//MARK: API CALL.
extension AboutUsViewController: UserServices {
    func reloadData() {
        SVProgressHUD.dismiss()
        if let dict = self.viewModel.aboutUsDict {
            let statusType = APIResponseStatus(rawValue: dict.status ?? "")
            switch statusType {
            case .success:
                //success API Response
                debugLog("success API Response")
                self.tblView.reload()
            case .failure:
                Utilities.sharedInstance.showToast(source: self, message: dict.message ?? "")
            default:
                Utilities.sharedInstance.showToast(source: self, message: "Some Error Occcured")
            }
        }
    }
    
    func showError(error: String) {
        SVProgressHUD.dismiss()
        DispatchQueue.main.async {
            Utilities.sharedInstance.showToast(source: self, message: error)
        }
    }

}





