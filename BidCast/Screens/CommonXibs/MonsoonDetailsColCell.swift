//
//  MonsoonDetailsColCell.swift
//  Rise Shine Swing
//
//  Created by JAM_E_329 on 02/05/25.
//

import UIKit

class MonsoonDetailsColCell: UICollectionViewCell {
    
    // MARK: Properties
    static let identifier = "MonsoonDetailsColCell"

    @IBOutlet var lblKey: UILabel!
    @IBOutlet var lblValue: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        lblKey.font = AppFont.Labeltitle
        lblValue.font = AppFont.Labeltitle
    }

}
