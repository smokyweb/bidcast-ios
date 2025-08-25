//
//  BlockedUserListModel.swift
//  BidCast
//
//  Created by JAM-E-329 on 13/08/25.
//

import Foundation

struct BlockedUserList : Codable{
    var status: Bool?
    var data : [BlockedByUserList]?
}

struct BlockedByUserList : Codable{
    var id: Int?
    var name: String?
   //var
}


