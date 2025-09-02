//
//  PromoteShowModel.swift
//  BidCast
//
//  Created by JAM_E_329 on 19/05/25.
//

import Foundation

// MARK: - PromoteToolModel
struct PromoteToolModel: Codable {
    var id: Int?
    var showIcon: String?
    var showTitle, showDetails: String?
    var showOptions: ShowOptionsModel?
    var features: [Feature]?
    var promoteTitle, promoteDetails: String?

    enum CodingKeys: String, CodingKey {
        case id
        case showIcon = "show_icon"
        case showTitle = "show_title"
        case showDetails = "show_details"
        case showOptions = "show_options"
        case features
        case promoteTitle = "promote_title"
        case promoteDetails = "promote_details"
    }
}


// MARK: - ShowOptionsModel
struct ShowOptionsModel: Codable {
    var shows, views, followers: Int?

    enum CodingKeys: String, CodingKey {
        case shows = "Shows"
        case views = "Views"
        case followers = "Followers"
    }
}
