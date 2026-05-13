//  SharedTypes.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Types that appear in MANY Android response DTOs as nested `data class`
//  siblings (Category, SubCategory, UserPublic, ShippingAddress, etc.).
//  Android redeclares them on every response file; on iOS we define them
//  once here and reference them from the domain-specific response files
//  to keep the codebase DRY.
//
//  QA-NOTE: If a specific endpoint's nested type has a divergent shape
//  (extra fields / missing fields), the domain file should declare its
//  own local type with the endpoint-specific fields rather than widening
//  this shared one.

import Foundation

// MARK: - Category / SubCategory (shared across Product, Show, Order, Offer, ...)
// BUGFIX 2026-05-13 (MC cmp4936yl00m93mx1pjyhcegi): Android-originated live-show
// payloads can carry mixed-shape nested fields (notably category extra_fields and
// user bio). Keep the public Swift surface area stable, but decode those fields
// leniently so the live-show viewer does not fail with “The data couldn’t be read
// because it isn’t in the correct format.” when iOS joins an Android seller show.

struct Category: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let image: String?
    let thumbnail: AnyCodable?    // Android mixes String and Any here
    let color: String?
    let extraFields: [CategoryExtraField]?
    let deletedAt: AnyCodable?
    var isSelected: Bool?
    var liveCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, name, image, thumbnail, color
        case extraFields = "extra_fields"
        case deletedAt = "deleted_at"
        case isSelected = "is_selected"
        case liveCount
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        image = try c.decodeIfPresent(String.self, forKey: .image)
        thumbnail = try c.decodeIfPresent(AnyCodable.self, forKey: .thumbnail)
        color = try c.decodeIfPresent(String.self, forKey: .color)
        deletedAt = try c.decodeIfPresent(AnyCodable.self, forKey: .deletedAt)
        isSelected = try c.decodeIfPresent(Bool.self, forKey: .isSelected)
        liveCount = try c.decodeIfPresent(Int.self, forKey: .liveCount)

        if let decoded = try c.decodeIfPresent([CategoryExtraField].self, forKey: .extraFields) {
            extraFields = decoded
        } else {
            extraFields = nil
            _ = try? c.decodeIfPresent([AnyCodable].self, forKey: .extraFields)
        }
    }
}

struct CategoryExtraField: Codable, Hashable {
    let label: String?
    let type: String?
    let options: [String]?
}

struct SubCategory: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let image: String?
    let thumbnail: String?
    let color: String?
    let categoryId: Int?
    let extraFields: [CategoryExtraField]?
    let deletedAt: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case id, name, image, thumbnail, color
        case categoryId = "category_id"
        case extraFields = "extra_fields"
        case deletedAt = "deleted_at"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        image = try c.decodeIfPresent(String.self, forKey: .image)
        thumbnail = try c.decodeIfPresent(String.self, forKey: .thumbnail)
        color = try c.decodeIfPresent(String.self, forKey: .color)
        categoryId = try c.decodeIfPresent(Int.self, forKey: .categoryId)
        deletedAt = try c.decodeIfPresent(AnyCodable.self, forKey: .deletedAt)

        if let decoded = try c.decodeIfPresent([CategoryExtraField].self, forKey: .extraFields) {
            extraFields = decoded
        } else {
            extraFields = nil
            _ = try? c.decodeIfPresent([AnyCodable].self, forKey: .extraFields)
        }
    }
}

// MARK: - UserPublic (shared condensed user representation)

/// A minimal user projection that appears inline in Show, Bid, Order,
/// Notification, and many other response payloads.
struct UserPublic: Codable, Identifiable, Hashable {
    let id: Int?
    let bio: String?
    let email: String?
    let firstName: String?
    let lastName: String?
    let name: String?
    let username: String?
    let profileImage: String?
    let thumbnail: AnyCodable?
    let referralCode: String?
    let roleId: Int?
    let isActive: Bool?
    let rating: String?
    let isFollowed: Bool?

    enum CodingKeys: String, CodingKey {
        case id, bio, email, name, username, rating
        case firstName = "first_name"
        case lastName = "last_name"
        case profileImage = "profile_image"
        case thumbnail
        case referralCode = "referral_code"
        case roleId = "role_id"
        case isActive = "is_active"
        case isFollowed = "is_followed"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decodeIfPresent(Int.self, forKey: .id)
        bio = (try? c.decodeIfPresent(String.self, forKey: .bio)) ?? nil
        email = try c.decodeIfPresent(String.self, forKey: .email)
        firstName = try c.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try c.decodeIfPresent(String.self, forKey: .lastName)
        name = try c.decodeIfPresent(String.self, forKey: .name)
        username = try c.decodeIfPresent(String.self, forKey: .username)
        profileImage = try c.decodeIfPresent(String.self, forKey: .profileImage)
        thumbnail = try c.decodeIfPresent(AnyCodable.self, forKey: .thumbnail)
        referralCode = try c.decodeIfPresent(String.self, forKey: .referralCode)
        roleId = try c.decodeIfPresent(Int.self, forKey: .roleId)
        isActive = try c.decodeIfPresent(Bool.self, forKey: .isActive)
        rating = try c.decodeIfPresent(String.self, forKey: .rating)
        isFollowed = try c.decodeIfPresent(Bool.self, forKey: .isFollowed)

        if bio == nil {
            _ = try? c.decodeIfPresent(AnyCodable.self, forKey: .bio)
        }
    }
}

// MARK: - Role

struct Role: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let createdAt: AnyCodable?
    let updatedAt: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case id, name
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - ShippingAddress

struct ShippingAddress: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let phoneNumber: String?
    let streetAddress: String?
    // MC sub-task cmp4932vk00l13mx1du6mmebo (Trey 2026-05-13): optional
    // second street-address line (apartment / unit / suite). Backing
    // column shipping_addresses.address_line_2 added the same session.
    let addressLine2: String?
    let pincode: String?
    let city: String?
    let state: String?
    let type: String?
    let userId: Int?
    let isDefault: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name, pincode, city, state, type
        case phoneNumber = "phone_number"
        case streetAddress = "street_address"
        case addressLine2 = "address_line_2"
        case userId = "user_id"
        case isDefault = "is_default"
    }
}

// MARK: - Pagination helper

/// Pagination metadata lifted out of `APIPaginatedResponse` so per-cursor
/// views can publish just the page state.
struct PageInfo: Codable, Hashable {
    let currentPage: Int?
    let perPage: Int?
    let total: Int?
    let totalPage: Int?
}

// MARK: - Media (shared between product images, clip thumbnails, etc.)

struct Media: Codable, Hashable {
    let url: String?
    let type: String?      // "image" | "video"
    let thumbnail: String?
}

// MARK: - Country / State / Language / Format

struct Country: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let code: String?
    let flag: String?
}

struct StateInfo: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let countryId: Int?

    enum CodingKeys: String, CodingKey {
        case id, name
        case countryId = "country_id"
    }
}

struct LanguageInfo: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    let code: String?
}

struct FormatInfo: Codable, Identifiable, Hashable {
    let id: Int?
    let name: String?
    var isSelected: Bool?

    enum CodingKeys: String, CodingKey {
        case id, name
        case isSelected = "is_selected"
    }
}
