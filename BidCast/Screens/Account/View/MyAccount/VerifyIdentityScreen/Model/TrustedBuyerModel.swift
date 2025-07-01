//
//  TrustedBuyerModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 10/06/25.
//

import Foundation

struct TrustedBuyerModel: Codable {
    var id, userID: Int?
    var image: String?
    var status: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case image, status
    }
}
