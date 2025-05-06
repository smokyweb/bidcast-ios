//
//  ProfileModel.swift
//  Rise Shine Swing App
//
//  Created by JAM-E-329 on 10/01/25.
//

import Foundation
import UIKit

struct EditProfileModel : Codable{
    var first_name : String?
    var last_name : String?
    var zip_code: Int?
    var image : String?
}

struct ProfileDataModel: Codable{
    var id, roleID,zip_code: Int?
    var firstName, lastName, name, email,profile_image: String?
    var phone, address,email_verified_at: String?
    var createdAt, updatedAt, token,deleted_at: String?
    var role: RoleData?
    
    enum CodingKeys: String, CodingKey {
        case id
        case zip_code
        case email_verified_at
        case profile_image
        case deleted_at
        case roleID = "role_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case name, email, phone, address
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case token, role
    }
}


