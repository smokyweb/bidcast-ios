//
//  BlockedUserListModel.swift
//  BidCast
//
//  Created by JAM-E-329 on 13/08/25.
//

import Foundation


// MARK: - BlockedUserList
struct BlockedUserList: Codable {
    var blockedByMe, blockedMe: [BlockedByUserList]?
    
    enum CodingKeys: String, CodingKey {
        case blockedByMe = "blocked_by_me"
        case blockedMe = "blocked_me"
    }
}

// MARK: - BlockedByUserList
struct BlockedByUserList: Codable {
    var id: Int?
    var name: String?
    var image: String?
}


