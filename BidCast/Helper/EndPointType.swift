//
//  EndPointType.swift
//  Youtube MVVM Products
//
//  Created by Yogesh Patel on 25/12/22.
//

import Foundation

enum HTTPMethods: String {
    case get = "GET"
    case post = "POST"
//    case delete = "DELETE"
}

protocol EndPointType {
    var path: String { get }
    var baseURL: String { get }
    var url: URL? { get }
    var method: HTTPMethods { get }
    var body: Encodable? { get }
	var jsonBody : [String:Any]? {get}
    var headers: [String: String]? { get }
}
enum Event {
    case loading
    case stopLoading
    case dataLoaded
    case error(Error?)
}
