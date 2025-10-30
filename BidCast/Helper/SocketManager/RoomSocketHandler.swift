//
//  RoomSocketHandler.swift
//  BidCast
//
//  Created by JamTech on 29/10/25.
//
 
import Foundation

@MainActor
final class RoomSocketHandler: ObservableObject {
    @Published private(set) var rooms: [RoomModel] = []

    private let base = BaseSocketManager.shared

    func createRoom(_ payload: [String: Any]) {
        base.performIfConnected {
            base.socket.emit("room_create", payload)
            base.logger.info("📡 Creating room: \(payload)")
        }
    }

    func observeRoomUpdates(onUpdate: @escaping (RoomModel) -> Void) {
        base.performIfConnected {
            base.socket.on("room_create_get") { [weak self] data, _ in
                guard let json = data.first as? [String: Any],
                      let self = self else { return }
                do {
                    let decoded = try JSONSerialization.data(withJSONObject: json)
                    let room = try JSONDecoder().decode(RoomModel.self, from: decoded)

                    if !self.rooms.contains(where: { $0.room_id == room.room_id }) {
                        self.rooms.append(room)
                    }

                    DispatchQueue.main.async {
                        onUpdate(room)
                    }
                    self.base.logger.info("✅ Room updated: \(room.room_id ?? "")")

                } catch {
                    self.base.logger.error("❌ Room decode error: \(error.localizedDescription)")
                }
            }
        }
    }

    func joinRoom(_ roomId: String, userId: Int, completion: @escaping () -> Void) {
        let payload:[String : Any] = ["room_id": roomId, "user_id": userId]
        base.performIfConnected {
            base.socket.emit("join_room", payload)
            base.logger.info("📡 Joined room \(roomId)")
            completion()
        }
    }

    func leaveRoom(_ roomId: String, userId: Int) {
        let payload: [String : Any] = ["room_id": roomId, "user_id": userId]
        base.performIfConnected {
            base.socket.emit("leave_room", payload)
            base.logger.info("📡 Left room \(roomId)")
        }
    }
}
