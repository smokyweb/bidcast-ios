//  BidCast
//
//  Created by Abdul-JAM-E-157 on 31/08/24.

import Foundation
import UIKit

protocol NextDelegate:AnyObject {
    func next()
}

var nextDelegate:NextDelegate?

extension UITableView{
    
    func setEmptyView(message: String) {
        let noResultView = UINib(nibName: "EmptyCustomView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! EmptyCustomView
        noResultView.noOrdersLbl.text = message
        self.backgroundView = noResultView
    }
//    
//    func setEmptyView2(message: String) {
//        let noResultView = UINib(nibName: "EmptyCustomView2", bundle: nil).instantiate(withOwner: nil, options: nil).first as! EmptyCustomView2
//        noResultView.nextBtn.setTitle(message, for: .normal)
//        noResultView.nextBtn.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
//        self.backgroundView = noResultView
//    }
    
    @objc func nextAction(_ sender:UIButton){
        nextDelegate?.next()
    }
    
    func reloadDataWithAutoSizingCellWorkAround() {
           self.reloadData()
           self.setNeedsLayout()
           self.layoutIfNeeded()
           self.reloadData()
       }
}

extension UICollectionView{
    
    func setEmptyView(message: String) {
        let noResultView = UINib(nibName: "EmptyCustomView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! EmptyCustomView
        noResultView.noOrdersLbl.text = message
        self.backgroundView = noResultView
    }
//
//    func setEmptyView2(message: String) {
//        let noResultView = UINib(nibName: "EmptyCustomView2", bundle: nil).instantiate(withOwner: nil, options: nil).first as! EmptyCustomView2
//        noResultView.nextBtn.setTitle(message, for: .normal)
//        noResultView.nextBtn.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
//        self.backgroundView = noResultView
//    }
    
    @objc func nextAction(_ sender:UIButton){
        nextDelegate?.next()
    }
    func reloadCollectionDataWithAutoSizingCellWorkAround() {
        self.reloadData()
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.reloadData()
    }
}


