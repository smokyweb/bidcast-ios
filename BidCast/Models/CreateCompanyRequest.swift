//
//  CreateCompanyRequest.swift
// BidSwipe
//
//  Created by Ankit - JAM - E - 294 on 20/04/24.
//

import Foundation

struct CreateCompanyRequest: Encodable {
    var company_id: String
    var name: String
    var website_link: String
    var industry: String
    var address: String
    var phone: String
    var size: String
    var type: String
    var tag_line: String
    var logo: String
    var latitude : String?
    var longitude : String?
}

struct CreateUserRequest: Encodable {
    var user_name: String
}

struct CreateCompanyResponse: Codable {
//    var user_id: Int?
    var company_name: String?
    var company_website_link: String?
    var company_industry, company_address, company_phone, company_size: String?
    var company_type, company_logo, company_tag_line, updated_at,latitude,longitude: String?
    var created_at: String?
    var id: Int?
}
