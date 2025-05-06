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
    var email, zipCode, updatedAt, createdAt: String?
    var id: Int?
    var token: String?

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case name
        case roleID = "role_id"
        case email
        case zipCode = "zip_code"
        case updatedAt = "updated_at"
        case createdAt = "created_at"
        case id, token
    }
}

//MARK: ResetPasswordModel
struct ResetPasswordModel:Codable {
    
}

