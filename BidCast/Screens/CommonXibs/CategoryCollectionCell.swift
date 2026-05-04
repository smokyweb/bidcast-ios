//
//  CategoryCollectionCell.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 07/05/25.
//
//  VISUAL PARITY 2026-05-04 (MC cmomx4f1k002c3r1hggx47mks):
//  Replaced the legacy label-only `CategoryRowCollectionViewCell` with a
//  programmatic `HomeCategoryTileCell`. The Android home rail renders three
//  distinct tile types (For You / Category / See All) — see
//  `home_category_tile.xml` + `HomeCategoryAdapter.kt`. The iOS version was
//  rendering pill-shaped tiles with text only, which is what Trey flagged
//  as "still not matching Android". This cell now owns the typed tile list
//  so the parent (`HomeViewController`) can pass structured data
//  (`HomeCategoryTile`) instead of a flat string array.
//

import UIKit

class CategoryCollectionCell: UICollectionViewCell {

    static  let identifier = "CategoryCollectionCell"

    /// Typed tile model — mirrors Android's `CategoryTile`. Set by
    /// `HomeViewController` and renders the For You / category /
    /// See All Categories cards in order.
    var tiles: [HomeCategoryTile] = []

    @IBOutlet weak var collectionViewOlt: UICollectionView!
    @IBOutlet weak var outerViewOlt: UIView!

    var didTapBtn : (Int) -> () = {_ in }
    var selectedIndex = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        configureCollectionVIew()
    }

    func configureCollectionVIew(){
        // Programmatic cell — register by class, not nib.
        self.collectionViewOlt.register(
            HomeCategoryTileCell.self,
            forCellWithReuseIdentifier: HomeCategoryTileCell.identifier
        )
        self.collectionViewOlt.delegate = self
        self.collectionViewOlt.dataSource = self
        self.collectionViewOlt.backgroundColor = .clear
        self.outerViewOlt?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.backgroundColor = .clear
        // Match Android's horizontal recycler layout — left-padded so the
        // first tile aligns with the body content above.
        if let flow = self.collectionViewOlt.collectionViewLayout as? UICollectionViewFlowLayout {
            flow.scrollDirection = .horizontal
            flow.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        self.collectionViewOlt.showsHorizontalScrollIndicator = false
    }
}

extension CategoryCollectionCell : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tiles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: HomeCategoryTileCell.self, for: indexPath)
        guard indexPath.item < tiles.count else {
            return cell
        }
        let tile = tiles[indexPath.item]
        cell.configure(with: tile, selected: indexPath.item == selectedIndex)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Android: 90dp wide × 100dp tall card.
        return CGSize(width: 90, height: 90)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.didTapBtn(indexPath.row)
    }
}
