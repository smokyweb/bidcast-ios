//
//  HomeViewController.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 06/05/25.
//

import UIKit

enum HomeSection : Int, CaseIterable {
   
    case category
    case label
    case data
    
    func numberOfRows(data: [HomeSection: Int]) -> Int {
        return data[self] ?? 1 // Default to 1 if no data provided
    }
}

class HomeViewController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var headerViewolt: HeaderWithAppName!
    @IBOutlet weak var collectionViewOlt: UICollectionView!
    
    //MARK: Properties
    var sectionData : [ HomeSection : Int] = [
        .category : 1,
        .label : 1,
        .data : 8
    ]
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureHeaderView()
        self.configureCollectionVIew()
    }
    
    func configureHeaderView(){
        self.headerViewolt.headerViewSetup(rightButtonHidden: false,leftButtonHidden: false , headerName: "",setRightImage: UIImage(systemName: "bell.fill")?.withTintColor(.black, renderingMode: .alwaysTemplate),setLeftImage: UIImage(named: "ic_search")?.withTintColor(.black, renderingMode: .alwaysTemplate))
    }
    
    
    func configureCollectionVIew(){
        let cellId = [
            CategoryCollectionCell.identifier,
            LabelCollectionCell.identifier,
            CollectionCardCell.identifier
            
        ]
        self.collectionViewOlt.registerCells(for: cellId)
        self.collectionViewOlt.delegate = self
        self.collectionViewOlt.dataSource = self
        
    }
    
}
extension HomeViewController : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HomeSection.allCases.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let sectionType = HomeSection(rawValue: section) else { return 0 }
       
        return sectionType.numberOfRows(data: sectionData)
        
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let rowType = HomeSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for LoginTableRow")
        }
        switch rowType {
        case .category:
            let cell = collectionView.dequeueCell(ofType: CategoryCollectionCell.self)
            cell.didTapBtn = { index in
                cell.selectedIndex = index
                cell.collectionViewOlt.reloadData()
            }
           
            return cell
        case .label:
            let cell = collectionView.dequeueCell(ofType: LabelCollectionCell.self)
            return cell
        case .data:
            let cell = collectionView.dequeueCell(ofType: CollectionCardCell.self)
           
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let rowType = HomeSection.allCases[safe: indexPath.section] else {
            fatalError("Invalid index for LoginTableRow")
        }
        switch rowType {
        case .category:
            return CGSize(width: self.collectionViewOlt.frame.width - 10, height: 90)
        case .label:
            return CGSize(width: self.collectionViewOlt.frame.width - 10, height: 60)
        case .data:
            return CGSize(width: self.collectionViewOlt.frame.width/2 - 1, height: 350)
        }
       
       
    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//     
//    }
}
