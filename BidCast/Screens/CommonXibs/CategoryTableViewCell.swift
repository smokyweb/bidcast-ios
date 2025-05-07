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

    var categoryListArray = ["Message","Bid","Offer","Purchases","Saved Items"]
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configure()
        self.categoryCollectionView.backgroundColor = .pearl
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(){
        self.categoryCollectionView.delegate = self
        self.categoryCollectionView.dataSource =  self
        
        let cellIds = [CategoryRowCollectionViewCell.identifier
                       ]
        categoryCollectionView.registerCells(for: cellIds)
        self.categoryCollectionView.reloadData()
        self.categoryCollectionView.showsHorizontalScrollIndicator = false
        
        // Set the layout for the collection view
        if let layout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 0 // Space between items
            layout.minimumLineSpacing = 0 // Space between rows
        }
    }
}


//MARK: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout.
extension CategoryTableViewCell : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if categoryListArray.isEmpty {
            return 0 // Return 1 when there are no images
        } else {
            return categoryListArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !categoryListArray.isEmpty {
            let cell = collectionView.dequeueCell(ofType: CategoryRowCollectionViewCell.self)
            cell.categoryLabel.text = categoryListArray[indexPath.row]
            cell.outerStackView.layer.borderWidth = 1.0
            cell.outerStackView.backgroundColor = .white
            cell.outerStackView.layer.borderColor = UIColor.primary.cgColor
            cell.outerStackView.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_05, shadowColor: AppColor.Label.SquirrelGrey ?? UIColor.squirrelGrey)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle item selection if needed
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    // Size for each item (3 images per row, fixed height 150)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var text = "Category Name"
        if indexPath.item < categoryListArray.count {
            let category = categoryListArray[indexPath.item]
            text = category
        }
        // Create a temporary label to calculate the size
        let tempLabel = UILabel()
        tempLabel.numberOfLines = 0
        tempLabel.text = text
        tempLabel.font = UIFont.systemFont(ofSize: 17)
        
        // Calculate the intrinsic content size of the label
        let labelWidth = tempLabel.intrinsicContentSize.width + 32  // Add padding for space around text
        
        // Return the size of the cell
        return CGSize(width: labelWidth, height: collectionView.frame.height)
    }
    
    // Optional: Adjust the section inset to give padding around the items
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    // Optional: Adjust line spacing (space between rows)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    // Optional: Adjust inter-item spacing (space between items in a row)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

