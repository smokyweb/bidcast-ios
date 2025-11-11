//
//  ChatSocketHandler.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 29/10/25.
//

import Foundation

@MainActor
final class ViewerSocketHandler: ObservableObject {
    @Published var viewerCount: Int = 0
    private let base = BaseSocketManager.shared

    func listenForViewerCount() {
        base.socket.on("viewerCount") { [weak self] data, _ in
            guard let self else { return }
            if let json = data.first as? [String: Any],
               let count = json["count"] as? Int {
                viewerCount = count
            } else if let count = data.first as? Int {
                viewerCount = count
            } else {
                base.logger.warning("❌ Invalid viewerCount payload: \(data)")
            }
        }
    }
}

