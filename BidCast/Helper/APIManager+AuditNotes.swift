//
//  APIManager+AuditNotes.swift
//  BidCast
//
//  iOS parity phase 1d (2026-04-22) \u2014 Networking layer audit notes + hooks.
//
//  This file is ADDITIVE ONLY. It does not change APIManager behavior. The
//  purpose is to:
//    1. Document what the existing APIManager already does well,
//    2. Flag the gaps that must be closed before Phase 2 commerce / live
//       features can ship (each gap has a TODO and a proposed shape),
//    3. Give Phase 2 a single concrete entry point (`AuthTokenRefreshHook`)
//       to plug in refresh-on-401 behavior WITHOUT rewriting APIManager.
//
//  Full rewrite / Alamofire migration, if ever desired, should be a Phase 7
//  conversation \u2014 APIManager's 873 lines handle the current surface correctly
//  today. The Android parity blockers here are token refresh + a consistent
//  error taxonomy, which we can add without touching the body of APIManager.
//

import Foundation

// MARK: - Audit findings (as of 2026-04-22)
//
// What APIManager.swift does well:
//   \u2022 async / await public surface (matches modern iOS + Swift concurrency).
//   \u2022 JSON encode via Encodable body (no Alamofire required).
//   \u2022 Bearer token header injection from UserDefaults.accessToken.
//   \u2022 `Content-Type: application/json` + `time_zone` header (parity with
//     Android's OkHttp interceptors).
//   \u2022 HTTP 200\u2013299 status-code gate, decoded ApiError message on failure.
//   \u2022 Rich decoding error surface (typeMismatch / valueNotFound / keyNotFound /
//     dataCorrupted) including coding path \u2014 this is better than Android's
//     default Gson behavior.
//   \u2022 Multipart form POST helper (`postMultipartForm`) that matches Android
//     Retrofit's `@Multipart @POST` + `@Part` contract, including the
//     "omit-to-mean-null" convention used by the BidCast Laravel backend.
//   \u2022 Multiple image-upload helpers for different Android endpoints.
//
// Gaps (must close before Phase 2\u20136):
//   [T-REFRESH] No 401 auth-token-refresh interceptor. When the server returns
//     HTTP 401 with an expired token, APIManager currently throws
//     `DataError.invalidCode("Unauthenticated.")` and the caller must re-login.
//     Android handles this in OkHttp's Authenticator chain. iOS needs a
//     transparent one-retry refresh flow. See `AuthTokenRefreshHook` below.
//   [T-ERRORS] Error taxonomy collapses HTTP + decoding + app-level errors
//     into one `DataError.invalidCode(String?)`. Phase 2 wants to distinguish
//     unauthorized / rate-limited / server-5xx / offline / decoding. Proposed
//     additive shape: new cases on DataError or a new NetworkError enum that
//     maps into DataError for backwards compat. NOT doing that rewrite in
//     Phase 1 because every existing VM catches DataError shape as-is.
//   [T-LOGS] `debugLog` prints go to stdout only \u2014 no file logging, no
//     breadcrumb store for Crashlytics. Phase 7 (Crashlytics) lands that.
//   [T-RETRY] No retry-with-backoff on transient network errors. Low priority
//     since `URLSessionConfiguration.waitsForConnectivity = true` already
//     handles offline \u2192 reachability. Add if user-facing rate limiting shows up.
//
// Not broken, but worth flagging for Phase 2 readers:
//   \u2022 The 873-line file includes 5 near-identical upload helpers
//     (`uploadMedia`, `uploadFile`, `uploadImage`, `uploadImageforDifferentKey`,
//     two `uploadImageWithMultipleKeys` overloads, `postMultipartForm`). Each
//     has its own boundary / body-builder code path. A single
//     `MultipartFormBuilder` + one public upload method would collapse this by
//     ~600 lines but is a rewrite \u2014 leaving it untouched here.

// MARK: - AuthTokenRefreshHook (scaffolding for Phase 2)
//
// Phase 1 commits this as a dormant hook. Phase 2 will wire
// APIManager.request / postMultipartForm / upload* to check
// `AuthTokenRefreshHook.shared` before throwing on a 401 and, if present,
// invoke it to mint a new access token, then retry the original request ONCE.
//
// Real token refresh implementation requires the backend to expose a refresh
// endpoint (currently the login contract returns only `token`, no explicit
// refresh token). Confirm the contract with the backend team before wiring
// the real refresh call.
public final class AuthTokenRefreshHook {

    public static let shared = AuthTokenRefreshHook()

    /// Swap in a real implementation in Phase 2. Receives the current
    /// (stale) bearer token and should resolve to a fresh one, or nil if
    /// refresh failed (callers should then surface a logout prompt).
    public var refresh: ((String) async -> String?)? = nil

    /// Convenience: single place to read / write the persisted access token.
    /// Keeping the same UserDefaults key the existing APIManager already
    /// uses so nothing else has to change.
    public static var currentAccessToken: String {
        get { UserDefaults.accessToken }
        set { UserDefaults.accessToken = newValue }
    }

    private init() {}
}
