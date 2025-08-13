//  Well Genius App
//
//  Created by Ankit-JAM-E-294 on 31/08/24.

import Foundation
import SVProgressHUD
import SwiftUICore

// Singleton Design Pattern
// final - inheritance nahi hoga theek hai final ho gya

enum DataError: Error {
    case invalidResponse(Data?)
    case invalidCode(String?)
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
        
        var request = URLRequest(url: url)
        
        request.httpMethod = type.method.rawValue
        
        if let parameters = type.body {
            request.httpBody = try? JSONEncoder().encode(parameters)
        }
        
        request.allHTTPHeaderFields = type.headers
        
        //        let deviceTimeZone = getDeviceTimeZone()
        if header{
            request.allHTTPHeaderFields = ["Authorization":"Bearer \(UserDefaults.accessToken)"]
        }
        
        
        print("URL: ====>\(url)")
        print("METHOD: =====> \(type.method)")
        print("BODY: =====> \(type.body ?? "")")
        print(request.allHTTPHeaderFields as Any)
        
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 120
        
        
        let (data, response) = try await URLSession(configuration: config).data(for: request)
        
        print(response)
        print("API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
        
        guard let response = response as? HTTPURLResponse,
              200 == response.statusCode || 201 == response.statusCode else {
            
            if let response = response as? HTTPURLResponse, 401 == response.statusCode {
                DispatchQueue.main.async {
                    do {
                        let dataObj = try JSONDecoder().decode(ApiError.self, from: data)
                        if dataObj.error_type == "UNAUTHORIZED" {
                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                               let rootVC = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                                
                                let alert = UIAlertController(
                                    title: "Session Expired",
                                    message: "Your account has been logged in from another device",
                                    preferredStyle: .alert
                                )
                                
                                let loginAction = UIAlertAction(title: "Login", style: .default) { _ in
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
                    }
                }
            }
            
            
            let dataObj = try JSONDecoder().decode(ApiError.self, from: data)
            print(dataObj)
            if let message = dataObj.message {
                throw DataError.invalidCode(message)
            }else if let errors = dataObj.errors{
                
                
                
                
                throw DataError.invalidCode(errors.email)
                throw DataError.invalidCode(errors.password)
            }else{
                throw DataError.invalidCode(dataObj.message)
            }
        }
        
        do {
            let json =  try JSONSerialization.jsonObject(with: data, options: [])
            print("Response JSon: ",json)
            let object = try JSONDecoder().decode(T.self, from: data)
            //            print(object)
            return object
        }
        catch let error {
            print(error)
            throw error//DataError.invalidResponse(data)
        }
    }
    
    func requestWithJSONBody<T: Decodable>(
        type: EndPointType,
        parameters: [String: Any],
        modalType: T.Type,
        header: Bool
    ) async throws -> T {
        
        print("Upload JSON API Request - - - - - - - - - - >>>>>")
        
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        
        // Encode parameters to JSON
        let jsonData = try JSONSerialization.data(withJSONObject: parameters, options: [])
        request.httpBody = jsonData
        
        // Headers
        if header {
            request.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("URL >> \(url)")
        print("Method >> \(type.method.rawValue)")
        print("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        print("Parameters >>> \(parameters)")
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        let (data, response) = try await URLSession(configuration: config).data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataError.invalidResponse(data)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            do {
                let dataObj = try JSONDecoder().decode(ApiError.self, from: data)
                print(dataObj)
                if let message = dataObj.message {
                    throw DataError.invalidCode(message)
                } else {
                    throw DataError.invalidCode(dataObj.message)
                }
            } catch {
                print("Error decoding error response: \(error)")
                throw DataError.invalidResponse(data)
            }
        }
        
        do {
            print("API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
            let decodedObject = try JSONDecoder().decode(modalType, from: data)
            return decodedObject
        } catch {
            print("Decoding error: \(error)")
            throw DataError.network(error)
        }
    }
    
    
    
    func topMostViewController() -> UIViewController? {
        guard let rootVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController else {
            return nil
        }
        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        return topVC
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
        print("Upload File API Request - - - - - - - - - - >>>>>")
        guard let url = type.url else {
            completion(.failure(.invalidURL))
            return
        }
        print("URL >> \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        print("Method >> \(type.method.rawValue)")
        
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
        
        print("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        
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
                    print("API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
                    let products = try JSONDecoder().decode(modelType, from: data)
                    completion(.success(products))
                }catch {
                    completion(.failure(.invalidResponse(data)))
                }
                return
            }
            do {
                
                print("API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
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
        print("Upload File API Request - - - - - - - - - - >>>>>")
        
        // Ensure the URL is valid
        guard let url = type.url else {
            completion(.failure(.invalidURL))
            return
        }
        
        print("URL >> \(url)")
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        print("Method >> \(type.method.rawValue)")
        
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
        print("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        
        // Configure URLSession
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 120
        
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
            
            print("API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
            
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
    
    
    
    //    func uploadImage<T: Decodable>(
    //        type: EndPointType,
    //        urlArray: [String]? = nil,
    //        mimeType: String,
    //        keyName: String,
    //        parameters: [String: Any],
    //        modelType: T.Type,
    //        header: Bool,
    //        completion: @escaping Handler<T>
    //    ) {
    //        print("Upload File API Request - - - - - - - - - - >>>>>")
    //        guard let url = type.url else {
    //            completion(.failure(.invalidURL))
    //            return
    //        }
    //        print("URL >> \(url)")
    //        var request = URLRequest(url: url)
    //        request.httpMethod = type.method.rawValue
    //        print("Method >> \(type.method.rawValue)")
    //
    //        let boundary = generateBoundary()
    //
    //        var media =  [MediaData1]()
    //
    //        urlArray?.forEach { url in
    //            if url.contains("media") {
    //                guard let med = MediaData1(withURL:"\(url)", forKey: keyName, mimeType: mimeType) else {
    //                    return }
    //                media.append(med)
    //            } else {
    //                guard let med = MediaData1(withURL: url, forKey: keyName, mimeType: mimeType) else {
    //                    return
    //                }
    //                media.append(med)
    //            }
    //        }
    //
    //        print(media as Any)
    //
    //        let params  = parameters
    //
    //        print(params)
    //
    //        request.allHTTPHeaderFields = type.headers
    //        if header {
    //            if header{
    //                request.allHTTPHeaderFields = ["Authorization":"Bearer \(UserDefaults.accessToken)"]
    //            }
    //        }
    //
    //        request.allHTTPHeaderFields = [ "Accept": "application/json",
    //            "Content-Type": "multipart/form-data; boundary=\(boundary)"
    //        ]
    //
    //        print(media as Any)
    //
    //        let dataBody = createDataBody1(withParameters: params, media: media, boundary: boundary)
    //
    //        request.httpBody = dataBody
    //
    //        print("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
    //
    //        print(request)
    //        let config = URLSessionConfiguration.default
    //        config.waitsForConnectivity = true
    //        config.timeoutIntervalForResource = 120
    //
    //        URLSession(configuration: config).dataTask(with: request) { data, response, error in
    //            print(response as Any)
    //            guard let data, error == nil else {
    //                completion(.failure(.invalidData))
    //                return
    //            }
    //            guard let response = response as? HTTPURLResponse,
    //                  200 ... 599 ~= response.statusCode else {
    //                do {
    //                    let products = try JSONDecoder().decode(modelType, from: data)
    //                    completion(.success(products))
    //                }catch {
    //                    completion(.failure(.invalidResponse(data)))
    //                }
    //                return
    //            }
    //            do {
    //                print("API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
    //                let products = try JSONDecoder().decode(modelType, from: data)
    //                completion(.success(products))
    //            }catch {
    //                completion(.failure(.network(error)))
    //            }
    //
    //        }.resume()
    //    }
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
        
        // Prepare multipart media
        var media = [MediaData1]()
        urlArray?.forEach { path in
            if let item = MediaData1(withURL: path, forKey: keyName, mimeType: mimeType) {
                media.append(item)
            }
        }
        
        let boundary = generateBoundary()
        let body = createDataBody1(withParameters: parameters, media: media, boundary: boundary)
        request.httpBody = body
        
        // Headers
        var headers = type.headers
        if header {
            headers?["Authorization"] = "Bearer \(UserDefaults.accessToken)"
        }
        headers?["Accept"] = "application/json"
        headers?["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        request.allHTTPHeaderFields = headers
        
        // Execute request
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        let (data, response) = try await URLSession(configuration: config).data(for: request)
        
        print("API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
        
        // Status check
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataError.invalidResponse(data)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            do {
                let decodedError = try JSONDecoder().decode(ApiError.self, from: data)
                
                throw DataError.invalidCode("Unknown server error")
            } catch {
                print(error)
                throw error
            }
        }
        
        // Decode final response
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            print("❌ Decoding error: \(error)")
            throw error
        }
    }
    
    func uploadImage<T: Decodable>(
        type: EndPointType,
        urlArray: [String]? = nil,
        mimeType: String,
        keyName: String,
        parameters: [String: Any],
        modalType: T.Type,
        header: Bool
    ) async throws -> T {
        print("Upload File API Request - - - - - - - - - - >>>>>")
        
        guard let url = type.url else {
            throw DataError.invalidURL
        }
        
        print("URL >> \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        print("Method >> \(type.method.rawValue)")
        
        let boundary = generateBoundary()
        
        var media = [MediaData1]()
        urlArray?.forEach { url in
            guard let med = MediaData1(withURL: url, forKey: keyName, mimeType: mimeType) else {
                return
            }
            print("✅ Loaded image at path: \(url)")
            media.append(med)
        }
        
        print(media)
        
        let params = parameters
        print(params)
        
        if header {
            request.setValue("Bearer \(UserDefaults.accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let dataBody = createDataBody1(withParameters: params, media: media, boundary: boundary)
        request.httpBody = dataBody
        
        print("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        
        let (data, response) = try await URLSession(configuration: config).data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw DataError.invalidResponse(data)
        }
        
        if !(200...299).contains(httpResponse.statusCode) {
            do {
                let dataObj = try JSONDecoder().decode(ApiError.self, from: data)
                print(dataObj)
                if let message = dataObj.message {
                    throw DataError.invalidCode(message)
                    
                }else{
                    throw DataError.invalidCode(dataObj.message)
                }
            } catch {
                print("Error decoding error response: \(error)")
                throw DataError.invalidResponse(data)
            }
        }
        
        do {
            print("API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
            let decodedObject = try JSONDecoder().decode(modalType, from: data)
            return decodedObject
        } catch {
            print("Decoding error: \(error)")
            throw DataError.network(error)
        }
    }
    
    
    func uploadImageWithMultipleKeys<T: Decodable>(
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
        
        let config = URLSessionConfiguration.default
        config.waitsForConnectivity = true
        config.timeoutIntervalForResource = 300
        
        let (data, response) = try await URLSession(configuration: config).data(for: request)
        
        print("API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
        
        guard let httpResponse = response as? HTTPURLResponse,
              200...299 ~= httpResponse.statusCode else {
            do {
                let apiError = try JSONDecoder().decode(ApiError.self, from: data)
                if let message = apiError.message {
                    throw DataError.invalidCode(message)
                } else if let errors = apiError.errors {
                    if ((errors.email?.isEmpty) == nil) {
                        throw DataError.invalidCode(errors.email)
                    }
                    if ((errors.password?.isEmpty) == nil) {
                        throw DataError.invalidCode(errors.password)
                    }
                }
                throw DataError.invalidCode("Unknown error")
            } catch {
                throw error
            }
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
    
    
    
    func uploadImageWithMultipleKeys1<T: Decodable>(
        type: EndPointType,
        urlArray: [[String]]? = nil,
        mimeType: [String],
        keyName: [String],
        parameters: [String: Any],
        modelType: T.Type,
        header: Bool,
        completion: @escaping Handler<T>
    ) {
        print("Upload File API Request - - - - - - - - - - >>>>>")
        guard let url = type.url else {
            completion(.failure(.invalidURL))
            return
        }
        print("URL >> \(url)")
        var request = URLRequest(url: url)
        request.httpMethod = type.method.rawValue
        print("Method >> \(type.method.rawValue)")
        
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
        
        print(media as Any)
        
        let params  = parameters
        
        print(params)
        
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
        
        print(media as Any)
        
        let dataBody = createDataBody1(withParameters: params, media: media, boundary: boundary)
        
        request.httpBody = dataBody
        
        print("Headers >>> \(request.allHTTPHeaderFields ?? [:])")
        
        print(request)
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
                print("API Response >>> \n\(data.prettyPrintedJSONString ?? "")")
                let products = try JSONDecoder().decode(modelType, from: data)
                completion(.success(products))
            }catch {
                completion(.failure(.network(error)))
            }
            
        }.resume()
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
                self.data = try Data(contentsOf: fileURL, options: .alwaysMapped)
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

struct ApiError:Codable {
    var message :String?
    var error_type: String?
    var errors:errorTypes?
}

struct errorTypes:Codable{
    var email: String?
    var password : String?
}

func getDeviceTimeZone() -> String {
    let timeZone = TimeZone.current
    return timeZone.identifier
}

extension Data {
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
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

