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
        // BUGFIX 2026-04-30 (MC task cmohlxj0h): use the real title array count
        // instead of a hard-coded 5. The parent (HomeViewController) sets `title`
        // from the live category feed, which is variable length; with the old
        // hard-coded 5 we would index past `title.count` and Swift would trap
        // (SIGTRAP brk 1) inside the cell's collection view as soon as the home
        // tab tried to render — exactly the post-sign-in crash on iOS 26.
        return title.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: CategoryRowCollectionViewCell.self, for: indexPath)
        // VISUAL PARITY 2026-05-01 (MC cmomwykts00233r1hcw317di3): match Android
        // home_category_tile.xml — selected tile uses warningAlt orange
        // (#ED8430) on a rectangular card, unselected tiles use a white card
        // with a hairline outline. Replaces the prior pill-shaped blue/secondary
        // selection so the home feed looks like android_feed.jpg.
        if selectedIndex == indexPath.row {
            cell.outerStackView.backgroundColor = UIColor(red: 0xED/255.0,
                                                          green: 0x84/255.0,
                                                          blue: 0x30/255.0,
                                                          alpha: 1.0)
            cell.outerStackView.layer.borderWidth = 0
            if let lbl = cell.categoryLabel {
                lbl.textColor = .white
                lbl.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            }
        } else {
            cell.outerStackView.backgroundColor = .white
            cell.outerStackView.layer.borderWidth = 1
            cell.outerStackView.layer.borderColor = UIColor(white: 0.90, alpha: 1.0).cgColor
            if let lbl = cell.categoryLabel {
                lbl.textColor = UIColor(white: 0.10, alpha: 1.0)
                lbl.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            }
        }
        // Defensive bounds check — should be unreachable now that
        // numberOfItemsInSection returns title.count, but keep it so a future
        // mismatch can't crash the app.
        if indexPath.row < title.count {
            cell.categoryLabel.text = title[indexPath.row]
        } else {
            cell.categoryLabel.text = ""
        }
        // Rectangular card (matches @drawable/home_category_tile_bg) instead
        // of the pill we used pre-port.
        cell.outerStackView.makeCornerRounded(ofSize: 12)
        cell.outerStackView.layer.masksToBounds = true
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // VISUAL PARITY 2026-05-01: shorter rectangular cards (matches Android
        // home_category_tile.xml ~64dp tall, three-up).
        return CGSize(width: self.collectionViewOlt.frame.width/2.4 - 20, height: 64)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didTapBtn(indexPath.row)
    }
}
