//
//  UITableView+Extension.swift
//  Rise Shine Swing
//
//  Created by Vivek-JAM-E-328 on 18/09/24.
//

import Foundation
import UIKit

extension UITableView {
    func registerCells(for cellIds: [String]) {
        for cellId in cellIds {
            let tableCell = UINib(nibName: "\(cellId)", bundle: nil)
            self.register(tableCell, forCellReuseIdentifier: "\(cellId)")
        }
    }
    func dequeueCell<T: UITableViewCell>(with cellType: T.Type) -> T {
        let identifier = String(describing: cellType)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
    func configTblView(rowHeight: CGFloat = UITableView.automaticDimension, estimatedRowHeight: CGFloat = 85.0, separatorStyle: UITableViewCell.SeparatorStyle = .none, showsVerticalScrollIndicator: Bool = false,bgColor : UIColor = .ultraLightGray) {
        
        // Configure row height and estimated row height
        self.rowHeight = rowHeight
        self.estimatedRowHeight = estimatedRowHeight
        
        self.bounces = false
        
        // Configure separator style
        self.separatorStyle = separatorStyle
        
        // Configure vertical scroll indicator visibility
        self.showsVerticalScrollIndicator = showsVerticalScrollIndicator
        
        // Set background color
        self.backgroundColor = bgColor
    }
}

extension UITableView {
    func scrollToBottomRow() {
        DispatchQueue.main.async {
            guard self.numberOfSections > 0 else { return }

            // Make an attempt to use the bottom-most section with at least one row
            var section = max(self.numberOfSections - 1, 0)
            var row = max(self.numberOfRows(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)

            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            while !self.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(self.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)

                // If we're down to the last section, attempt to use the first row
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }

            // In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
            // exception here
            guard self.indexPathIsValid(indexPath) else { return }

            self.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }

    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return section < self.numberOfSections && row < self.numberOfRows(inSection: section)
    }
}

//MARK: - Reload Data
extension UITableView {
    func reloadRow(for row: Int, section: Int = 0) {
        DispatchQueue.main.async {
            let indexPosition = IndexPath(row: row, section: section)
            self.reloadRows(at: [indexPosition], with: .automatic)
        }
    }
    
    func reload() {
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
}
