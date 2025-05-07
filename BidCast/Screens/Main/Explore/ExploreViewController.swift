//
//  ExploreViewController.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 06/05/25.
//

import UIKit

enum ExploreSection : Int, CaseIterable {
    case search
    case label
    case category
   
    
    func numberOfRows(data: [ExploreSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}


class ExploreViewController: UIViewController {

    @IBOutlet weak var tableViewOlt: UITableView!
    @IBOutlet weak var headerViewOlt: HeaderWithAppName!
    //MARK: Properties
    var sectionData : [ExploreSection : Int ] = [
        .search : 1,
        .label : 1,
        .category : 5
       
    ]
    
    
    var imageName = ["gaming","sports","jewelery","fashion","vinyl"]
    var tabName = ["Gaming","Sports","Jewellery ","Fashion","Vinyl Records"]
    var subLabel = ["864 Live","1.2K Live","640 Live","640 Live","640 Live"]
    
   
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureHeaderView()
        configureTableView()
    }

    func configureHeaderView(){
        self.headerViewOlt.headerViewSetup(rightButtonHidden: false,leftButtonHidden: false , headerName: "",setRightImage: UIImage(systemName: "bell.fill")?.withTintColor(.black, renderingMode: .alwaysTemplate),setLeftImage: UIImage(named: "ic_search")?.withTintColor(.black, renderingMode: .alwaysTemplate))
    }
    
    
    private func configureTableView(){
        self.tableViewOlt.delegate = self
        self.tableViewOlt.dataSource = self
        self.tableViewOlt.configTblView(bgColor:.bg)
        
       
        let cellIds = [LocationNameCell.identifier,
                       SearchTextfieldCell.identifier,
                       LabelCell.identifier,
                      
                       ]
        tableViewOlt.registerCells(for: cellIds)
        
    }
    
}
extension ExploreViewController : UITableViewDataSource,UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return ExploreSection.allCases.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionType = ExploreSection(rawValue: section) else { return 0 }
       
        return sectionType.numberOfRows(data: sectionData)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let rowType = ExploreSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for LoginTableRow")
        }
        switch rowType {
            
            
        case .search:
            let cell = tableViewOlt.dequeueCell(with: SearchTextfieldCell.self)
            cell.innerViewOlt.addBorders(of: .black, width: 1.0)
            return cell
        case .label:
            let cell = tableViewOlt.dequeueCell(with: LabelCell.self)
            cell.titleOlt.text = "Recommended | Popular | All"
            cell.titleOlt.font = AppFont.LblTitleBold_17
            cell.titleOlt.textColor = .black
            cell.innerViewOlt.backgroundColor = .bg
            return cell
        case .category:
            let cell = tableViewOlt.dequeueCell(with: LocationNameCell.self)
            cell.imageOlt.image = UIImage(named: self.imageName[indexPath.row])
            cell.titleOlt.text = self.tabName[indexPath.row]
            cell.descriptionOlt.text = self.subLabel[indexPath.row]
            cell.rightButtonOlt.isHidden = false
            cell.rightButtonOlt.setImage(UIImage(systemName: "chevron.right")?.withTintColor(.black, renderingMode: .alwaysTemplate), for: .normal)
            cell.contentView.backgroundColor = .clear
            cell.outerViewOlt.backgroundColor = .bg
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      
            return UITableView.automaticDimension
        
    }
}
