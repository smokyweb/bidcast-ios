//
//  ColelctionWithLabelCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 08/05/25.
//

import UIKit

class ColelctionWithLabelCell: UITableViewCell {

    static let identifier = "ColelctionWithLabelCell"
    
    @IBOutlet weak var collectionViewOlt: UICollectionView!
    @IBOutlet weak var titleLabelOlt: UILabel!
    @IBOutlet weak var outerViewOlt: UIView!
    
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var isForTeam = false
    var isForKey = false
    var isForImpact = false
    var items = [Any]()
    
    var impactTitle = [String]()
    var keySubLabel = [String]()
    var keyImage = [String]()
    var KeyName = [String]()
    var impactSublabel = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionVIew()
       
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(with items: [String]) {
        self.items = items
        
        self.collectionViewOlt.layoutIfNeeded()

        let rows = ceil(CGFloat(4/*items.count*/) / 2.0)
        let itemHeight: CGFloat = 150
        let spacing: CGFloat = 4
        let totalHeight = (rows * itemHeight) + ((rows - 1) * spacing)
        self.collectionViewHeight.constant = totalHeight
        self.collectionViewOlt.reloadData()
    }
    
    func configureCollectionVIew(){
        let cellId = [
            ProductCollectionViewCell.identifier,
            SellerRevenueCell.identifier,
            KeyCollectionViewCell.identifier,
            MemberCollectionViewCell.identifier
        ]
        self.collectionViewOlt.registerCells(for: cellId)
        self.collectionViewOlt.delegate = self
        self.collectionViewOlt.dataSource = self
        
       
        
    }
    
    func collectionDirection(direction:Int){
        if let layout = collectionViewOlt.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.scrollDirection = direction == 0 ? .vertical : .horizontal
                collectionViewOlt.setCollectionViewLayout(layout, animated: false)
            }
    }
}
extension ColelctionWithLabelCell : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.isForKey{
            return 4
        }else if isForTeam{
            return 5
        }else {
            return 3
        }
           
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        if isForImpact{
                let cell = collectionView.dequeueCell(ofType: SellerRevenueCell.self)
                cell.innerView.makeCornerRounded(ofSize: 12)
            cell.labelOlt.textColor = .secondary
            cell.labelOlt.text = self.impactTitle[indexPath.row]
            cell.productNameLbl.text = self.impactSublabel[indexPath.row]
            
                return cell
        }else if isForKey{
            let cell = collectionView.dequeueCell(ofType: KeyCollectionViewCell.self)
            cell.titleOlt.text = self.KeyName[indexPath.row]
            cell.imgOlt.image = UIImage(named: self.keyImage[indexPath.row])
            cell.subLabelOlt.text = self.keySubLabel[indexPath.row]
            cell.outerViewOlt.makeCornerRounded(ofSize: 12)
           
            return cell
        }else{
            let cell = collectionView.dequeueCell(ofType: MemberCollectionViewCell.self)
            cell.outerViewOlt.makeCornerRounded(ofSize: 12)
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
        if self.isForKey{
            return CGSize(width: self.collectionViewOlt.frame.width/2.1 - 2, height: 140)
        }else if isForTeam{
            return CGSize(width: self.collectionViewOlt.frame.width/3 - 10 , height: 170)
        }else {
            return CGSize(width: self.collectionViewOlt.frame.width/2.8 - 10, height: 100)
        }
       
               
            
    }
  
}
