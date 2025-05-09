//
//  CategoryTableViewCell.swift
//  BidCast
//
//  Created by Fazal-JAM-E-329 on 07/05/25.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    static let identifier = "CategoryTableViewCell"
    
    var categoryListArray = ["Message", "Bid", "Offer", "Purchases", "Saved Items"]
    var transCategoryArr : [TransCategory] = []
    var onItemSelected: ((Int) -> Void)?
    var selectedIndex: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
        self.categoryCollectionView.backgroundColor = .pearl
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        
        let cellIds = [CategoryRowCollectionViewCell.identifier]
        categoryCollectionView.registerCells(for: cellIds)
        categoryCollectionView.reloadData()
        categoryCollectionView.showsHorizontalScrollIndicator = false
        
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
    }
}

// MARK: - UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension CategoryTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if transCategoryArr.count != 0 || !transCategoryArr.isEmpty{
            return transCategoryArr.count
        }else{
            return categoryListArray.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: CategoryRowCollectionViewCell.self)
        if transCategoryArr.count != 0 || !transCategoryArr.isEmpty{
            cell.categoryLabel.text = transCategoryArr[indexPath.row].name
            if selectedIndex == indexPath.row{
                cell.outerStackView.backgroundColor = .secondary
            }else{
                cell.outerStackView.backgroundColor = .bg
            }
        }else{
            cell.categoryLabel.text = categoryListArray[indexPath.row]
            cell.outerStackView.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_05, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)

            if selectedIndex == indexPath.row {
                // Selected appearance
                cell.categoryLabel.textColor = AppColor.blue
                cell.categoryLabel.font = AppFont.Labeltitle
                cell.seprator.isHidden = false
            } else {
                cell.categoryLabel.textColor = AppColor.black
                cell.categoryLabel.font = AppFont.Labeltitle
                cell.seprator.isHidden = true
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if selectedIndex == indexPath.row {
            return // already selected
        }

        var indexPathsToReload: [IndexPath] = []
        if let previousIndex = selectedIndex {
            indexPathsToReload.append(IndexPath(row: previousIndex, section: 0))
        }
        selectedIndex = indexPath.row
        indexPathsToReload.append(indexPath)
        onItemSelected?(indexPath.row)
        collectionView.reloadItems(at: indexPathsToReload)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if transCategoryArr.count != 0 || !transCategoryArr.isEmpty{
            let text = transCategoryArr[indexPath.item].name
            let tempLabel = UILabel()
            tempLabel.numberOfLines = 0
            tempLabel.text = text
            tempLabel.font = UIFont.systemFont(ofSize: 17)
            let labelWidth = tempLabel.intrinsicContentSize.width + 32
            return CGSize(width: labelWidth, height: collectionView.frame.height)
        }else{
            let text = categoryListArray[indexPath.item]
            let tempLabel = UILabel()
            tempLabel.numberOfLines = 0
            tempLabel.text = text
            tempLabel.font = UIFont.systemFont(ofSize: 17)
            let labelWidth = tempLabel.intrinsicContentSize.width + 32
            return CGSize(width: labelWidth, height: collectionView.frame.height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}
