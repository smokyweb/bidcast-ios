//
//  addSongButtonFooterView.swift
//  Rise Shine Swing
//
//  Created by JAM_E_329 on 28/12/24.
//

import UIKit

class addSongButtonFooterView: UITableViewHeaderFooterView {
    
    @IBOutlet var outerView: UIView!
    @IBOutlet var addSongBtn: UIButton!
    @IBOutlet var addSubscription: UIButton!
    
    var didTapSum : (UIButton) -> () = {_ in}
    var didTapSubscription : (UIButton) -> () = {_ in}
    
    //MARK: IBAction.
    @IBAction func didTap(_ sender: UIButton) {
        self.didTapSum(sender)
    }
    
    @IBAction func addSubscription(_ sender: UIButton) {
        self.didTapSubscription(sender)
    }
}
