//  Well Genius App
//
//  Created by Ankit-JAM-E-294 on 31/08/24.
//  Well Genius App
//
//  Created by Ankit-JAM-E-294 on 31/08/24.

import Foundation
import SVProgressHUD
import SwiftUI
import Combine

// MARK: - Error Types
enum DataError: Error {
    case invalidResponse(Data?)
    case invalidCode(String?)
    case invalidURL
    case invalidData
    case network(Error?)
    case networkError
    case failedToDecode
}

extension DataError {
    func getErrorMessage() -> String {
        switch self {
        case .invalidResponse(let data):
            if let data = data {
                do {
                    let dataObj = try JSONDecoder().decode(ApiError.self, from: data)
                    return dataObj.message ?? ""
                } catch {
                    return "Invalid Response"
                }
            }
            return "Invalid Response"
        case .invalidCode(let message):
            return message ?? ""
        case .invalidURL:
            return "Not a Valid URL"
        case .invalidData:
            return "Response Data is not valid"
        case .network(let underlying):
            return underlying?.localizedDescription ?? "Network Error"
        case .networkError:
            return "Network Error"
        case .failedToDecode:
            return "Failed to Decode Response"
        }
    }
}

// Conform to LocalizedError so that `error.localizedDescription` (used widely in
// ViewModels, e.g. `self.errorMessage = error.localizedDescription`) returns the
// real message we packed into the case rather than Swift's generic
// "The operation couldn't be completed. (BidCast.DataError error N.)" fallback.
extension DataError: LocalizedError {
    var errorDescription: String? { getErrorMessage() }
}

// MARK: - Protocol
protocol APIManaging {
    func request<T: Decodable>(type: APIEndPoint, header: Bool) -> AnyPublisher<ResponseModel<T>, DataError>
}

typealias Handler<T> = (Result<T, DataError>) -> Void
let deviceTimeZone = getDeviceTimeZone()

final class APIManager {
    
    static var commonHeaders: [String: String] {
        return ["Content-Type": "application/json"]
    }
    
    private static var isShowingUnauthorizedAlert = false
    static let shared = APIManager()
    
    // MARK: - Optimization 1: Reusable URLSession with optimized configuration
private lazy var optimizedSession: URLSession = {
    let config = URLSessionConfiguration.ephemeral
    config.waitsForConnectivity = false
    config.timeoutIntervalForRequest = 120
    config.timeoutIntervalForResource = 120
    config.requestCachePolicy = .reloadIgnoringLocalCacheData
    config.httpShouldUsePipelining = true
    config.httpMaximumConnectionsPerHost = 8
    config.urlCache = nil   // 🚀 NO DISK, NO MEMORY CACHE
    return URLSession(configuration: config)
}()
    
    // MARK: - Optimization 2: Reusable JSON Decoder
    private lazy var jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    // MARK: - Optimization 3: Reusable JSON Encoder
    private lazy var jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    // MARK: - Response Envelope (for fallback decoding when typed decode fails)
    /// Mirrors the common server envelope (`status`, `message`, `error_type`) so we can
    /// recover a useful error message even when the inner `data` payload doesn't match
    /// the Swift model expected by the caller.
    private struct ResponseEnvelope: Decodable {
        var status: String?
        var message: String?
        var error_type: String?
    }

    /// Centralized decoder used by every request function.
    /// On success, returns the typed `T`.
    /// On failure, logs the full JSON + DecodingError, falls back to decoding the response
    /// envelope so the thrown `DataError.invalidCode` message is something humans can act on
    /// (server's own message, or a precise "Decoding mismatch at <path>: expected X, found Y"
    /// when the server returned `success` but the local model is out of date).
    private func decodeResponse<T: Decodable>(_ data: Data, as type: T.Type) throws -> T {
        do {
            return try jsonDecoder.decode(type, from: data)
        } catch let decodingError as DecodingError {
            // Always print so the dev can see the broken field even outside #if DEBUG.
            print("👉 Decoding failed for \(T.self):\n\(decodingError)")
            print("👉 Raw JSON was:\n\(data.prettyPrintedJSONString ?? "<non-JSON or empty>")")

            let decodingMessage = handleDecodingError(decodingError)

            // Try to recover the server's envelope so we can surface the *real* status/message
            // instead of a confusing "Decoding Error" string.
            if let envelope = try? jsonDecoder.decode(ResponseEnvelope.self, from: data) {
                if envelope.status?.lowercased() == "success" {
                    // Server said the call succeeded; the local model is out of sync with the API.
                    let msg = "Model out of sync with server. \(decodingMessage)"
                    print("👉 \(msg)")
                    throw DataError.invalidCode(msg)
                } else if let serverMessage = envelope.message, !serverMessage.isEmpty {
                    print("👉 Server reported error: \(serverMessage)")
                    throw DataError.invalidCode(serverMessage)
                }
            }

            throw DataError.invalidCode(decodingMessage)
        } catch {
            print("👉 Non-decoding error during response parse: \(error.localizedDescription)")
            throw DataError.invalidCode("Other Error: \(error.localizedDescription)")
        }
    }

    // MARK: - Main Request Function
    func request<T: Decodable>(type: EndPointType, header: Bool) async throws -> T {
        
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData // Enable caching
        
        if let parameters = type.body {
            request.httpBody = try? jsonEncoder.encode(parameters)
        }
        
        // CRASH FIX (cmp3z7e4400k54axyxucdv6qm): preserve Content-Type when adding
        // auth headers. The previous code replaced allHTTPHeaderFields entirely,
        // dropping "Content-Type: application/json" — causing Laravel to ignore
        // the JSON body (type/page params), returning unfiltered or empty data.
        request.allHTTPHeaderFields = type.headers
        
        if header {
            request.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
            request.setValue(deviceTimeZone, forHTTPHeaderField: "timezone")
            request.setValue(deviceTimeZone, forHTTPHeaderField: "time_zone")
        }
        
        #if DEBUG
        print("✅ URL: ====>\(url)")
        print("✅ METHOD: =====> \(type.method)")
        print("✅ BODY: =====> \(type.body ?? "")")
        print("✅ \(request.allHTTPHeaderFields as Any)")
        #endif
        
        let (data, response) = try await optimizedSession.data(for: request)
        
        #if DEBUG
        print("👉 API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
        #endif
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataError.invalidResponse(data)
        }
        
        // Handle status codes
        if httpResponse.statusCode == 401 {
            let dataObj = try jsonDecoder.decode(ApiError.self, from: data)
            await handleUnauthorized(data: data)
            if UserDefaults.accessToken.isEmpty{
                throw DataError.invalidCode(dataObj.message)
            }else{
                throw DataError.invalidCode("Unauthorized")
            }
        }
        
        guard (200...201).contains(httpResponse.statusCode) else {
            let dataObj = try jsonDecoder.decode(ApiError.self, from: data)
            
            if let message = dataObj.message {
                throw DataError.invalidCode(message)
            } else if let errors = dataObj.errors {
                if let emailError = errors.email { throw DataError.invalidCode(emailError) }
                if let passwordError = errors.password { throw DataError.invalidCode(passwordError) }
                throw DataError.invalidCode(errors.email)
            } else {
                throw DataError.invalidCode(dataObj.message)
            }
        }
        
        return try decodeResponse(data, as: T.self)
    }
    
    // MARK: - Request with JSON Body
    func requestWithJSONBody<T: Decodable>(
        type: EndPointType,
        parameters: [String: Any],
        modalType: T.Type,
        header: Bool
    ) async throws -> T {
        
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = jsonData
        
        if header {
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(UserDefaults.accessToken)",
                "timezone": "\(deviceTimeZone)",
                "time_zone": "\(deviceTimeZone)",
                "Content-Type": "application/json",
                "Accept": "application/json"
            ]
        } else {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        #if DEBUG
        print("Upload JSON API Request - - - - - - - - - - >>>>>")
        print("URL >> \(url)")
        print("Method >> \(type.method.rawValue)")
        print("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        print("Parameters >>> \(parameters)")
        #endif
        
        let (data, response) = try await optimizedSession.data(for: request)
        
        #if DEBUG
        print("API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
        #endif
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataError.invalidResponse(data)
        }
        
        if httpResponse.statusCode == 401 {
            await handleUnauthorized(data: data)
            throw DataError.invalidCode("Unauthorized")
        }
        
        guard (200...201).contains(httpResponse.statusCode) else {
            let dataObj = try jsonDecoder.decode(ApiError.self, from: data)
            
            if let message = dataObj.message {
                throw DataError.invalidCode(message)
            } else if let errors = dataObj.errors {
                if let emailError = errors.email { throw DataError.invalidCode(emailError) }
                if let passwordError = errors.password { throw DataError.invalidCode(passwordError) }
                throw DataError.invalidCode(errors.email)
            } else {
                throw DataError.invalidCode(dataObj.message)
            }
        }
        
        return try decodeResponse(data, as: T.self)
    }
    
    // MARK: - Upload Image
    func uploadImage<T: Decodable>(
        type: EndPointType,
        urlArray: [String]? = nil,
        mimeType: String,
        keyName: String,
        parameters: [String: Any],
        modalType: T.Type,
        header: Bool
    ) async throws -> T {
        
        #if DEBUG
        print("Upload File API Request - - - - - - - - - - >>>>>")
        #endif
        
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-store", forHTTPHeaderField: "Pragma")
        
        let boundary = generateBoundary()
        
        var media = [MediaData1]()
        urlArray?.forEach { url in
            guard let med = MediaData1(withURL: url, forKey: keyName, mimeType: mimeType) else {
                return
            }
            media.append(med)
        }
        
        if header {
            request.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let dataBody = createDataBody1(withParameters: parameters, media: media, boundary: boundary)
        request.httpBody = dataBody
        
        let (data, response) = try await optimizedSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataError.invalidResponse(data)
        }
        
        if httpResponse.statusCode == 401 {
            await handleUnauthorized(data: data)
            throw DataError.invalidCode("Unauthorized")
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let dataObj = try jsonDecoder.decode(ApiError.self, from: data)
            throw DataError.invalidCode(dataObj.message ?? "Upload failed")
        }
        
        return try decodeResponse(data, as: modalType)
    }
    
    // MARK: - Upload Image 1
    func uploadImage1<T: Decodable>(
        type: EndPointType,
        urlArray: [String]? = nil,
        mimeType: String,
        keyName: String,
        parameters: [String: Any],
        modalType: T.Type,
        header: Bool
    ) async throws -> T {
        
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-store", forHTTPHeaderField: "Pragma")
        
        var media = [MediaData1]()
        urlArray?.forEach { path in
            if let item = MediaData1(withURL: path, forKey: keyName, mimeType: mimeType) {
                media.append(item)
            }
        }
        
        let boundary = generateBoundary()
        let body = createDataBody1(withParameters: parameters, media: media, boundary: boundary)
        request.httpBody = body
        
        var headers = type.headers
        if header {
            headers?["Authorization"] = "Bearer \(UserDefaults.accessToken)"
            headers?["timezone"] = "\(deviceTimeZone)"
            headers?["time_zone"] = "\(deviceTimeZone)"
        }
        headers?["Accept"] = "application/json"
        headers?["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        request.allHTTPHeaderFields = headers
        
        let (data, response) = try await optimizedSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataError.invalidResponse(data)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            do {
                let decodedError = try jsonDecoder.decode(ApiError.self, from: data)
                throw DataError.invalidCode(decodedError.message ?? "Unknown server error")
            } catch {
                throw error
            }
        }
        
        return try decodeResponse(data, as: T.self)
    }
    
    // MARK: - Upload Image with Multiple Keys
    func uploadImageWithMultipleKeys<T: Decodable>(
        type: EndPointType,
        urlArray: [[String]]? = nil,
        mimeType: [String],
        keyName: [String],
        parameters: [String: Any]?,
        modelType: T.Type,
        header: Bool
    ) async throws -> T {
        
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-store", forHTTPHeaderField: "Pragma")
        
        let boundary = generateBoundary()
        
        var media = [MediaData1]()
        
        for (index, key) in keyName.enumerated() {
            urlArray?[index].forEach { url in
                if let med = MediaData1(withURL: url, forKey: key, mimeType: mimeType[index]) {
                    media.append(med)
                }
            }
        }
        
        request.allHTTPHeaderFields = type.headers
        if header {
            request.allHTTPHeaderFields = [
                "Authorization": "Bearer \(UserDefaults.accessToken)",
                "Accept": "application/json",
                "Content-Type": "multipart/form-data; boundary=\(boundary)"
            ]
        } else {
            request.allHTTPHeaderFields = [
                "Accept": "application/json",
                "Content-Type": "multipart/form-data; boundary=\(boundary)"
            ]
        }
        
        let dataBody = createDataBody1(withParameters: parameters, media: media, boundary: boundary)
        request.httpBody = dataBody
        
        let (data, response) = try await optimizedSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataError.invalidResponse(data)
        }
        
        if httpResponse.statusCode == 401 {
            await handleUnauthorized(data: data)
            throw DataError.invalidCode("Unauthorized")
        }
        
        guard (200...201).contains(httpResponse.statusCode) else {
            let dataObj = try jsonDecoder.decode(ApiError.self, from: data)
            
            if let message = dataObj.message {
                throw DataError.invalidCode(message)
            } else if let errors = dataObj.errors {
                if let emailError = errors.email { throw DataError.invalidCode(emailError) }
                if let passwordError = errors.password { throw DataError.invalidCode(passwordError) }
                throw DataError.invalidCode(errors.email)
            } else {
                throw DataError.invalidCode(dataObj.message)
            }
        }
        
        return try decodeResponse(data, as: T.self)
    }
    
    // MARK: - Upload Image with Multiple Keys 1
    func uploadImageWithMultipleKeys1<T: Decodable>(
        type: EndPointType,
        urlArray: [[String]]? = nil,
        mimeType: [String],
        keyName: [String],
        parameters: [String: Any],
        modelType: T.Type,
        header: Bool
    ) async throws -> T {
        
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        request.setValue("no-store", forHTTPHeaderField: "Pragma")
        
        let boundary = generateBoundary()
        var media = [MediaData1]()
        
        for (index, key) in keyName.enumerated() {
            urlArray?[index].forEach { url in
                if let med = MediaData1(withURL: url, forKey: key, mimeType: mimeType[index]) {
                    media.append(med)
                }
            }
        }
        
        let dataBody = createDataBody1(withParameters: parameters, media: media, boundary: boundary)
        request.httpBody = dataBody
        
        var headers = type.headers
        if header {
            headers?["Authorization"] = "Bearer \(UserDefaults.accessToken)"
        }
        headers?["Accept"] = "application/json"
        headers?["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        request.allHTTPHeaderFields = headers
        
        // Extended timeout for multiple files
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForResource = 300
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            do {
                let apiError = try jsonDecoder.decode(ApiError.self, from: data)
                if let message = apiError.message {
                    throw DataError.invalidCode(message)
                } else if let errors = apiError.errors {
                    if let emailError = errors.email { throw DataError.invalidCode(emailError) }
                    if let passwordError = errors.password { throw DataError.invalidCode(passwordError) }
                }
                throw DataError.invalidCode("Unknown error")
            } catch {
                throw error
            }
        }
        
        return try decodeResponse(data, as: T.self)
    }
    
    // MARK: - Helper: Handle Unauthorized
    @MainActor
    private func handleUnauthorized(data: Data) {
        guard !UserDefaults.accessToken.isEmpty,
              UserDefaults.accessToken != "",
              !APIManager.isShowingUnauthorizedAlert else {
            return
        }
        
        APIManager.isShowingUnauthorizedAlert = true
        
        do {
            let dataObj = try jsonDecoder.decode(ApiError.self, from: data)
            
            if dataObj.error_type == "UNAUTHORIZED" || dataObj.error_type == "invalid_token" {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                    
                    let message = dataObj.error_type == "UNAUTHORIZED"
                        ? "Your account has been logged in from another device"
                        : "Your account has been deleted or your session is no longer valid. Please log in again."
                    
                    let alert = UIAlertController(
                        title: "Session Expired",
                        message: message,
                        preferredStyle: .alert
                    )
                    
                    let loginAction = UIAlertAction(title: "Login", style: .default) { _ in
                        APIManager.isShowingUnauthorizedAlert = false
                        UserDefaults.accessToken = ""
                        rootVC.topMostViewController.dismiss(animated: true) {
                            NotificationCenter.default.post(name: .userSessionExpired, object: nil)
                        }
                    }
                    
                    alert.addAction(loginAction)
                    rootVC.topMostViewController.present(alert, animated: true, completion: nil)
                }
            }
        } catch {
            print("Failed to decode ApiError: \(error)")
            APIManager.isShowingUnauthorizedAlert = false
        }
    }
    
    // MARK: - Helper: Handle Decoding Error
    private func handleDecodingError(_ error: DecodingError) -> String {
        let kind: String
        let expected: String
        let context: DecodingError.Context

        switch error {
        case .typeMismatch(let type, let ctx):
            kind = "typeMismatch"
            expected = "\(type)"
            context = ctx
        case .valueNotFound(let type, let ctx):
            kind = "valueNotFound"
            expected = "\(type)"
            context = ctx
        case .keyNotFound(let key, let ctx):
            kind = "keyNotFound"
            expected = "key `\(key.stringValue)`"
            context = ctx
        case .dataCorrupted(let ctx):
            kind = "dataCorrupted"
            expected = "valid JSON"
            context = ctx
        @unknown default:
            return "Unknown Decoding Error: \(error)"
        }

        let path = context.codingPath
            .map { $0.intValue.map { "[\($0)]" } ?? $0.stringValue }
            .joined(separator: " -> ")
        let pathOut = path.isEmpty ? "<root>" : path
        return "Decoding \(kind) at \(pathOut) (expected \(expected)): \(context.debugDescription)"
    }
    
    // MARK: - Helper: Create Data Body
    private func createDataBody1(withParameters params: [String: Any]?, media: [MediaData1]?, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\("\(value)" + lineBreak)")
            }
        }
        
        if let media = media {
            for photo in media {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(photo.key)\"; filename=\"\(photo.fileName)\"\(lineBreak)")
                body.append("Content-Type: \(photo.mimeType + lineBreak + lineBreak)")
                body.append(photo.data)
                body.append(lineBreak)
            }
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    private func createDataBody1(withParameters params: [String: Any]?, media: MediaData1? = nil, boundary: String) -> Data {
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for (key, value) in parameters {
                body.append("--\(boundary + lineBreak)")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                body.append("\("\(value)" + lineBreak)")
            }
        }
        
        if let media = media {
            body.append("--\(boundary + lineBreak)")
            body.append("Content-Disposition: form-data; name=\"\(media.key)\"; filename=\"\(media.fileName)\"\(lineBreak)")
            body.append("Content-Type: \(media.mimeType + lineBreak + lineBreak)")
            body.append(media.data)
            body.append(lineBreak)
        }
        
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
    
    private func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    // MARK: - MediaData1
    struct MediaData1 {
        let key: String
        let fileName: String
        let data: Data
        let mimeType: String
        
        init?(withURL url: String?, forKey key: String, mimeType type: String) {
            guard let url = url else {
                print("❌ URL is nil.")
                return nil
            }
            
            let fileURL: URL
            if let u = URL(string: url), u.scheme == "file" {
                fileURL = u
            } else {
                fileURL = URL(fileURLWithPath: url)
            }
            
            guard FileManager.default.fileExists(atPath: fileURL.path) else {
                print("❌ File does not exist at path: \(fileURL.path)")
                return nil
            }
            
            do {
                self.data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
                self.key = key
                self.mimeType = type
                self.fileName = "\(UUID().uuidString).\(type.split(separator: "/").last ?? "jpg")"
            } catch {
                print("❌ Failed to load data from fileURL: \(fileURL), error: \(error.localizedDescription)")
                return nil
            }
        }
    }
}

// MARK: - APIManaging Extension
extension APIManager: APIManaging {
    func request<T: Decodable>(type: APIEndPoint, header: Bool) -> AnyPublisher<ResponseModel<T>, DataError> {
        Future { promise in
            Task {
                do {
                    let result: ResponseModel<T>? = try await self.request(type: type, header: header)
                    if let result = result {
                        promise(.success(result))
                    } else {
                        promise(.failure(DataError.invalidCode("Failed to get data")))
                    }
                } catch {
                    promise(.failure(DataError.invalidCode(error.localizedDescription)))
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}

// MARK: - ApiError
struct ApiError: Codable {
    var message: String?
    var error_type: String?
    var errors: errorTypes?
}

struct errorTypes: Codable {
    var email: String?
    var password: String?
}

// MARK: - Helper Functions
func getDeviceTimeZone() -> String {
    return TimeZone.current.identifier
}

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }
        return prettyPrintedString
    }
    
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
