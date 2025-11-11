//
//  DeepLinkManager.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 29/10/25.
//

import Foundation

final class DeepLinkManager: ObservableObject {
    
    @Published var destination: DeepLinkDestination? = nil
    
    func handle(url: URL) {
        print("Received URL: \(url.absoluteString)")
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        let path = components.path
        
        if path.starts(with: "/live-show=") {
            let id = path.replacingOccurrences(of: "/live-show", with: "")
            destination = .showDetail(id: id)
        }
    }
}

enum DeepLinkDestination: Hashable, Equatable {
    case showDetail(id: String)
    
    static func == (lhs: DeepLinkDestination, rhs: DeepLinkDestination) -> Bool {
        switch (lhs, rhs) {
        case (.showDetail(let lID), .showDetail(let rID)):
            return lID == rID
        }
    }
}
