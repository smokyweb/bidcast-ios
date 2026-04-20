//
//  Error+Extension.swift
//  BidCast
//
//  Created by jam 1 TB on 25/03/25.
//

import Foundation

extension DataError {
    func getErrorMessage() -> String {
        switch self {
        case .invalidResponse(let data):
            if let data = data{
                do {
                    let dataObj = try JSONDecoder().decode(ApiError.self, from: data)
                    return dataObj.message
                }
                catch {
                    return "Invalid Response"
                }
            }
        case .invalidCode(let message):
            return message ?? ""
        case .invalidURL:
            return "Not a Valid URL"
        case .invalidData:
            return "Response Data is not valid"
        default:
            return "Unknown Error"
        }
        return "Error found"
    }

    // QA-FIX (deleted-account signup): callers that need to branch on the
    // backend's `error_type` (e.g. signup to detect ACCOUNT_DELETED vs
    // EMAIL_TAKEN) can use this to recover the decoded ApiError. Returns nil
    // when this DataError case does not carry a decodable ApiError payload.
    func getApiError() -> ApiError? {
        switch self {
        case .invalidResponse(let data):
            if let data = data {
                if let apiError = try? JSONDecoder().decode(ApiError.self, from: data) {
                    return apiError
                }
            }
            return nil
        default:
            return nil
        }
    }
}
