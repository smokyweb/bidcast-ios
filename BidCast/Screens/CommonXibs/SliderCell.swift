//
//  SliderCell.swift
//  BidCast
//
//  Created by JAM-E-221 on 04/09/24.
//

import UIKit
import CHIPageControl

class SliderCell: UITableViewCell {
    
    //MARK: IBOutlets.
    @IBOutlet weak var outerViewOlt: UIView!
    
    @IBOutlet var btnSlider: UIButton!
    @IBOutlet weak var collectionViewOlt: UICollectionView!
    @IBOutlet weak var pageController: CHIPageControlJaloro!
    @IBOutlet weak var pageControlHeightConstarint: NSLayoutConstraint!
    
    //MARK: properties.
    static let identifier = "SliderCell"
    var Index = 0
    var spacing  : CGFloat = 20.0
    var imgArr : [String]?
    var totalImage = 1.0
    
    //MARK: - Initilizations
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configure()
    }
    
    //MARK: configure.
    func configure(){
        self.collectionViewOlt.delegate = self
        self.collectionViewOlt.dataSource =  self
        let cellIds = [ImagesCollectionViewCell.identifier,NoDataTableViewCell.identifier]
        collectionViewOlt.registerCells(for: cellIds)
        self.collectionViewOlt.reloadData()
        self.collectionViewOlt.showsHorizontalScrollIndicator = false
        pageController.numberOfPages = 4
        pageController.radius = 4
        pageController.tintColor = .mediumLightGray
        pageController.currentPageTintColor = .primary
        pageController.padding = 6
        pageController.borderWidth = 0.0
        pageController.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        
    }
    
    @IBAction func btnTappedSlider(_ sender: UIButton) {
    }
    
    //MARK: pageControlTapped.
    @objc func pageControlTapped(_ sender: CHIBasePageControl) {
        let pageIndex = sender.progress
        let indexPath = IndexPath(item: Int(pageIndex * totalImage), section: 0) // Use scaled index
        collectionViewOlt.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

//MARK: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout.
extension SliderCell : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if imgArr == nil || imgArr!.isEmpty {
            pageController.numberOfPages = 1
            return 2 // Return 1 when there are no images
        } else {
            let numberOfPages = CGFloat(imgArr?.count ?? 0) / totalImage
            pageController.numberOfPages = Int(ceil(numberOfPages))
            return imgArr?.count ?? 0
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
//        let cell = collectionViewOlt.dequeueCell(ofType: ImagesCollectionViewCell.self)
//        cell.profileImage.image = UIImage(named: arrImg[indexPath.row])
//        cell.profileImage.makeCornerRounded(ofSize: Corner_12)
//        cell.profileImage.addBorders(of: .black, width: Width_01)
//        return cell
        
        //TODO: Uncomment Code when fetch from server
        
        if imgArr == nil || imgArr!.isEmpty {
        let cell = collectionViewOlt.dequeueCell(ofType: ImagesCollectionViewCell.self)
        cell.profileImage.image = UIImage(named: "image1")
        return cell
        } else {
            let cell = collectionViewOlt.dequeueCell(ofType: ImagesCollectionViewCell.self)
            Utilities.sharedInstance.setImageWithUrl(imgStr: imgArr?[indexPath.row].addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "", imgView: cell.profileImage)
            
            return cell
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let itemWidth = collectionViewOlt.bounds.width / totalImage  // Width of 1.5 items per row
        let pageIndex = round(scrollView.contentOffset.x / itemWidth) // Adjust for 1.5 items per row
        self.Index = Int(pageIndex)
        pageController.set(progress: Int(pageIndex), animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 40 // Total padding (left + right)
        let itemsPerRow: CGFloat = totalImage
        let totalSpacing = (itemsPerRow - 1) * spacing // Space between items

        let width = (collectionView.frame.width - padding - totalSpacing) / itemsPerRow
        let height: CGFloat = 300
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
    
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionViewOlt.frame.width / 1.5 - 10 , height: collectionViewOlt.frame.width/1.5 - 10)
//    }
}
