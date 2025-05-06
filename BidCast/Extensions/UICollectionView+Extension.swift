//
//  UICollectionView+Extension.swift
//  Rise Shine Swing
//
//  Created by Vivek-JAM-E-328 on 10/12/24.
//

import Foundation
import UIKit

extension UICollectionView {
    func registerCells(for cellIds: [String]) {
        for cellId in cellIds {
            let tableCell = UINib(nibName: "\(cellId)", bundle: nil)
            self.register(tableCell, forCellWithReuseIdentifier: "\(cellId)")
        }
    }
    func dequeueCell<T: UICollectionViewCell>(ofType cellType: T.Type) -> T {
        let identifier = String(describing: cellType)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: 0, section: 0)) as? T else {
            fatalError("Could not dequeue cell with identifier: \(identifier)")
        }
        return cell
    }
}
