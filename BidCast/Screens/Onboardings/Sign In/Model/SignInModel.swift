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
    var username: String?
    var zipCode: Int?
    var profileImage, emailVerifiedAt: String?
    var zoneID: Int?
    var createdAt, updatedAt: String?
    var deletedAt: String?
    var token: String
    var isSubscribed: Bool?
    var subscription: SubscriptionData?
    var role: RoleData?

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
        case token
        case isSubscribed = "is_subscribed"
        case subscription, role
    }
}

// MARK: - Role
struct RoleData: Codable {
    var id: Int?
    var name, createdAt, updatedAt: String?

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






