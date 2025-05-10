//
//  SignUpModel.swift
//  BidCast
//
//  Created by JAM-E-329 on 06/05/25
//

// MARK: - SignUpDataModel
struct SignUpDataModel: Codable {
    var firstName, lastName, name: String?
    var roleID: Int?
    var email: String?
    var id: Int?
    var token: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case name
        case roleID = "role_id"
        case email, id, token
    }
}


//MARK: ResetPasswordModel
struct ResetPasswordModel:Codable {
    
}

