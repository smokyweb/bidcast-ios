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

    // HOTFIX 2026-05-01 (MC cmomwykts00233r1hcw317di3): the previous CodingKeys
    // declared the JSON keys as camelCase (currentPage / perPage / totalPage),
    // but Laravel returns them as snake_case (current_page / per_page /
    // total_page). The mismatch made the home feed envelope fail to decode
    // and the user saw "Couldn't load feed" right after sign-in. Just remap
    // the rawValues to the snake_case keys Laravel actually emits.
    enum CodingKeys: String, CodingKey {
        case status, message, data, total
        case currentPage = "current_page"
        case perPage     = "per_page"
        case totalPage   = "total_page"
        case errorType   = "error_type"
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
