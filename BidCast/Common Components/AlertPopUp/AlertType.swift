//
//  AlertType.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 23/01/24.
//

import Foundation

enum AlertType {
    
    case success(title: String, message: String = "", leftBtnText: String = "", rightBtnText: String = "")
    case error(title: String, message: String = "", leftBtnText: String = "", rightBtnText: String = "")
    
    func title() -> String {
        switch self {
            case .success(title: let title, _, _, _):
                return title
            case .error(title: let title, _, _, _):
                return title
        }
    }
    
    func message() -> String {
        switch self {
            case .success(_, message: let message, _, _):
                return message
            case .error(_, message: let message, _, _):
                return message
        }
    }
    
        /// Left button action text for the alert view
    var leftActionText: String {
        switch self {
            case .success(_, _, let leftBtnText, _):
                return leftBtnText
            case .error(_, _, let leftBtnText, _):
                return leftBtnText
        }
    }
    
        /// Right button action text for the alert view
    var rightActionText: String {
        switch self {
            case .success(_, _, _, let rightBtnText):
                return rightBtnText
            case .error(_, _, _, let rightBtnText):
                return rightBtnText
        }
    }
    
    func height(isShowVerticalButtons: Bool = false) -> CGFloat {
        switch self {
            case .success:
                return isShowVerticalButtons ? 220 : 150
            case .error:
                return isShowVerticalButtons ? 220 : 150
        }
    }
}
