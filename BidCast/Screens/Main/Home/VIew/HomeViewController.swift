//
//  HomeViewController.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 06/05/25.
//

import UIKit

class HomeViewController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var headerViewolt: HeaderWithAppName!
    @IBOutlet weak var collectionViewOlt: UICollectionView!
    
    //MARK: Properties
    
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureHeaderView()
    }
    
    func configureHeaderView(){
        self.headerViewolt.headerViewSetup(rightButtonHidden: false,leftButtonHidden: false , headerName: "")
    }
    

}
