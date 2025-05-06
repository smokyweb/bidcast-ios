//  BidCast
//
//  Created by Abdul-JAM-E-157 on 31/08/24.

import Foundation

enum HTTPMethods: String {
    case get = "GET"
    case post = "POST"
}

enum APIResponseStatus: String  {
    case success = "success"
    case failure = "failed"
}

protocol EndPointType {
    var path: String { get }
    var baseURL: String { get }
    var url: URL? { get }
    var method: HTTPMethods { get }
    var body: Encodable? { get }
    var headers: [String: String]? { get }
}

enum Event {
    case loading
    case stopLoading
    case dataLoaded
    case error(Error?)
}
