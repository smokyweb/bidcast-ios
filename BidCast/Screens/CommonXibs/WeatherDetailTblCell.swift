//
//  WeatherDetailTblCell.swift
//  BidCast
//
//  Created by JAM_E_329 on 02/05/25.
//

import UIKit

class WeatherDetailTblCell: UITableViewCell {

    @IBOutlet var roadMainView: UIView!
    @IBOutlet var roadDetailLbl: UILabel!
    @IBOutlet var roadImg: UIImageView!
    @IBOutlet var dotViewTemp: UIView!
    @IBOutlet var feelsLikeLbl: UILabel!
    @IBOutlet var weatherName: UILabel!
    @IBOutlet var temperatureLbl: UILabel!
    @IBOutlet var weatherImgOlt: UIImageView!
    @IBOutlet var dotView: UIView!
    @IBOutlet var temperatureValueLbl: UILabel!
    @IBOutlet var colView: UICollectionView!
    @IBOutlet var keyValueOne: UILabel!
    @IBOutlet var keyValuetwo: UILabel!
    @IBOutlet var keyValueFour: UILabel!
    @IBOutlet var keyValueThree: UILabel!
    @IBOutlet var valueOne: UILabel!
    @IBOutlet var valueTwo: UILabel!
    @IBOutlet var valueFour: UILabel!
    @IBOutlet var valueThree: UILabel!
    
    static let identifier = "WeatherDetailTblCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colView.delegate = self
        colView.dataSource = self
        let cellIds = [MonsoonDetailsColCell.identifier]
        colView.registerCells(for: cellIds)
        self.colView.reloadData()
        self.colView.showsHorizontalScrollIndicator = false
        roadMainView.makeCornerRounded(ofSize: Corner_02)
        weatherImgOlt.makeCornerRounded(ofSize: Corner_12)
        temperatureLbl.font = OutFitFont.defaultBold(size: 66).value
        weatherName.font =  OutFitFont.defaultBold(size: 26).value
        feelsLikeLbl.font = AppFont.mediumTitle
        temperatureValueLbl.font = AppFont.mediumTitle
        roadDetailLbl.font =  AppFont.mediumTitle
        valueOne.font =  AppFont.Labeltitle
        valueTwo.font =  AppFont.Labeltitle
        valueThree.font =  AppFont.Labeltitle
        valueFour.font =  AppFont.Labeltitle
        keyValueOne.font =  AppFont.mediumTitle
        keyValuetwo.font =  AppFont.mediumTitle
        keyValueThree.font =  AppFont.mediumTitle
        keyValueFour.font =  AppFont.mediumTitle
        dotViewTemp.makeCircular()
        dotView.makeCircular()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}


//MARK: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout.
extension WeatherDetailTblCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MonsoonDetailsColCell.identifier, for: indexPath) as! MonsoonDetailsColCell
//        cell.lblKey.text =
//        cell.lblValue.text =
        return cell
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 4, height: collectionView.frame.height)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}


