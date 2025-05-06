//
//  HSelectedAlertModelViewController.swift
//  Well Genius App
//
//  Created by Fazal-JAM-E-329 on 12/12/24.
//

import UIKit

class HSelectedAlertModelViewController: UIViewController {

    @IBOutlet var selectedAlertTbl: UITableView!
    @IBOutlet var headerView: HeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }

    //MARK: configureView.
    private func configureView() {
        self.headerView.headerViewSetup(rightButtonHidden: false, leftButtonHidden: false,headerName: AppString.VCName.selectedAlert,setRightImage: UIImage(named: "ic_delete")?.withTintColor(.white, renderingMode: .alwaysTemplate),leftButtonAction: didTabBack)
        configureTableView()
    }
    
    //MARK: didTabBack.
    @objc func didTabBack() {
        self.goToBack()
    }
}

//MARK: UITableViewDelegate,UITableViewDataSource.
extension HSelectedAlertModelViewController : UITableViewDelegate,UITableViewDataSource{
    private func configureTableView(){
        self.selectedAlertTbl.delegate = self
        self.selectedAlertTbl.dataSource = self
        let cellIds = [LabelCell.identifier,AppHeaderExpendableCell.identifier,LocationNameCell.identifier]
        selectedAlertTbl.registerCells(for: cellIds)
        self.selectedAlertTbl.separatorStyle = .none
        self.selectedAlertTbl.rowHeight = UITableView.automaticDimension
        selectedAlertTbl.backgroundColor = AppColor.ghostWhite
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = SectionType.section(for: section)
        switch sectionType {
        case .section0:
            return 1
        case .section1:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = selectedAlertTbl.dequeueCell(with: AppHeaderExpendableCell.self)
            cell.outerViewOlt.backgroundColor = AppColor.ghostWhite
            cell.rightButtonOlt.isHidden = true
            cell.titleOlt.text = AppString.Title.alert
            return cell
        }else if indexPath.section == 1{
            let cell = selectedAlertTbl.dequeueCell(with: LocationNameCell.self)
            cell.contentView.backgroundColor = AppColor.ghostWhite
            cell.selectionStyle = .none
            return cell
        }
        else{
            let cell = selectedAlertTbl.dequeueCell(with: LabelCell.self)
            cell.contentView.backgroundColor = AppColor.ghostWhite
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0{
            return 70
        }else if indexPath.section == 1{
            return 70
        }else {
            return UITableView.automaticDimension
        }
    }
}

