//
//  CollectionViewCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 06/05/25.
//

import UIKit

class CollectionViewCell: UITableViewCell {

    @IBOutlet weak var collectionViewHeihgt: NSLayoutConstraint!
    @IBOutlet weak var outerViewOlt: UIView!
    @IBOutlet weak var collectionViewOlt: UICollectionView!
    
    static let identifier = "CollectionViewCell"
    var isForDetails = false
    var items = [Any]()
    var seller = [String]()
    var sellerItemsNAme = [String]()
    var imageName = [String]()
    var titleName = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionVIew()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with items: [String]) {
        self.items = items
        self.collectionViewOlt.reloadData()
        self.collectionViewOlt.layoutIfNeeded()

        let rows = ceil(CGFloat(items.count) / 2.0)
        let itemHeight: CGFloat = 100
        let spacing: CGFloat = 8
        let totalHeight = (rows * itemHeight) + ((rows - 1) * spacing)
        self.collectionViewHeihgt.constant = totalHeight
    }
    
    func configureCollectionVIew(){
        let cellId = [
            ProductCollectionViewCell.identifier,
            SellerRevenueCell.identifier
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
            return self.seller.count == 0 ? 0 : self.seller.count
        }else{
            return self.titleName.count == 0 ? 0 : self.titleName.count
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if isForDetails{
            let cell = collectionView.dequeueCell(ofType: SellerRevenueCell.self)
            cell.innerView.makeCornerRounded(ofSize: 12)
            cell.labelOlt.text = self.seller[indexPath.row]
            cell.productNameLbl.text = self.sellerItemsNAme[indexPath.row]
            return cell
        }else{
            let cell = collectionView.dequeueCell(ofType: ProductCollectionViewCell.self)
            cell.innerView.makeCornerRounded(ofSize: 12)
            if self.titleName.count != 0{
                cell.productNameLbl.text = self.titleName[indexPath.row]
                cell.productImgView.image = UIImage(named: self.imageName[indexPath.row])
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if isForDetails{
            return CGSize(width: self.collectionViewOlt.frame.width/3 - 10, height: 100)
        }else{
            return CGSize(width: self.collectionViewOlt.frame.width/2 - 10, height: 100)
        }
    }
    
    
    
}
