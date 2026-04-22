//
//  LiveShowResolver.swift
//  BidCast
//
//  iOS Parity Phase 5 (2026-04-22):
//  Given only a show id (from a push notification, a deep link like
//  `bidcast://stream/42`, or a live-feed tile), fetch the full live-show
//  payload from the backend and hand back a ready-to-launch `LiveShowContext`.
//
//  Android parity: `WatchStreamFragment` receives a `LiveShowModel` from the
//  list fragment (e.g. `HomeFragment` or `ExploreFragment`), which already
//  pre-populates `rtcToken` + `roomId` via `/api/get-live-show`. On iOS we
//  don't always have that intermediate model yet, so this resolver hits the
//  backend on-demand and falls back to `/api/agora-token` if the show
//  response omits `rtc_token` (which the backend will do when a viewer joins
//  a show that hasn't been pre-tokenized for them).
//

import Foundation

public enum LiveShowResolverError: Error, LocalizedError {
    case showNotFound
    case missingAgoraAppId
    case missingRoomId
    case backendError(String)

    public var errorDescription: String? {
        switch self {
        case .showNotFound: return "Live show could not be found."
        case .missingAgoraAppId: return "Agora app id is not configured for this build."
        case .missingRoomId: return "This show does not have a room id yet."
        case .backendError(let m): return m
        }
    }
}

public enum LiveShowResolver {

    /// Resolve a `LiveShowContext` for a viewer given a show id.
    /// Tries these sources in order:
    ///   1. `POST /api/get-live-show` returning the full `Show` payload.
    ///   2. If `rtc_token` is missing, `POST /api/agora-token` with
    ///      channel=room_id, uid=currentUserId.
    public static func resolveViewerContext(
        showId: Int,
        currentUserId: String
    ) async throws -> LiveShowContext {
        // 1. Fetch show via raw GET to api/v1/get-show-details-by-id?show_id=<id>
        //    (The EndPointType enum doesn't carry query params yet, so build
        //    the URL directly. Android uses the equivalent GET path.)
        let showResp: GetShowDetailsResponse
        do {
            showResp = try await fetchShowById(showId: showId)
        } catch let e as LiveShowResolverError {
            throw e
        } catch let e as DataError {
            throw LiveShowResolverError.backendError(e.getErrorMessage())
        } catch {
            throw LiveShowResolverError.backendError(error.localizedDescription)
        }

        guard let show = showResp.data else { throw LiveShowResolverError.showNotFound }
        guard let roomId = show.roomId, !roomId.isEmpty else {
            throw LiveShowResolverError.missingRoomId
        }
        let appId = agoraAppIdFromBundle()
        guard !appId.isEmpty else { throw LiveShowResolverError.missingAgoraAppId }

        // 2. Ensure rtc token. If the show payload doesn't carry one (viewer
        // joining cold), fetch a fresh token.
        var rtcToken = show.rtcToken ?? ""
        if rtcToken.isEmpty {
            let payload = try await AgoraTokenService.fetch(
                channel: roomId,
                uid: currentUserId
            )
            rtcToken = payload.token ?? ""
        }
        guard !rtcToken.isEmpty else {
            throw LiveShowResolverError.backendError("Could not obtain Agora token for this show.")
        }

        let sellerId = show.userId.map(String.init) ?? show.user?.id.map(String.init) ?? ""
        let sellerName: String = {
            if let f = show.user?.firstName, !f.isEmpty {
                let l = show.user?.lastName ?? ""
                return "\(f) \(l)".trimmingCharacters(in: .whitespaces)
            }
            if let n = show.user?.name, !n.isEmpty { return n }
            if let u = show.user?.username, !u.isEmpty { return u }
            return show.title ?? "Seller"
        }()

        return LiveShowContext(
            showId: show.id.map(String.init) ?? String(showId),
            roomId: roomId,
            rtcToken: rtcToken,
            agoraAppId: appId,
            sellerId: sellerId,
            sellerName: sellerName,
            sellerImage: show.user?.profileImage,
            categoryId: show.categoryId.map(String.init),
            auctionTypeId: show.auctionTypeId,
            productIds: (show.productIds ?? []).compactMap { $0 },
            isHost: false
        )
    }

    // MARK: - Private

    private static func agoraAppIdFromBundle() -> String {
        if let s = Bundle.main.object(forInfoDictionaryKey: "AGORA_APP_ID") as? String, !s.isEmpty {
            return s
        }
        return ""
    }

    private static func fetchShowById(showId: Int) async throws -> GetShowDetailsResponse {
        // Build the URL with a query param — the getShowDetails enum case is
        // a GET with no native params, so we construct the final URL here.
        let base = "https://backend.bidcast.betaplanets.com/api/v1/get-show-details-by-id"
        guard var components = URLComponents(string: base) else {
            throw LiveShowResolverError.backendError("Invalid backend URL")
        }
        components.queryItems = [URLQueryItem(name: "show_id", value: String(showId))]
        guard let url = components.url else {
            throw LiveShowResolverError.backendError("Failed to build show-details URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")

        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 60

        let (data, response) = try await URLSession(configuration: config).data(for: request)
        if let http = response as? HTTPURLResponse {
            if http.statusCode == 401 || http.statusCode == 403 {
                throw LiveShowResolverError.backendError("Not authorized. Please log in again.")
            }
            guard 200 ... 299 ~= http.statusCode else {
                let apiErr = try? JSONDecoder().decode(ApiError.self, from: data)
                throw LiveShowResolverError.backendError(apiErr?.message ?? "Request failed (\(http.statusCode))")
            }
        }
        do {
            return try JSONDecoder().decode(GetShowDetailsResponse.self, from: data)
        } catch {
            throw LiveShowResolverError.backendError("Unable to parse show details: \(error.localizedDescription)")
        }
    }
}
