//
//  SegmentCell.swift
//  Well Genius App
//
//  Created by jam 1 TB on 19/12/24.
//

import UIKit

class SegmentCell: UITableViewCell {
    
    @IBOutlet var segment: HBSegmentedControl!
    
    static let identifier = "SegmentCell"
    var selectedIndex: Int = 0
    var isNavFrom : String?

    // Define a closure property
    var onSegmentChanged: ((Int) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupforsegmentControl()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    // MARK: setupforsegmentControl
    func setupforsegmentControl() {
        if isNavFrom == "InventoryVC"{
            segment.items = ["Active", "Draft","Inactive"]
        }else if isNavFrom == "MyAccountVC"{
            segment.items = ["Seller Hub", "My Account"]
        }
       
        segment.font  = AppFont.Labeltitle
        segment.backgroundColor = AppColor.Segment.whiteFrost
        segment.selectedLabelColor = .black
        segment.unselectedLabelColor = .darkGray
        segment.thumbColor = .white
        segment.selectedIndex = selectedIndex
        segment.padding = 6
        segment.makeCornerRounded(ofSize: Corner_08)
        
        // Add target for value change
        segment.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
    }
    
    @objc private func segmentValueChanged(_ sender: HBSegmentedControl) {
        // Call the closure when the segment value changes
        onSegmentChanged?(sender.selectedIndex)
        selectedIndex = sender.selectedIndex
    }
}
