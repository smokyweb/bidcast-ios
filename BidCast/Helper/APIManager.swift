//  Well Genius App
//
//  Created by Vivek-JAM-E-328 on 31/08/24.

import Foundation
import SVProgressHUD

// Singleton Design Pattern
// final - inheritance nahi hoga theek hai final ho gya

enum DataError: Error {
    case invalidResponse(Data?)
    case invalidCode(String?)
    case errorMessage(String?)
    case invalidURL
    case invalidData
    case network(Error?)
    case networkError
    case failedToDecode
}

typealias Handler<T> = (Result<T, DataError>) -> Void

final class APIManager {
    
    static var commonHeaders: [String: String] {
        return [
            "Content-Type": "application/json"
        ]
    }
    
    static let shared = APIManager()

    
    func request<T: Decodable>(type: EndPointType, header: Bool) async throws ->  T {
        
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        debugLog("URL: ====>\(url)")
        debugLog("METHOD: =====> \(type.method)")
        debugLog("BODY: =====> \(type.body)")
        var request = URLRequest(url: url)
        
        request.httpMethod = type.method.rawValue
        
        if let parameters = type.body {
            request.httpBody = try? JSONEncoder().encode(parameters)
        }
        
        request.allHTTPHeaderFields = type.headers
        
        let deviceTimeZone = getDeviceTimeZone()
        if header{
            debugLog("Token: \(UserDefaults.accessToken)")
            request.allHTTPHeaderFields = ["Authorization":"Bearer \(UserDefaults.accessToken)","time_zone":"\(deviceTimeZone)"]
        }
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 240
        
        
        let (data, response) = try await URLSession(configuration: config).data(for: request)
        
        debugLog(response)
        debugLog("API Response >>> \n")
        debugLog(data.prettyPrintedJSONString ?? "")
        
        guard let response = response as? HTTPURLResponse,
              200 ... 299 ~= response.statusCode else {
            let dataObj = try JSONDecoder().decode(ApiError.self, from: data)
            debugLog(dataObj)
            throw DataError.invalidCode(dataObj.message)
        }
        do {
            let object = try JSONDecoder().decode(T.self, from: data)
            debugLog(object)
            return object
        }
        catch let error as DecodingError {
            switch error {
            case .typeMismatch(_, let context),
                 .valueNotFound(_, let context),
                 .keyNotFound(_, let context),
                 .dataCorrupted(let context):
                
                // Extract the coding path (which contains "data" and "created_by")
                let codingKeys = context.codingPath.map { $0.stringValue }.joined(separator: " -> ")
                
                print("Decoding Error: \(context.debugDescription)")
                print("Coding Path: \(codingKeys)")
                throw DataError.invalidCode("Decoding Error: \(context.debugDescription), Path: \(codingKeys)")
            @unknown default:
                print("Unknown Decoding Error: \(error)")
                throw DataError.invalidCode("Unknown Decoding Error: \(error)")
            }
        } catch {
            print("Other Error: \(error.localizedDescription)")
            throw DataError.invalidCode("Other Error: \(error.localizedDescription)")
        }
    }
    
    
    func uploadMedia<T: Decodable>(
        type: EndPointType,
        urlArray: String,
        mimeType: String,
        parameters: [String: Any],
        modelType: T.Type,
        header: Bool,
        completion: @escaping Handler<T>
    ) {
        debugLog("Upload File API Request - - - - - - - - - - >>>>>")
        guard let url = type.url else {
            completion(.failure(.invalidURL))
            return
        }
        debugLog("URL >> \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        debugLog("Method >> \(type.method.rawValue)")
        
        let boundary = generateBoundary()
        
        var media: MediaData1?
        
        guard let med = MediaData1(withURL: urlArray, forKey: "media", mimeType: mimeType) else {
            return
        }
        media = med
        
        let params  = parameters
        
        
        
        request.allHTTPHeaderFields = type.headers
        if header {
            if header{
                request.allHTTPHeaderFields = ["Authorization":"Bearer \(UserDefaults.accessToken)"]
            }
        }
        
        request.allHTTPHeaderFields = [
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
        
        let dataBody = createDataBody1(withParameters: params, media: media, boundary: boundary)
        
        request.httpBody = dataBody
        
        debugLog("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 240
        
        URLSession(configuration: config).dataTask(with: request) { data, response, error in
            guard let data, error == nil else {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  200 ... 599 ~= response.statusCode else {
                do {
                    debugLog("API Response >>> \n")
                    debugLog(data.prettyPrintedJSONString ?? "")
                    let products = try JSONDecoder().decode(modelType, from: data)
                    completion(.success(products))
                }catch {
                    completion(.failure(.invalidResponse(data)))
                }
                return
            }
            do {
                
                debugLog("API Response >>> \n")
                debugLog(data.prettyPrintedJSONString ?? "")
                let products = try JSONDecoder().decode(modelType, from: data)
                completion(.success(products))
            }catch {
                completion(.failure(.network(error)))
            }
            
        }.resume()
    }
    
    func uploadFile<T: Decodable>(
        type: EndPointType,
        urlArray: String? = nil,
        mimeType: String,
        keyName: String,
        parameters: [String: Any],
        modelType: T.Type,
        header: Bool,
        completion: @escaping Handler<T>
    ) {
        debugLog("Upload File API Request - - - - - - - - - - >>>>>")
        
        // Ensure the URL is valid
        guard let url = type.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        debugLog("URL >> \(url)")
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        debugLog("Method >> \(type.method.rawValue)")
        
        // Generate boundary for multipart/form-data
        let boundary = generateBoundary()
        request.allHTTPHeaderFields = type.headers ?? [:]
        
        // Set authorization header if needed
        if header {
            request.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Prepare media data
        guard let media = MediaData1(withURL: urlArray, forKey: keyName, mimeType: mimeType) else {
            completion(.failure(.invalidData))
            return
        }
        
        // Prepare body data
        let dataBody: Data
        if let urlArray = urlArray {
            dataBody = createDataBody1(withParameters: parameters, media: media, boundary: boundary)
        } else {
            dataBody = createDataBody1(withParameters: parameters, boundary: boundary)
        }
        
        request.httpBody = dataBody
        debugLog("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        
        // Configure URLSession
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 240
        
        // Create data task
        let task = URLSession(configuration: config).dataTask(with: request) { data, response, error in
            // Handle error
            if let error = error {
                completion(.failure(.network(error)))
                return
            }
            
            // Ensure we have data
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            // Check for valid response
            guard let response = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse(data)))
                return
            }
            
            debugLog("API Response >>> \n")
            debugLog(data.prettyPrintedJSONString ?? "")
            
            // Decode the response
            do {
                let products = try JSONDecoder().decode(modelType, from: data)
                completion(.success(products))
            } catch {
                completion(.failure(.invalidResponse(data)))
            }
        }
        
        // Start the task
        task.resume()
    }

    func uploadImageforDifferentKey<T: Decodable>(
        type: EndPointType,
        urlArray: [ImageModel]? = nil,
        parameters: [String: Any],
        modelType: T.Type,
        header: Bool,
        completion: @escaping Handler<T>
    ) {
        debugLog("Upload File API Request - - - - - - - - - - >>>>>")
        guard let url = type.url else {
            completion(.failure(.invalidURL))
            return
        }
        debugLog("URL >> \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        debugLog("Method >> \(type.method.rawValue)")
        
        let boundary = generateBoundary()
        
        var media =  [MediaData1]()

        urlArray?.forEach { img in
            if img.url.contains("media") {
                guard let med = MediaData1(withURL:"\(img.url)", forKey: img.keyName, mimeType: img.mimeType) else {
                    return }
                media.append(med)
            } else {
                guard let med = MediaData1(withURL: img.url, forKey: img.keyName, mimeType: img.mimeType) else {
                    return
                }
                
                media.append(med)
                
            }
        }
        
        debugLog(media as Any)
   
        let params  = parameters
        
        debugLog(params)
        
        request.allHTTPHeaderFields = type.headers
        if header {
            if header{
                request.allHTTPHeaderFields = ["Authorization":"Bearer \(UserDefaults.accessToken)"]
            }
        }
        
        request.allHTTPHeaderFields = [
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
        
        debugLog(media as Any)
        
        let dataBody = createDataBody1(withParameters: params, media: media, boundary: boundary)
        
        request.httpBody = dataBody
        
        debugLog("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        
        debugLog(request)
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 120
        
        URLSession(configuration: config).dataTask(with: request) { data, response, error in
            guard let data, error == nil else {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  200 ... 599 ~= response.statusCode else {
                do {
                    let products = try JSONDecoder().decode(modelType, from: data)
                    completion(.success(products))
                }catch {
                    completion(.failure(.invalidResponse(data)))
                }
                return
            }
            do {
                debugLog("API Response >>> \n")
                debugLog(data.prettyPrintedJSONString ?? "")
                let products = try JSONDecoder().decode(modelType, from: data)
                completion(.success(products))
            }catch {
                completion(.failure(.network(error)))
            }
            
        }.resume()
    }
    
    
    
    func uploadImage<T: Decodable>(
        type: EndPointType,
        urlArray: [String]? = nil,
        mimeType: String,
        keyName: String,
        parameters: [String: Any],
        modelType: T.Type,
        header: Bool,
        completion: @escaping Handler<T>
    ) {
        debugLog("Upload File API Request - - - - - - - - - - >>>>>")
        guard let url = type.url else {
            completion(.failure(.invalidURL))
            return
        }
        debugLog("URL >> \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        debugLog("Method >> \(type.method.rawValue)")
        
        let boundary = generateBoundary()
        
        var media =  [MediaData1]()

        urlArray?.forEach { url in
            if url.contains("media") {
                guard let med = MediaData1(withURL:"\(url)", forKey: keyName, mimeType: mimeType) else {
                    return }
                media.append(med)
            } else {
                guard let med = MediaData1(withURL: url, forKey: keyName, mimeType: mimeType) else {
                    return
                }
                
                media.append(med)
                
            }
        }
        
        debugLog(media as Any)
   
        let params  = parameters
        
        debugLog(params)
        
        request.allHTTPHeaderFields = type.headers
        if header {
            if header{
                request.allHTTPHeaderFields = ["Authorization":"Bearer \(UserDefaults.accessToken)"]
            }
        }
        
        request.allHTTPHeaderFields = [
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
        
        debugLog(media as Any)
        
        let dataBody = createDataBody1(withParameters: params, media: media, boundary: boundary)
        
        request.httpBody = dataBody
        
        debugLog("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        
        debugLog(request)
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 120
        
        URLSession(configuration: config).dataTask(with: request) { data, response, error in
            guard let data, error == nil else {
                completion(.failure(.invalidData))
                return
            }
            guard let response = response as? HTTPURLResponse,
                  200 ... 599 ~= response.statusCode else {
                do {
                    let products = try JSONDecoder().decode(modelType, from: data)
                    completion(.success(products))
                }catch {
                    completion(.failure(.invalidResponse(data)))
                }
                return
            }
            do {
                debugLog("API Response >>> \n")
                debugLog(data.prettyPrintedJSONString ?? "")
                let products = try JSONDecoder().decode(modelType, from: data)
                completion(.success(products))
            }catch {
                completion(.failure(.network(error)))
            }
            
        }.resume()
    }
    
    
    
    func uploadImageWithMultipleKeys<T: Decodable>(
        type: EndPointType,
        urlArray: [[String]]? = nil,
        mimeType: [String],
        keyName: [String],
        parameters: [String: Any]?,
        modelType: T.Type,
        header: Bool
    ) async throws -> T  {
        debugLog("Upload File API Request - - - - - - - - - - >>>>>")
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        debugLog("URL >> \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        debugLog("Method >> \(type.method.rawValue)")
        
        let boundary = generateBoundary()
        
        var media =  [MediaData1]()
        
        for (index,key) in keyName.enumerated()  {
            urlArray?[index].forEach { url in
                if url.contains("media") {
                    guard let med = MediaData1(withURL:"\(url)", forKey: key, mimeType: mimeType[index]) else {
                        return }
                    media.append(med)
                } else {
                    guard let med = MediaData1(withURL: url, forKey: key, mimeType: mimeType[index]) else {
                        return
                    }
                    
                    media.append(med)
                }
            }
        }

        debugLog(media as Any)
   
        let params  = parameters
        
        debugLog(params)
        
        request.allHTTPHeaderFields = type.headers
        if header {
            if header{
                debugLog("Access Token >>>> \(UserDefaults.accessToken)")
                request.allHTTPHeaderFields = ["Authorization":"Bearer \(UserDefaults.accessToken)"]
            }
        }
        
        request.allHTTPHeaderFields = [
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
        
        debugLog(media as Any)
        
        let dataBody = createDataBody1(withParameters: params, media: media, boundary: boundary)
        
        request.httpBody = dataBody
        
        debugLog("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        
        debugLog(request)
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 120
        
        let (data, response) = try await URLSession(configuration: config).data(for: request)
        debugLog("response >>> \(response)")
        debugLog("API Response >>> \n")
        debugLog(data.prettyPrintedJSONString ?? "")
        
        guard let response = response as? HTTPURLResponse,
              200 ... 599 ~= response.statusCode else {
            let dataObj = try JSONDecoder().decode(ApiError.self, from: data)
            debugLog(dataObj)
            throw DataError.invalidCode(dataObj.message)
        }
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            debugLog("jsonData: \(jsonData)")
            let object = try JSONDecoder().decode(T.self, from: data)
            debugLog("decoded data: \(object)")
            return object
        }
        catch let error {
            throw error//DataError.invalidResponse(data)
        }
        
    }

    
    func uploadImageWithMultipleKeys<T: Decodable>(
        type: EndPointType,
        urlArray: [[String]]? = nil,
        mimeType: [String],
        keyName: [String],
        parameters: [[String: Any]]?,
        modelType: T.Type,
        header: Bool
    ) async throws -> T  {
        debugLog("Upload File API Request - - - - - - - - - - >>>>>")
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        debugLog("URL >> \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        debugLog("Method >> \(type.method.rawValue)")
        
        let boundary = generateBoundary()
        
        var media =  [MediaData1]()
        
        for (index,key) in keyName.enumerated()  {
            urlArray?[index].forEach { url in
                if url.contains("media") {
                    guard let med = MediaData1(withURL:"\(url)", forKey: key, mimeType: mimeType[index]) else {
                        return }
                    media.append(med)
                } else {
                    guard let med = MediaData1(withURL: url, forKey: key, mimeType: mimeType[index]) else {
                        return
                    }
                    
                    media.append(med)
                }
            }
        }

        debugLog(media as Any)
   
        let params  = parameters
        
        debugLog(params)
        
        request.allHTTPHeaderFields = type.headers
        if header {
            if header{
                debugLog("Access Token >>>> \(UserDefaults.accessToken)")
                request.allHTTPHeaderFields = ["Authorization":"Bearer \(UserDefaults.accessToken)"]
            }
        }
        
        request.allHTTPHeaderFields = [
            "Accept": "application/json",
            "Content-Type": "multipart/form-data; boundary=\(boundary)"
        ]
        
        debugLog(media as Any)
        
        let dataBody = createDataBody1(withParameters: params, media: media, boundary: boundary)
        
        request.httpBody = dataBody
        
        debugLog("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        
        debugLog(request)
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 120
        
        let (data, response) = try await URLSession(configuration: config).data(for: request)
        debugLog("response >>> \(response)")
        debugLog("API Response >>> \n")
        debugLog(data.prettyPrintedJSONString ?? "")
        
        guard let response = response as? HTTPURLResponse,
              200 ... 599 ~= response.statusCode else {
            let dataObj = try JSONDecoder().decode(ApiError.self, from: data)
            debugLog(dataObj)
            throw DataError.invalidCode(dataObj.message)
        }
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data, options: [])
            debugLog("jsonData: \(jsonData)")
            let object = try JSONDecoder().decode(T.self, from: data)
            debugLog("decoded data: \(object)")
            return object
        }
        catch let error {
            throw error//DataError.invalidResponse(data)
        }
        
    }
    
    func createDataBody1(withParameters params: [String: Any]?, media: [MediaData1]?, boundary: String) -> Data {
        
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
    
    
    func createDataBody1(withParameters params: [[String: Any]]?, media: [MediaData1]?, boundary: String) -> Data {
        
        let lineBreak = "\r\n"
        var body = Data()
        
        if let parameters = params {
            for item in parameters {
                for (key, value) in item {
                    body.append("--\(boundary + lineBreak)")
                    body.append("Content-Disposition: form-data; name=\"\(key)\"\(lineBreak + lineBreak)")
                    body.append("\("\(value)" + lineBreak)")
                }
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
    
    
    func createDataBody1(withParameters params: [String: Any]?, media: MediaData1? = nil, boundary: String) -> Data {
        
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
        //        let boundaryLineBreak = "--\(boundary)--\(lineBreak)"
        //        if let boundaryLineBreakData = boundaryLineBreak.data(using: .utf8) {
        //            body.append(boundaryLineBreakData)
        //        }
        
        return body
    }
    
    func generateBoundary() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
    
    struct MediaData1 {
        let key: String
        let fileName: String
        let data: Data
        let mimeType: String
        
        init?(withURL url: String?, forKey key: String, mimeType type: String) {
            self.key = key
            self.mimeType = type
            self.fileName = "\(arc4random()).\(type.split(separator: "/").last ?? "")"
            if let url = url {
                do {
                    self.data = try Data(contentsOf: URL(string: url)!, options: Data.ReadingOptions.alwaysMapped)
                } catch _ {
                    self.data = Data()
                }
            }else{
                self.data = Data()
            }
        }
    }

}

struct ApiError:Codable {
    var status = ""
    var message = ""
    var error_type = ""
}

func getDeviceTimeZone() -> String {
    let timeZone = TimeZone.current
    return timeZone.identifier
}

