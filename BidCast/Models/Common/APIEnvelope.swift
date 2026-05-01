//  APIEnvelope.swift
//  BidCast — iOS parity phase 2 (2026-04-22)
//
//  Android responses (network/response/*Response.kt) all share the same
//  envelope: status / message / error_type / data. Use `APIResponse<T>`
//  for endpoints that return a single object, and `APIListResponse<T>`
//  for endpoints that return a list (some of which also include
//  pagination metadata — see `APIPaginatedResponse<T>`).
//
//  QA-NOTE: Android uses `Any?` for "empty" fields (e.g. deleted_at) —
//  those map to `AnyCodable` here to accept either `null`, a string,
//  or a nested structure without decoding failures.

import Foundation

// MARK: - Single-object envelope

/// Envelope for endpoints that return a single `data` object.
/// Example: LoginResponse, SignUpResponse, GetUserProfileResponse, ...
struct APIResponse<T: Codable>: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let data: T?

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorType = "error_type"
    }
}

// MARK: - List envelope

/// Envelope for endpoints that return a `data` array.
/// Example: GetCategoryResponse, FAQResponse, GetHowToSellResponse, ...
struct APIListResponse<T: Codable>: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let data: [T]?

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorType = "error_type"
    }
}

// MARK: - Paginated list envelope

/// Envelope for endpoints that return a paginated list. Android's paginated
/// responses include currentPage / perPage / total / totalPage at the top
/// level alongside `data: List<T>`.
/// Example: GetMyShowResponse, GetOrdersResponse, FetchBidResponse,
/// GetNotificationResponse, GetMyInventoryResponse, GetClipsResponse,
/// GetOffersResponse, GetProductsByStatusResponse.
struct APIPaginatedResponse<T: Codable>: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let data: [T]?
    let currentPage: Int?
    let perPage: Int?
    let total: Int?
    let totalPage: Int?

    // HOTFIX 2026-05-01 (MC cmomwykyp00253r1hroxmppfn): the previous CodingKeys
    // declared the JSON keys as `currentPage`/`perPage`/`totalPage` (camelCase),
    // but Laravel returns them as snake_case (`current_page`/`per_page`/`total_page`).
    // The mismatch caused the home feed `getLiveShow` envelope to fail decoding
    // with a keyNotFound error and the user saw "Couldn't load feed" right after
    // sign-in. Use a tolerant init that accepts either spelling so we don't break
    // any callsite that's already (silently) been getting the camelCase form.
    enum CodingKeys: String, CodingKey {
        case status, message, data, total
        case currentPage = "current_page"
        case perPage = "per_page"
        case totalPage = "total_page"
        case errorType = "error_type"
        // Backwards-compat aliases in case any endpoint actually returns camelCase.
        case currentPageCamel = "currentPage"
        case perPageCamel = "perPage"
        case totalPageCamel = "totalPage"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status = try c.decodeIfPresent(String.self, forKey: .status)
        message = try c.decodeIfPresent(String.self, forKey: .message)
        errorType = try c.decodeIfPresent(String.self, forKey: .errorType)
        data = try c.decodeIfPresent([T].self, forKey: .data)
        total = try c.decodeIfPresent(Int.self, forKey: .total)
        currentPage = (try c.decodeIfPresent(Int.self, forKey: .currentPage))
            ?? (try c.decodeIfPresent(Int.self, forKey: .currentPageCamel))
        perPage = (try c.decodeIfPresent(Int.self, forKey: .perPage))
            ?? (try c.decodeIfPresent(Int.self, forKey: .perPageCamel))
        totalPage = (try c.decodeIfPresent(Int.self, forKey: .totalPage))
            ?? (try c.decodeIfPresent(Int.self, forKey: .totalPageCamel))
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(status,      forKey: .status)
        try c.encodeIfPresent(message,     forKey: .message)
        try c.encodeIfPresent(errorType,   forKey: .errorType)
        try c.encodeIfPresent(data,        forKey: .data)
        try c.encodeIfPresent(total,       forKey: .total)
        try c.encodeIfPresent(currentPage, forKey: .currentPage)
        try c.encodeIfPresent(perPage,     forKey: .perPage)
        try c.encodeIfPresent(totalPage,   forKey: .totalPage)
    }
}

// MARK: - Common empty/generic response

/// Envelope for endpoints that return a `data` field of arbitrary shape
/// (Android declares `data : Any?`). Use when the client doesn't care
/// about the body, only the status/message (success toasts etc.).
/// Example: CommonResponse (Android fallback used by ~40 endpoints).
struct APIEmptyResponse: Codable {
    let status: String?
    let message: String?
    let errorType: String?
    let data: AnyCodable?

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorType = "error_type"
    }
}

// MARK: - APIError

/// Mirrors Android's `error_type` / `message` surface for failed calls.
struct APIError: Codable, Error {
    let status: String?
    let message: String?
    let errorType: String?

    enum CodingKeys: String, CodingKey {
        case status, message
        case errorType = "error_type"
    }
}
