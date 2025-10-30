//
//  ChatSocketHandler.swift
//  BidCast
//
//  Created by JamTech on 29/10/25.
//

import Foundation

@MainActor
final class RaidSocketHandler {
    private let base = BaseSocketManager.shared

    func sendRaidEvent(sourceRoomId: String, targetRoomId: String, sourceHostId: String, targetHostId: String) {
        let payload = [
            "source_room_id": sourceRoomId,
            "target_room_id": targetRoomId,
            "source_host_id": sourceHostId,
            "target_host_id": targetHostId
        ]
        base.socket.emit("createRaid", payload)
        print("📤 Sent createRaid:", payload)
    }

    func listenForRaidEvent(completion: @escaping (RaidInfo?) -> Void) {
        base.socket.on("receiveRaid") { data, _ in
            guard let json = data.first as? [String: Any] else {
                completion(nil)
                return
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json)
                let raidInfo = try JSONDecoder().decode(RaidInfo.self, from: jsonData)
                completion(raidInfo)
            } catch {
                print("❌ Failed to decode RaidInfo:", error)
                completion(nil)
            }
        }
    }
}

