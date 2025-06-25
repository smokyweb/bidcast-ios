//
//  SignUpModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 12/05/25.
//

import Foundation

struct LoginModel : Codable {
    var id: Int?
    var name: String?
    var first_name: String?
    var last_name: String?
    var email: String?
    var role_id: Int?
    var token : String?
    var is_first_login : Int?
    var profile_image: String?
    var roles: RoleData?
}

// MARK: - DeviceDetailModal
struct DeviceDetailModal : Codable {
    var id, userID: Int?
    var deviceToken, platform, appVersion, isUserLoggedin: String?
    var timeZone, createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case userID = "user_id"
        case deviceToken = "device_token"
        case platform
        case appVersion = "app_version"
        case isUserLoggedin = "is_user_loggedin"
        case timeZone = "time_zone"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct RoleData: Codable {
    var id: Int?
    var name: String?
    var updated_at : String?
    
    var created_at : String?
}
