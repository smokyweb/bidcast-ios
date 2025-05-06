//
//  ProductCollectionViewCell.swift
//  Well Genius App
//
//  Created by Vivek-JAM-E-328 on 30/12/24.
//

import UIKit

class ProductCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var productImgView: UIImageView!
    @IBOutlet weak var lblStackView: UIStackView!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var productPriceLbl: UILabel!
    
    static let identifier = "ProductCollectionViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        innerView.backgroundColor = .white
//        self.productNameLbl.setupLabel(title: "Product Name", fontSize: AppFont.labelBold)
//        self.productPriceLbl.setupLabel(title: "$999.99", fontSize: AppFont.label)
//        self.productImgView.image = UIImage(named: "solar-panel")
    }
    
//    func configureCell(with product: CGetShopProduct?) {
//        if let productImages = product?.productImages, !productImages.isEmpty,
//            let img = productImages.first?.productImg{
//            Utilities.sharedInstance.setImageWithUrl(imgStr: img, imgView: productImgView)
//        }
////        else  {
////            productImgView.image =  UIImage(named: "solar-panel")
////        }
//        
//        productNameLbl.text = product?.name ?? "Product Name"
//        productPriceLbl.text = product?.price ??  "$999.99"
//        innerView.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_05, shadowColor: AppColor.black ?? UIColor.black)
//        lblStackView.backgroundColor = .white
//    }
    
    
    func configureCell() {
//        if let productImages = product?.productImages, !productImages.isEmpty,
//            let img = productImages.first?.productImg{
//            Utilities.sharedInstance.setImageWithUrl(imgStr: img, imgView: productImgView)
//        }
////        else  {
            productImgView.image =  UIImage(named: "solar-panel")
//        }
        
//        productNameLbl.text = product?.name ?? "Product Name"
//        productPriceLbl.text = product?.price ??  "$999.99"
        productNameLbl.text = "Product Name"
        productPriceLbl.text = "$999.99"
        innerView.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_05, shadowColor: AppColor.black ?? UIColor.black)
//        lblStackView.backgroundColor = .ghostWhite
    }
    
//    func configureCell(with product: GetHGProduct?) {
//        if let productImages = product?.productImages, !productImages.isEmpty,
//            let img = productImages.first?.productImg{
//            Utilities.sharedInstance.setImageWithUrl(imgStr: img, imgView: productImgView)
//        }
//        else  {
//            productImgView.image =  UIImage(named: "solar-panel")
//        }
//        
//        productNameLbl.text = product?.name ?? "Product Name"
//        productPriceLbl.text = product?.price ??  "$999.99"
//        innerView.dropShadow(opacity: 0.5, shadowRadius: Radius_04, cornerRadius: Corner_05, shadowColor: AppColor.black ?? UIColor.black)
//        lblStackView.backgroundColor = .ghostWhite
//    }

}
