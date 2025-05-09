//
//  MyOrderCollectionCell.swift
//  BidCast
//
//  Created by JAM_E_329 on 08/05/25.
//

import UIKit

struct OrderDetail{
    var orderName : String?
    var orderPrice : String?
}

class MyOrderCollectionCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet var collectionViewOlt: UICollectionView!
    
    //MARK: properties.
    static let identifier = "MyOrderCollectionCell"
    var spacing: CGFloat = 2.5
    var itemsPerRow : CGFloat = 3.0
    var orderName : [OrderDetail] = []

    
    //MARK: - Initializations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
       
    }
    
    //MARK: configure
    func configure() {
        collectionViewOlt.delegate = self
        collectionViewOlt.dataSource = self
        let cellIds = [NoDataTableViewCell.identifier,SellerRevenueCell.identifier]
        collectionViewOlt.registerCells(for: cellIds)
        self.collectionViewOlt.showsHorizontalScrollIndicator = false
    }
}

//MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension MyOrderCollectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if orderName == nil || orderName.isEmpty {
            return 1 // Return 1 when there are no images
        } else {
            return orderName.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionViewOlt.dequeueCell(ofType: SellerRevenueCell.self)
            cell.innerView.makeCornerRounded(ofSize: 12)
        cell.labelOlt.text = orderName[indexPath.row].orderPrice
        cell.productNameLbl.text = orderName[indexPath.row].orderName
        cell.innerView.backgroundColor = .white
        cell.innerView.addBorders(of: .pearl, width: Width_01)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 5 // Total padding (left + right)
        let itemsPerRow: CGFloat = itemsPerRow
        let totalSpacing = (itemsPerRow - 1) * spacing // Space between items
        
        let width = (collectionViewOlt.frame.width - padding - totalSpacing) / itemsPerRow
        let height: CGFloat = 100
        return CGSize(width: width , height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return spacing
    }
}
