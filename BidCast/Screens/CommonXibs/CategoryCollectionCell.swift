//
//  CategoryCollectionCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 07/05/25.
//

import UIKit

class CategoryCollectionCell: UICollectionViewCell {

    static  let identifier = "CategoryCollectionCell"
    var title = ["For You","Collectible","Trading card","Collectible","Trading card"]
    @IBOutlet weak var collectionViewOlt: UICollectionView!
    @IBOutlet weak var outerViewOlt: UIView!
    
    var didTapBtn : (Int) -> () = {_ in }
    var selectedIndex = 0
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
extension CategoryCollectionCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType:CategoryRowCollectionViewCell.self)
        if selectedIndex == indexPath.row{
            cell.outerStackView.backgroundColor = .secondary
        }else{
            cell.outerStackView.backgroundColor = .bg
        }
        cell.categoryLabel.text = title[indexPath.row]
        cell.outerStackView.makeCornerRounded(ofSize: 32)
        return cell
        
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionViewOlt.frame.width/2.4 - 20, height: 60)
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didTapBtn(indexPath.row)
    }
}
