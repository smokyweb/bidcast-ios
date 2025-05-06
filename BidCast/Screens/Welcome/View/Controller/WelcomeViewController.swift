//
//  WelcomeViewController.swift
//  Well Genius App
//
//  //  Created by Fazal-JAM-E-329 on 11/12/24.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    //MARK: IBOutlets.
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet var welcomeTbl: UITableView!
    
    //MARK: Properties
    
    //MARK: ViewLife Cycle Methods.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureTableView()
    }
    
    //MARK: configureTableView.
    private func configureTableView(){
        self.welcomeTbl.delegate = self
        self.welcomeTbl.dataSource = self
        let cellIds = [NewsCell.identifier,AppHeaderCell.identifier]
        welcomeTbl.registerCells(for: cellIds)
        self.welcomeTbl.separatorStyle = .none
        welcomeTbl.showsVerticalScrollIndicator = false
        self.welcomeTbl.rowHeight = UITableView.automaticDimension
        self.configureHeaderView()
    }
    //MARK: configureView.
    private func configureHeaderView() {
        self.headerView.headerViewSetup(leftButtonHidden: false, headerName: AppString.VCName.welcome,leftButtonAction: didTabBack)
    }
    
    
    //MARK: didTabBack.
    @objc private func didTabBack(){
        self.goToBack()
    }
    
    //MARK: didTap.
    private func didTap(index:Int){
    }
}

//MARK: - UITableViewDelegate,UITableViewDataSource.
extension WelcomeViewController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = SectionType.section(for: section)
        switch sectionType {
        case .section0:
            return 1
        default:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = welcomeTbl.dequeueCell(with: AppHeaderCell.self)
            cell.titleOlt.text = AppString.Header.news
            cell.contentView.backgroundColor = AppColor.View.bgLightGray
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = welcomeTbl.dequeueCell(with: NewsCell.self)
            return cell
        }
    }
}

func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
        return UITableView.automaticDimension
    }else{
        return 90
    }
}

