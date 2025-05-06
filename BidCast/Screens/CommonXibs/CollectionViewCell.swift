//
//  CollectionViewCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 06/05/25.
//

import UIKit

class CollectionViewCell: UITableViewCell {

    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet weak var collectionViewOlt: UICollectionView!
    
    static let identifier = "CollectionViewCell"
    var isForDetails = false
    var items = [Any]()
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionVIew()
        self.configure(with: [""])
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with items: [Any]) {
        self.items = items
        self.collectionViewOlt.reloadData()
        self.collectionViewOlt.layoutIfNeeded()

        let rows = ceil(CGFloat(10) / 2.0)
        let itemHeight: CGFloat = 100  // same as returned in sizeForItemAt
        let spacing: CGFloat = 10  // adjust based on your layout spacing
        let totalHeight = (rows * itemHeight) + ((rows - 1) * spacing)
        collectionViewHeightConstraint.constant = totalHeight
    }
    
    func configureCollectionVIew(){
        let cellId = [
            ProductCollectionViewCell.identifier
        ]
        self.collectionViewOlt.registerCells(for: cellId)
        self.collectionViewOlt.delegate = self
        self.collectionViewOlt.dataSource = self
        
    }
    
}
extension CollectionViewCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isForDetails{
            return 3
        }else{
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: ProductCollectionViewCell.self)
        cell.productNameLbl.text = "test"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isForDetails{
            return CGSize(width: self.collectionViewOlt.frame.width/3 - 10, height: 80)
        }else{
            return CGSize(width: self.collectionViewOlt.frame.width/2, height: 80)
        }
    }
    
    
    
}
