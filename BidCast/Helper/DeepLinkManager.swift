//
//  DeepLinkManager.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 29/10/25.
//

import Foundation

final class DeepLinkManager: ObservableObject {
    
    @Published var destination: DeepLinkDestination? = nil
    @Published var liveShowId: String? = nil
    
    func handle(url: URL) {
        print("🔗 Received URL: \(url.absoluteString)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("❌ Failed to parse URL components")
            return
        }
        
        let path = components.path
        
        // Handle /live-show path
        if path.starts(with: "/live-show") {
            // Check for roomid query parameter
            if let queryItems = components.queryItems,
               let roomIdItem = queryItems.first(where: { $0.name == "roomid" }),
               let roomId = roomIdItem.value {
                print("✅ Parsed roomId: \(roomId)")
                destination = .showDetail(id: roomId)
            }
            // Fallback: parse from path if no query param
            else {
                let id = path.replacingOccurrences(of: "/live-show=", with: "")
                    .replacingOccurrences(of: "/live-show", with: "")
                print("✅ Parsed id from path: \(id)")
                destination = .showDetail(id: id)
            }
        }
        // Handle show detail path (alternative format)
        else if path.starts(with: "/show/") {
            let components = path.components(separatedBy: "/")
            if components.count > 2 {
                let showId = components[2]
                print("✅ Parsed showId: \(showId)")
                destination = .showDetail(id: showId)
            }
        }
    }
    func openLiveShow(id: String) {
            DispatchQueue.main.async {
                self.liveShowId = id
            }
        }

        func reset() {
            liveShowId = nil
        }
    
    /// Clear current destination
    func clearDestination() {
        destination = nil
    }
    
    /// Generate share URL for live show
    static func generateLiveShowURL(roomId: String) -> URL {
        return URL(string: "https://www.backend.bidcast.betaplanets.com/live-show?roomid=\(roomId)")!
    }
    
    /// Generate share URL with show ID and user ID (alternative format)
    static func generateShowURL(showId: Int, userId: Int) -> URL {
        return URL(string: "https://www.backend.bidcast.betaplanets.com/show/\(showId)?user=\(userId)")!
    }
}

enum DeepLinkDestination: Hashable, Equatable {
    case showDetail(id: String)
    case kycResult(status: KycStatus)

    static func == (lhs: DeepLinkDestination, rhs: DeepLinkDestination) -> Bool {
        switch (lhs, rhs) {
        case (.showDetail(let lID), .showDetail(let rID)):
            return lID == rID

        case (.kycResult(let lStatus), .kycResult(let rStatus)):
            return lStatus == rStatus

        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .showDetail(let id):
            hasher.combine("showDetail")
            hasher.combine(id)

        case .kycResult(let status):
            hasher.combine("kycResult")
            hasher.combine(status.rawValue)
        }
    }
}

enum KycStatus: String {
    case success
    case failed
    case pending
}



//import Foundation
//
//final class DeepLinkManager: ObservableObject {
//
//    @Published var destination: DeepLinkDestination? = nil
//
//    func handle(url: URL) {
//        print("Received URL: \(url.absoluteString)")
//
//        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
//        let path = components.path
//
//        if path.starts(with: "/live-show=") {
//            let id = path.replacingOccurrences(of: "/live-show", with: "")
//            destination = .showDetail(id: id)
//        }
//    }
//}
//
//enum DeepLinkDestination: Hashable, Equatable {
//    case showDetail(id: String)
//
//    static func == (lhs: DeepLinkDestination, rhs: DeepLinkDestination) -> Bool {
//        switch (lhs, rhs) {
//        case (.showDetail(let lID), .showDetail(let rID)):
//            return lID == rID
//        }
//    }
//}
