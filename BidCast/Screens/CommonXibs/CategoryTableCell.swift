//
//  MyOrderCollectionCell.swift
//  BidCast
//
//  Created by JAM_E_329 on 08/05/25.
//

import UIKit



class CategoryTableCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet var collectionViewOlt: UICollectionView!
    
    //MARK: properties.
    static let identifier = "CategoryTableCell"
    
    var title = ["For You","Collectible","Trading card","Collectible","Trading card"]
    var didTapBtn : (Int) -> () = {_ in }
    var selectedIndex = 0

    
    //MARK: - Initializations
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionVIew()
       
    }
    
    func configureCollectionVIew(){
        let cellId = [
            CategoryRowCollectionViewCell.identifier
           
        ]
        self.collectionViewOlt.registerCells(for: cellId)
        self.collectionViewOlt.delegate = self
        self.collectionViewOlt.dataSource = self
        
    }
    
}
extension CategoryTableCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: CategoryRowCollectionViewCell.self, for: indexPath)
        if selectedIndex == indexPath.row{
            cell.outerStackView.backgroundColor = .secondary
        }else{
            cell.outerStackView.backgroundColor = .bg
        }
        cell.categoryLabel.text = title[indexPath.row]
        cell.outerStackView.makeCornerRounded(ofSize: 25)
        return cell
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewOlt.frame.width/2.4 - 20, height: 50)
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didTapBtn(indexPath.row)
    }
}
