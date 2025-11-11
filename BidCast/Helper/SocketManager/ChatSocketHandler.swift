//
//  ChatSocketHandler.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 29/10/25.
//

import Foundation

@MainActor
final class ChatSocketHandler: ObservableObject {
    @Published var chats: [CommentModel] = []

    private let base = BaseSocketManager.shared

    func sendChat(roomId: String, message: String, userId: Int, userName: String, userImage: String) {
        let payload: [String: Any] = [
            "room_id": roomId,
            "message": message,
            "user_id": "\(userId)",
            "user_name": userName,
            "user_image": userImage
        ]
        base.performIfConnected {
            base.socket.emit("chat", payload)
        }
    }

    func observeChat(forRoom roomId: String) {
        base.socket.on("chat_get") { [weak self] data, _ in
            guard let json = data.first as? [String: Any],
                  let self = self else { return }
            do {
                let decoded = try JSONSerialization.data(withJSONObject: json)
                let chat = try JSONDecoder().decode(CommentModel.self, from: decoded)

                guard chat.roomId == roomId else { return }

                DispatchQueue.main.async {
                    if !self.chats.contains(where: { $0.id == chat.id }) {
                        self.chats.append(chat)
                    }
                }

            } catch {
                self.base.logger.error("❌ Chat decode error: \(error.localizedDescription)")
            }
        }
    }
}
