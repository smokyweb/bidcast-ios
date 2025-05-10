//
//  SignInModel.swift
//  BidCast
//
//  Created by Vivek-JAM-E-328 on 31/08/24.
//


// MARK: - SignInDataModel
struct SignInDataModel: Codable {
    var id, roleID: Int?
    var firstName, lastName, name, email: String?
    var profileImage: String?
    var token: String
    var role: RoleData?

    enum CodingKeys: String, CodingKey {
        case id
        case roleID = "role_id"
        case firstName = "first_name"
        case lastName = "last_name"
        case name, email
        case profileImage = "profile_image"
        case token, role
    }
}

// MARK: - RoleData
struct RoleData: Codable {
    var id: Int?
    var name: String?
    var createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}


// MARK: - Subscription
struct SubscriptionData: Codable {
    var purchaseToken, original_transaction_id, subscription_status,expires_date_pst,subscription_type,is_expired,platform: String?
}






