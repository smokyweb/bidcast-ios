//
//  ShowsModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - GetAgoraModel
struct GetAgoraModel: Codable {
    var status, channel: String?
    var uid: Int?
    var token: String?
    var expiresAt: Int?

    enum CodingKeys: String, CodingKey {
        case status, channel, uid, token
        case expiresAt = "expires_at"
    }
}
