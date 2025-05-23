//
//  QualificationResponse.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 05/02/24.
//

import Foundation

struct QualificationResponse: Codable {
    var name: String
    var order: String?
    var id: Int
}

struct SalaryTypeResponse: Codable {
    var id: Int?
    var type: String?
}
