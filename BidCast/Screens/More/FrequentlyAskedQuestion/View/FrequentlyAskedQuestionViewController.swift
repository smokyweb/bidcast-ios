//
//  FrequentlyAskedQuestionViewController.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25. on 27/12/24.
//

import UIKit
import SVProgressHUD

enum FAQRow: Int, CaseIterable {
    case FaqHeader
    case FAQRow
    
    func numberOfRows(data: [FAQRow: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class FrequentlyAskedQuestionViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var tblView: UITableView!
    
    @IBOutlet var heightHeaderConstraint: NSLayoutConstraint!
    //MARK: Properties
    private var selectedIndex = 0
    var viewModel = FAQViewModel()
    
    var faqDatArray:[FAQModel] = []
    
   lazy var sectionData: [FAQRow: Int] = [
        .FAQRow: faqDatArray.count
    ]
    
    //MARK: ViewLife Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadInit()
    }
    
    //MARK: - Configure view Method.
    private func loadInit(){
        self.initialViewModel()
        self.configureTableView()
        self.configureHeaderView()
        self.fetchApi()
    }
    
    //MARK: configureTableView.
    private  func configureTableView(){
        self.tblView.delegate = self
        self.tblView.dataSource = self
        let cellIds = [FAQCell.identifier,AppHeaderCell.identifier,NoDataTableViewCell.identifier]
        tblView.registerCells(for: cellIds)
        tblView.configTblView()
        configureHeaderView()
    }
    
    //MARK: configureView.
    private func configureHeaderView() {
        self.headerView.headerViewSetup(leftButtonHidden: false,
                                        headerName: AppString.VCName.faq,
                                        leftButtonAction: didTabBack)
        heightHeaderConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotch : Const.Height.notNotch
        headerView.cenetrVerticalConstraint.constant = UIDevice.current.hasNotch ? Const.Height.isNotchCenter : Const.Height.notNotchCenter
    }
    
    //MARK: fetch api .
    private func fetchApi(){
        if Reachability.isConnectedToNetwork(){
            SVProgressHUD.show()
            self.viewModel.getFAQData()
        }else{
            DispatchQueue.main.async {
                Utilities.sharedInstance.showToast(source: self, message: Toast.Network.noConnection)
            }
        }
    }
    // MARK: initialViewModel
    func initialViewModel(){
        self.viewModel.userDelegate = self
    }
    //MARK: didTabBack
    @objc private func didTabBack(){
        self.goToBack()
    }
    
}
//MARK: - UITableViewDelegate,UITableViewDataSource.
extension FrequentlyAskedQuestionViewController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return FAQRow.allCases.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = FAQRow(rawValue: section) else { return 0 }
        debugLog("Rows in section:\(sectionType.numberOfRows(data: sectionData))")
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let rowType = FAQRow.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for FAQRow")
        }
        
        switch rowType {
        case .FaqHeader:
            let cell = tblView.dequeueCell(with: AppHeaderCell.self)
            cell.outerViewOlt.backgroundColor = .ultraLightGray
            cell.titleOlt.text = AppString.Header.faq
            return cell
        case .FAQRow:
            let cell = tableView.dequeueCell(with: FAQCell.self)
            cell.contentView.backgroundColor = .ultraLightGray
            if let dataFAQ = self.viewModel.FAQDict?.data{
                cell.lblQuestions.text = dataFAQ?[indexPath.row].question
                cell.lblQuestions.font = AppFont.LblTitleBold_17
                cell.lblAnswer.attributedText = dataFAQ?[indexPath.row].answer?.htmlToAttributedString
                cell.lblAnswer.font = AppFont.LblTitle_15
            }
            if self.selectedIndex == indexPath.row {
                cell.secondView.isHidden = false
                cell.vertorImg.image = UIImage(named: "ic_arrowUp")
            }else{
                cell.secondView.isHidden = true
                cell.vertorImg.image = UIImage(named: "ic_arrowDown")
            }
            cell.showBtn.tag = indexPath.row
            cell.didTabFAQ = { [weak self] sender in
                if self?.selectedIndex == sender.tag{
                    self?.selectedIndex = -1
                }else{
                    self?.selectedIndex = sender.tag
                }
                
                self?.tblView.reloadData()
            }
            cell.selectionStyle = .none
            return cell
            
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let rowType = FAQRow.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for FAQRow")
        }
        
        switch rowType {
        case .FAQRow:
            return Const.Height.AutomaticDimension
        case .FaqHeader:
            return Const.Height.header
        }
    }
}

//MARK: API CALL.
extension FrequentlyAskedQuestionViewController: UserServices {
    func reloadData() {
        SVProgressHUD.dismiss()
        if let dict = self.viewModel.FAQDict {
            let statusType = APIResponseStatus(rawValue: dict.status ?? "")
            switch statusType {
            case .success:
                //success API Response
                debugLog("success API Response")
                //update aray and sectionDict
                self.faqDatArray = (dict.data ?? []) ?? []
                sectionData[.FAQRow] = self.faqDatArray.count > 0 ? self.faqDatArray.count : 1
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







