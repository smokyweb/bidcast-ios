//
//  NewPasswordModel.swift
//  BidCast
//
//  Created by Vivek-JAM-E-328 on 05/09/24.
//


import Foundation

// MARK: - UpdatePasswordModel
struct UpdatePasswordModel: Codable {
    var id, roleID: Int?
    var firstName, lastName, name, email: String?
    var username: String?
    var zipCode: Int?
    var profileImage: String?
    var emailVerifiedAt: String?
    var zoneID: Int?
    var createdAt, updatedAt: String?
    var deletedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case roleID = "role_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case name, email, username
        case zipCode = "zip_code"
        case profileImage = "profile_image"
        case emailVerifiedAt = "email_verified_at"
        case zoneID = "zone_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case deletedAt = "deleted_at"
    }
}
