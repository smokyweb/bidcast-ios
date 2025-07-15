//  ZegoChat.swift
//  BidCast

import Foundation
import ZIM
import ZegoExpressEngine

class ZIMChatManager: NSObject, ObservableObject {
    
        static let shared = ZIMChatManager()
    
        private var zim: ZIM?
        @Published var messages: [Comment] = []
    
        var userID = ""
        var userName = ""
        var roomID = ""
    
        func initialize(appID: UInt32, appSign: String) {
            self.messages.removeAll()
            if zim != nil {
                    print("⚠️ Babumoshai, ZIM already initialized! Returning existing instance.")
                    return
                }
                print("✅ Babumoshai, initializing ZIM at \(Date())")
            let config = ZIMAppConfig()
            config.appID = appID
            config.appSign = appSign
            zim = ZIM.create(with: config)
//            zim?.setEventHandler(self)
            zim?.setEventHandler(ZIMGlobalEventHandler.shared)
            print("🧩 Babumoshai, ZIM instance memory: \(Unmanaged.passUnretained(zim!).toOpaque())")
            
        }
    
        func login(userID: String, userName: String) {
            self.userID = userID
            self.userName = userName
    
            let userInfo = ZIMUserInfo()
            userInfo.userID = userID
            userInfo.userName = userName
    
            zim?.login(with: userInfo) { errorInfo in
                if errorInfo.code.rawValue == 0 {
                    print("✅ ZIM login success babumoshai!")
                } else {
                    print("❌ ZIM login failed babumoshai: \(errorInfo.message)")
                }
            }
        }
    
    func joinRoom(roomID: String) {
        guard let zim = zim else {
               print("❌ Babumoshai, ZIM not initialized!")
               return
           }
        zim.setEventHandler(ZIMGlobalEventHandler.shared)
        self.roomID = roomID
        let roomInfo = ZIMRoomInfo()
        roomInfo.roomID = roomID

        let config = ZIMRoomAdvancedConfig()
//        config.isUserStatusNotify = true

        zim.enterRoom(with: roomInfo, config: config) { roomFullInfo, errorInfo in
            if errorInfo.code.rawValue == 0 {
                print("✅ Babumoshai, joined ZIM room: \(roomID)")
            } else {
                print("❌ Babumoshai, failed to join room: \(errorInfo.message)")
            }
        }
    }
    
//    func sendMessage(message: String,roomId : String) {
//        let zimMessage = ZIMTextMessage(message: message)
//        let sendConfig = ZIMMessageSendConfig()
//           // Optional: adjust settings
//        sendConfig.priority = .high
//           
//        let notification = ZIMMessageSendNotification()
//        guard let zim = zim else {
//            print("❌ Babumoshai, ZIM not initialized!")
//            return
//        }
//        zim.setEventHandler(ZIMGlobalEventHandler.shared)
//        guard !userID.isEmpty else {
//            print("❌ Babumoshai, user not logged in!")
//            return
//        }
//        
//        guard !roomId.isEmpty else {
//            print("❌ Babumoshai, roomID is empty!")
//            return
//        }
//        zim.sendMessage(
//            zimMessage,
//                    toConversationID: roomId,
//                    conversationType: .room,
//                    config: sendConfig,
//                    notification: notification
//        ) { _, errorInfo in
//            if errorInfo.code.rawValue == 0 {
//                print("✅ Message sent babumoshai!")
//                let newComment = Comment(
//                    image: UserDefaults.profileURL,
//                    username: self.userName,
//                    message: message
//                )
//                DispatchQueue.main.async {
//                    self.messages.append(newComment)
//                }
//            } else {
//                print("❌ Message failed babumoshai: \(errorInfo.message)")
//            }
//        }
//    }
    
    func sendMessage(message: String, roomId: String,image : String,name:String) {
        let payload: [String: Any] = [
            "text": message,
            "username": name,
            "avatarUrl": image
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
            print("❌ Failed to serialize JSON")
            return
        }
        let jsonString = String(data: jsonData, encoding: .utf8) ?? message

        let zimMessage = ZIMTextMessage(message: jsonString)
        let sendConfig = ZIMMessageSendConfig()
        sendConfig.priority = .high

        let notification = ZIMMessageSendNotification()
        guard let zim = zim else {
            print("❌ Babumoshai, ZIM not initialized!")
            return
        }

        zim.sendMessage(
            zimMessage,
            toConversationID: roomId,
            conversationType: .room,
            config: sendConfig,
            notification: notification
        ) { _, errorInfo in
            if errorInfo.code.rawValue == 0 {
                print("✅ Message sent babumoshai!")
                let newComment = Comment(
                    image: image,
                    username: self.userName,
                    message: message
                )
                DispatchQueue.main.async {
                    self.messages.append(newComment)
                }
            } else {
                print("❌ Message failed babumoshai: \(errorInfo.message)")
            }
        }
    }

    
        func logout() {
            zim?.logout()
        }
//    func handleIncomingMessage(username: String, message: String) {
//        let newComment = Comment(
//            image: "",  // Add profile image if you have
//            username: username,
//            message: message
//        )
//        DispatchQueue.main.async {
//            self.messages.append(newComment)
//        }
//    }
    
    func handleIncomingMessage(username: String, message: String, userImage: String) {
        let newComment = Comment(
            image: userImage,
            username: username,
            message: message
        )
        DispatchQueue.main.async {
            self.messages.append(newComment)
        }
    }
    }



class ZIMGlobalEventHandler: NSObject, ZIMEventHandler {
    static let shared = ZIMGlobalEventHandler()

    func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
        print("🔥 Babumoshai, GLOBAL connection state changed: \(state.rawValue)")
    }
//    func zim(_ zim: ZIM, roomMessageReceived messageList: [ZIMMessage], info: ZIMMessageReceivedInfo, fromRoomID: String) {
//        print("📥 Babumoshai, GLOBAL received \(messageList.count) message(s) in room:  at \(Date())")
//        for msg in messageList {
//            if let textMsg = msg as? ZIMTextMessage {
//                print("💬 Babumoshai, GLOBAL message content: \(textMsg.message) from: \(msg.senderUserID)")
//                
//                DispatchQueue.main.async {
//                    ZIMChatManager.shared.handleIncomingMessage(
//                        username: msg.senderUserID,
//                        message: textMsg.message
//                    )
//                }
//            } else {
//                print("⚠️ Babumoshai, GLOBAL unsupported message type received.")
//            }
//        }
//    }
    func zim(_ zim: ZIM, roomMessageReceived messageList: [ZIMMessage], info: ZIMMessageReceivedInfo, fromRoomID: String) {
        for msg in messageList {
            if let textMsg = msg as? ZIMTextMessage {
                print("💬 Babumoshai, raw: \(textMsg.message)")

                if let data = textMsg.message.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let text = json["text"] as? String {
                    let username = json["username"] as? String ?? msg.senderUserID
                    let avatarUrl = json["avatarUrl"] as? String ?? ""

                    ZIMChatManager.shared.handleIncomingMessage(
                        username: username,
                        message: text,
                        userImage: avatarUrl
                    )
                } else {
                    ZIMChatManager.shared.handleIncomingMessage(
                        username: msg.senderUserID,
                        message: textMsg.message,
                        userImage: ""
                    )
                }
            }
        }
    }
}
