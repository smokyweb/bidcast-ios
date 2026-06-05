// RandomizerModels.swift
// BidCast — Randomizer feature data models
// Build 313 / 2026-05-26

import Foundation
import SwiftUI

// MARK: - Template Type
enum RandomizerType: String, Codable, CaseIterable, Identifiable {
    case productRaffle        = "product_raffle"
    case blindProductRaffle   = "blind_product_raffle"
    case buyerRaffle          = "buyer_raffle"
    case wheelBinAuction      = "wheel_bin_auction"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .productRaffle:      return "Product Raffle"
        case .blindProductRaffle: return "Blind Product Raffle"
        case .buyerRaffle:        return "Buyer Raffle"
        case .wheelBinAuction:    return "Wheel + BIN/Auction"
        }
    }

    var description: String {
        switch self {
        case .productRaffle:      return "Slots show product images, colors & icons"
        case .blindProductRaffle: return "Slots show colors & icons only (mystery!)"
        case .buyerRaffle:        return "Slots show buyer avatars & names"
        case .wheelBinAuction:    return "Visual wheel decoration alongside BIN/Auction"
        }
    }
}

// MARK: - Slot Colors (12 swatches)
enum RandomizerSlotColor: String, CaseIterable, Identifiable {
    case red       = "#FF6B6B"
    case orange    = "#FFA94D"
    case yellow    = "#FFD43B"
    case lime      = "#82C91E"
    case green     = "#51CF66"
    case teal      = "#20C997"
    case cyan      = "#22B8CF"
    case blue      = "#339AF0"
    case indigo    = "#5C7CFA"
    case violet    = "#845EF7"
    case grape     = "#CC5DE8"
    case pink      = "#F06595"

    var id: String { rawValue }

    var color: Color { Color(hex: rawValue) }
}

// MARK: - Slot Icons (12 emoji)
enum RandomizerSlotIcon: String, CaseIterable, Identifiable {
    case gift    = "🎁"
    case party   = "🎉"
    case money   = "💰"
    case trophy  = "🏆"
    case star    = "⭐"
    case target  = "🎯"
    case diamond = "💎"
    case circus  = "🎪"
    case clover  = "🍀"
    case fire    = "🔥"
    case bolt    = "⚡"
    case crown   = "👑"

    var id: String { rawValue }
}

// MARK: - Slot Model
struct RandomizerSlot: Codable, Identifiable {
    var id: Int?
    var template_id: Int?
    var position: Int
    var color: String
    var icon: String?
    var image: String?        // #9960173707 Phase 4: custom slot image url
    var product_id: Int?
    var product: SlotProduct?

    // Local-only (not sent to server)
    var localId: UUID = UUID()

    enum CodingKeys: String, CodingKey {
        case id, template_id, position, color, icon, image, product_id, product
    }

    init(position: Int, color: String = "#339AF0", icon: String? = nil, image: String? = nil, product_id: Int? = nil) {
        self.position = position
        self.color = color
        self.icon = icon
        self.image = image
        self.product_id = product_id
    }
}

// MARK: - Slim product info embedded in slot
struct SlotProduct: Codable, Identifiable {
    var id: Int?
    var title: String?
    var images: [String]?
    var pricing: String?

    var thumbnailURL: URL? {
        guard let first = images?.first else { return nil }
        return URL(string: first)
    }
}

// MARK: - Template Model
struct RandomizerTemplate: Codable, Identifiable {
    var id: Int?
    var user_id: Int?
    var name: String
    var type: String
    var entry_cost: Double?
    var prize_product_id: Int?       // #9960173707 Phase 4: buyer_raffle single prize product
    var prize_product: SlotProduct?  // optional embedded prize product detail
    var slot_count: Int
    var slots: [RandomizerSlot]?
    var created_at: String?
    var updated_at: String?

    var randomizerType: RandomizerType {
        RandomizerType(rawValue: type) ?? .productRaffle
    }

    var formattedEntryCost: String {
        guard let cost = entry_cost, cost > 0 else { return "Free" }
        return String(format: "$%.2f", cost)
    }
}

// MARK: - API response wrappers
struct RandomizerTemplateListResponse: Codable {
    var status: String?
    var message: String?
    var data: [RandomizerTemplate]?
}

struct RandomizerTemplateSingleResponse: Codable {
    var status: String?
    var message: String?
    var data: RandomizerTemplate?
}

// MARK: - Create/Update request body
struct RandomizerTemplateRequest: Encodable {
    var name: String
    var type: String
    var entry_cost: Double?
    var prize_product_id: Int?    // #9960173707 Phase 4: buyer_raffle prize product
    var slot_count: Int
    var slots: [RandomizerSlotRequest]
}

struct RandomizerSlotRequest: Encodable {
    var position: Int
    var color: String
    var icon: String?
    var image: String?           // #9960173707 Phase 4: custom slot image url
    var product_id: Int?
}

// MARK: - Show-attach request
struct AttachTemplateRequest: Encodable {
    var template_id: Int
}

// MARK: - Single-detach request (#9960173707 Phase 4: multiple-per-show)
struct DetachTemplateRequest: Encodable {
    var template_id: Int
}

// MARK: - Show-scoped attached-templates response (#9960173707 Phase 4)
struct ShowTemplatesResponse: Codable {
    var status: String?
    var success: Bool?
    var data: [RandomizerTemplate]?
}

// MARK: - Slot image upload response (#9960173707 Phase 4)
struct SlotImageUploadResponse: Codable {
    var status: String?
    var success: Bool?
    var url: String?
    var path: String?
    var message: String?
}

// MARK: - Socket payload extensions for template-based wheel
struct RandomizerFreebiePayload: Codable {
    var freebie: FreebieModel?
    var users_list: [FreebieUser]?
    var template_type: String?
    var slots: [RandomizerSlot]?
    var entry_cost: Double?
}

// Extend FreebieModel to include optional template metadata
// (decoded from get-freebie event when template is used)
struct TemplateWheelSlot: Codable, Identifiable {
    var id: Int?
    var position: Int
    var color: String
    var icon: String?
    var image: String?        // #9960173707 Phase 4: custom slot image url
    var product_id: Int?
    var product: SlotProduct?

    // Derived UI values
    var displayColor: Color { Color(hex: color) }
    var displayLabel: String {
        if let product = product, let title = product.title {
            return title
        }
        return icon ?? "🎁"
    }
    var imageURL: URL? {
        guard let image = image, !image.isEmpty else { return nil }
        return URL(string: image)
    }
}
