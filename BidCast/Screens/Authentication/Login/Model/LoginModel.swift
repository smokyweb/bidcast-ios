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

struct RoleData: Codable {
    var id: Int?
    var name: String?
    var updated_at : String?
    
    var created_at : String?
}
