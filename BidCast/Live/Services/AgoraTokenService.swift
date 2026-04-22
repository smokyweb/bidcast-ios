//
//  AgoraTokenService.swift
//  BidCast
//
//  iOS Parity Phase 5 (2026-04-22):
//  Fetch a fresh Agora RTC token for a channel/uid pair via the backend's
//  `/api/agora-token` endpoint. Mirrors Android's
//  `ApiInterface.getAgoraToken(channel, uid)` contract:
//
//    POST api/agora-token        (multipart)
//      channel : <room_id>
//      uid     : <current_user_id>
//
//    Response JSON (Android `GetAgoraTokenResponse`):
//      {
//        "status": "true",
//        "data": {
//          "channel": "...",
//          "token":   "...",
//          "uid":     12345,
//          "expires_at": 17... (unix seconds)
//        }
//      }
//
//  This service is invoked by LiveShowLauncher when the Show object
//  returned from list endpoints does not include `rtc_token` (e.g.
//  the Home feed's `get-live-show` response, or a deep link where only
//  the show id is known).
//

import Foundation

public struct AgoraTokenPayload: Decodable {
    public let channel: String?
    public let token: String?
    public let uid: Int?
    public let expiresAt: Int?

    enum CodingKeys: String, CodingKey {
        case channel, token, uid
        case expiresAt = "expires_at"
    }
}

private struct AgoraTokenResponse: Decodable {
    let status: String?
    let message: String?
    let data: AgoraTokenPayload?
}

public enum AgoraTokenServiceError: Error, LocalizedError {
    case missingChannel
    case backendError(String)
    case decodingError

    public var errorDescription: String? {
        switch self {
        case .missingChannel: return "No channel id available to request an Agora token."
        case .backendError(let m): return m
        case .decodingError: return "Unable to parse Agora token response."
        }
    }
}

public enum AgoraTokenService {

    /// Fetch a fresh Agora RTC token for `channel` + `uid`.
    /// If the backend returns success with an empty token we surface
    /// `.backendError` rather than pretend we have one.
    public static func fetch(channel: String, uid: String) async throws -> AgoraTokenPayload {
        guard !channel.isEmpty else { throw AgoraTokenServiceError.missingChannel }

        let fields: [String: String] = [
            "channel": channel,
            "uid": uid
        ]
        do {
            let resp: AgoraTokenResponse = try await APIManager.shared.postMultipartForm(
                type: .getAgoraToken(param: [:]),
                fields: fields,
                header: true
            )
            guard let data = resp.data, let token = data.token, !token.isEmpty else {
                throw AgoraTokenServiceError.backendError(resp.message ?? "Backend returned empty Agora token.")
            }
            return data
        } catch let e as AgoraTokenServiceError {
            throw e
        } catch let e as DataError {
            throw AgoraTokenServiceError.backendError(e.getErrorMessage())
        } catch {
            throw AgoraTokenServiceError.backendError(error.localizedDescription)
        }
    }
}
