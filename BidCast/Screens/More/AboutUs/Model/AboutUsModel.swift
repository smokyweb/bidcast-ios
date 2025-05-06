//
//  AboutUsModel.swift
//  BidCast App
//
//  Created by JAM-E-329 on 06/05/25. on 27/12/24.
//

import Foundation


// MARK: - AboutUsModel
struct AboutUsModel: Codable {
    var id: Int?
    var pageName, pageURL, pageContent: String?
    var images: [String]?
    var createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case pageName = "page_name"
        case pageURL = "page_url"
        case pageContent = "page_content"
        case images
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
