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
}
