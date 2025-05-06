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
    private func setupforsegmentControl() {
        segment.items = ["SIGN IN", "SIGN UP"]
        segment.font  = AppFont.Labeltitle
        segment.backgroundColor = AppColor.lightGray
        segment.borderColor = .clear
        segment.selectedLabelColor = .white
        segment.unselectedLabelColor = AppColor.darkGray ?? .darkGray
        segment.thumbColor = AppColor.primary ?? .primary
        segment.selectedIndex = 0
        segment.padding = 6
        // Add target for value change
        segment.addTarget(self, action: #selector(segmentValueChanged(_:)), for: .valueChanged)
    
    }
    
    @objc private func segmentValueChanged(_ sender: HBSegmentedControl) {
        // Call the closure when the segment value changes
        onSegmentChanged?(sender.selectedIndex)
    }
}
