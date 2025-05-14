//
//  BundleEx.swift
//  BidCast
//
//  Created by JAM_E_329 on 14/05/25.
//

import Foundation

private var bundleKey: UInt8 = 0

class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        guard let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle else {
            return super.localizedString(forKey: key, value: value, table: tableName)
        }
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, BundleEx.self)
        }
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj"),
              let langBundle = Bundle(path: path) else {
            return
        }
        objc_setAssociatedObject(Bundle.main, &bundleKey, langBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
