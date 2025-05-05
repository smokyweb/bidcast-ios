//
//  UIApplication+Extension.swift
//  imperium
//
//  Created by JAM-E-282 on 19/01/24.
//

import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
