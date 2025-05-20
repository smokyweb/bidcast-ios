//
//  LinkedInStatusModel.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 06/03/24.
//

import Foundation

struct LinkedInDataResponse: Codable {
    var login: UserDetailModal?
    var signup: LinkedInStatusModel?
}

struct LinkedInLinkModel: Codable {
    var code: String
}

struct CreateEventParam: Codable {
    var code: String
}

struct LinkedInStatusModel: Codable {
    var sub: String?
    var email_verified: Bool?
    var name, given_name, family_name: String?
    var email: String?
    var locale: LocaleModel?
    var linkedin_access: LinkedInAccessModel?
    
    var id: Int?
    var first_name: String?
    var last_name: String?
    var role_id: String?
    var location: String?
    var profile_image: String?
    var video_resume: String?
    var created_at: String?
    var token: String?
    var user_role: String?
}

struct LocaleModel: Codable {
    var country, language: String?
}

struct LinkedInAccessModel: Codable {
    var access_token: String?
    var expires_in: Int?
    var scope: String?
    var token_type, id_token: String?
}
