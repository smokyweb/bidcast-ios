//
//  UICollectionView+Extension.swift
//  BidCast
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
    /// Legacy callsites that don't pass an indexPath. Internally synthesises
    /// a placeholder, but iOS 26 / Xcode 26.4 traps when the dequeue index
    /// path doesn't match the index path UIKit asked the data source to
    /// render. Prefer the `dequeueCell(ofType:for:)` overload below.
    func dequeueCell<T: UICollectionViewCell>(ofType cellType: T.Type) -> T {
        let identifier = String(describing: cellType)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: IndexPath(item: 0, section: 0)) as? T else {
            fatalError("Could not dequeue cell with identifier: \(identifier)")
        }
        return cell
    }

    /// Bug fix 2026-04-30 (MC task cmohlxj0h): the legacy `dequeueCell(ofType:)`
    /// always passed `IndexPath(0,0)`, which traps under iOS 26 / Xcode 26.4
    /// once UIKit's update cycle creates cells outside that index path.
    /// Always call this overload from `cellForItemAt:` so the dequeue indexPath
    /// matches the real one.
    func dequeueCell<T: UICollectionViewCell>(ofType cellType: T.Type, for indexPath: IndexPath) -> T {
        let identifier = String(describing: cellType)
        guard let cell = dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(identifier) at \(indexPath)")
        }
        return cell
    }
}
