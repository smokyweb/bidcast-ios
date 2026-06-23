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
        case .wheelBinAuction:    return "Random Product Wheel"
        }
    }

    var description: String {
        switch self {
        case .productRaffle:      return "Slots show product images, colors & icons"
        case .blindProductRaffle: return "Slots show colors & icons only (mystery!)"
        case .buyerRaffle:        return "Slots show buyer avatars & names"
        case .wheelBinAuction:    return "Randomly chooses the next BIN or auction item"
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
    var thumbnail: [String]?
    var pricing: String?
    var quantity: String?
    var purchasedQuantity: String?

    var thumbnailURL: URL? {
        guard let first = thumbnail?.first ?? images?.first else { return nil }
        return URL(string: first)
    }

    var quantityValue: Int {
        Int(Double(quantity ?? "0") ?? 0)
    }

    var availableQuantityValue: Int {
        let purchased = Int(Double(purchasedQuantity ?? "0") ?? 0)
        return max(0, quantityValue - purchased)
    }

    private enum CodingKeys: String, CodingKey {
        case id, title, images, thumbnail, pricing, quantity, purchasedQuantity
        case purchased_quantity
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decodeIfPresent(Int.self, forKey: .id)
        title = try? c.decodeIfPresent(String.self, forKey: .title)
        images = randomizerDecodeFlexibleStringArray(c, forKey: .images)
        thumbnail = randomizerDecodeFlexibleStringArray(c, forKey: .thumbnail)
        pricing = randomizerDecodeFlexibleString(c, forKey: .pricing)
        quantity = randomizerDecodeFlexibleString(c, forKey: .quantity)
        purchasedQuantity = randomizerDecodeFlexibleString(c, forKey: .purchasedQuantity) ?? randomizerDecodeFlexibleString(c, forKey: .purchased_quantity)
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(id, forKey: .id)
        try c.encodeIfPresent(title, forKey: .title)
        try c.encodeIfPresent(images, forKey: .images)
        try c.encodeIfPresent(thumbnail, forKey: .thumbnail)
        try c.encodeIfPresent(pricing, forKey: .pricing)
        try c.encodeIfPresent(quantity, forKey: .quantity)
        try c.encodeIfPresent(purchasedQuantity, forKey: .purchasedQuantity)
    }
}

private func randomizerDecodeFlexibleString<K: CodingKey>(_ c: KeyedDecodingContainer<K>, forKey key: K) -> String? {
    if let s = try? c.decodeIfPresent(String.self, forKey: key) { return s.isEmpty ? nil : s }
    if let i = try? c.decodeIfPresent(Int.self, forKey: key) { return String(i) }
    if let d = try? c.decodeIfPresent(Double.self, forKey: key) { return String(d) }
    if let b = try? c.decodeIfPresent(Bool.self, forKey: key) { return b ? "true" : "false" }
    return nil
}

private func randomizerDecodeFlexibleDouble<K: CodingKey>(_ c: KeyedDecodingContainer<K>, forKey key: K) -> Double? {
    if let d = try? c.decodeIfPresent(Double.self, forKey: key) { return d }
    if let i = try? c.decodeIfPresent(Int.self, forKey: key) { return Double(i) }
    if let s = try? c.decodeIfPresent(String.self, forKey: key) { return Double(s.trimmingCharacters(in: .whitespaces)) }
    return nil
}

private func randomizerDecodeFlexibleStringArray<K: CodingKey>(_ c: KeyedDecodingContainer<K>, forKey key: K) -> [String]? {
    if let values = try? c.decodeIfPresent([String].self, forKey: key) { return values }
    if let value = try? c.decodeIfPresent(String.self, forKey: key), !value.isEmpty { return [value] }
    return nil
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
    var source_template_id: Int?
    var show_scoped_show_id: Int?
    var created_at: String?
    var updated_at: String?

    enum CodingKeys: String, CodingKey {
        case id, user_id, name, type, entry_cost, prize_product_id, prize_product, slot_count, slots, source_template_id, show_scoped_show_id, created_at, updated_at
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try? c.decodeIfPresent(Int.self, forKey: .id)
        user_id = try? c.decodeIfPresent(Int.self, forKey: .user_id)
        name = (try? c.decodeIfPresent(String.self, forKey: .name)) ?? ""
        type = (try? c.decodeIfPresent(String.self, forKey: .type)) ?? RandomizerType.productRaffle.rawValue
        entry_cost = randomizerDecodeFlexibleDouble(c, forKey: .entry_cost)
        prize_product_id = try? c.decodeIfPresent(Int.self, forKey: .prize_product_id)
        prize_product = try? c.decodeIfPresent(SlotProduct.self, forKey: .prize_product)
        slot_count = (try? c.decodeIfPresent(Int.self, forKey: .slot_count)) ?? 6
        slots = try? c.decodeIfPresent([RandomizerSlot].self, forKey: .slots)
        source_template_id = try? c.decodeIfPresent(Int.self, forKey: .source_template_id)
        show_scoped_show_id = try? c.decodeIfPresent(Int.self, forKey: .show_scoped_show_id)
        created_at = try? c.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try? c.decodeIfPresent(String.self, forKey: .updated_at)
    }

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
    var show_id: Int? = nil
    var is_show_copy: Bool? = nil
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
    var copy_for_show: Bool? = nil
}

struct AttachTemplateResponse: Codable {
    var success: Bool?
    var data: AttachTemplatePayload?
}

struct AttachTemplatePayload: Codable {
    var attached_template_id: Int?
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
