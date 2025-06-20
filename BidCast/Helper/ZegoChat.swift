//
//  ZegoChat.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 19/06/25.
//



//import Foundation
//import ZIM
//
//class ZegoChatManager: NSObject {
//    
//    static let shared = ZegoChatManager()
//    private var zim: ZIM?
//    
//    // MARK: - Initialize and Login
//    func initialize(appID: UInt32, userID: String, userName: String) {
//        let config = ZIMAppConfig()
//        config.appID = appID
//
//        zim = ZIM.create(with: config)
//        zim?.setEventHandler(self)
//
//        let user = zim?.ZIMUser()
//        user.userID = userID
//        user.userName = userName
//
//        zim?.login(with: user, config: nil) { userInfo, error in
//            if let error = error {
//                print("❌ ZIM Login failed: \(error.code), \(error.message ?? "")")
//            } else {
//                print("✅ ZIM Login success: \(userInfo.userID)")
//            }
//        }
//    }
//    
//    // MARK: - Join Room
//    func joinRoom(roomID: String) {
//        let config = ZIMRoomConfig()
//        zim?.enterRoom(with: roomID, config: config) { roomInfo, error in
//            if let error = error {
//                print("❌ Enter room failed: \(error.code), \(error.message ?? "")")
//            } else {
//                print("✅ Joined room: \(roomInfo?.roomID ?? "")")
//            }
//        }
//    }
//
//    // MARK: - Send Message
//    func sendMessage(_ text: String, toRoom roomID: String) {
//        let message = ZIMTextMessage(content: text)
//        zim?.sendRoomMessage(message, toRoom: roomID, config: nil) { message, error in
//            if let error = error {
//                print("❌ Message send failed: \(error.code), \(error.message ?? "")")
//            } else {
//                print("✅ Message sent: \(text)")
//            }
//        }
//    }
//
//    // MARK: - Logout
//    func logout() {
//        zim?.logout { error in
//            if let error = error {
//                print("⚠️ Logout error: \(error.message ?? "")")
//            } else {
//                print("🔒 Logged out")
//            }
//        }
//        ZIM.destroy()
//    }
//}
//
//
//extension ZegoChatManager: ZIMEventHandler {
//    
//    func zim(_ zim: ZIM, receiveRoomMessage messageList: [ZIMMessage], fromRoom roomID: String) {
//        for message in messageList {
//            if let textMsg = message as? ZIMTextMessage {
//                print("📩 Received in room \(roomID): \(textMsg.content)")
//                // You can now update your chat UI
//            }
//        }
//    }
//}
