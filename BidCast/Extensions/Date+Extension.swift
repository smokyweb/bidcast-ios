//
//  Date+Extension.swift
//  BidCast
//
//  Created by Vivek-JAM-E-328 on 03/10/24.
//

import Foundation

extension Date {
   func getFormattedDate(format: String) -> String {
        let dateformat = DateFormatter()
        dateformat.dateFormat = format
        return dateformat.string(from: self)
    }
}
