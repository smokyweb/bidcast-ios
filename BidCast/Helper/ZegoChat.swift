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
            let config = ZIMAppConfig()
            config.appID = appID
            config.appSign = appSign
            zim = ZIM.create(with: config)
            zim?.setEventHandler(self)
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
                    print("❌ ZIM login failed babumoshai: \(errorInfo.message ?? "")")
                }
            }
        }
    
    func joinRoom(roomID: String) {
        self.roomID = roomID

        let roomInfo = ZIMRoomInfo()
        roomInfo.roomID = roomID

        let config = ZIMRoomAdvancedConfig()
//        config.isUserStatusNotify = true

        zim?.enterRoom(with: roomInfo, config: config) { roomFullInfo, errorInfo in
            if errorInfo.code.rawValue == 0 {
                print("✅ Babumoshai, joined ZIM room: \(roomID)")
            } else {
                print("❌ Babumoshai, failed to join room: \(errorInfo.message)")
            }
        }
    }
    
    func sendMessage(message: String,roomId : String) {
        let zimMessage = ZIMTextMessage(message: message)
        let sendConfig = ZIMMessageSendConfig()
           // Optional: adjust settings
        sendConfig.priority = .high
           
        let notification = ZIMMessageSendNotification()
        guard let zim = zim else {
            print("❌ Babumoshai, ZIM not initialized!")
            return
        }
        
        guard !userID.isEmpty else {
            print("❌ Babumoshai, user not logged in!")
            return
        }
        
        guard !roomId.isEmpty else {
            print("❌ Babumoshai, roomID is empty!")
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
                    image: UserDefaults.profileURL,
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
    }
    
    extension ZIMChatManager: ZIMEventHandler {
        func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
                print("🔥 Babumoshai, connection state changed: \(state.rawValue)")
                
            }
        func zim(_ zim: ZIM, roomMessageReceived roomID: String, messageList: [ZIMMessage]) {
               print("📥 Babumoshai, received \(messageList.count) message(s) in room: \(roomID)")

               for msg in messageList {
                   if let textMsg = msg as? ZIMTextMessage {
                       DispatchQueue.main.async {
                           let newComment = Comment(
                               image: "",  // You can later attach sender profile image here
                               username: msg.senderUserID,
                               message: textMsg.message
                           )
                           self.messages.append(newComment)
                       }
                   } else {
                       print("⚠️ Babumoshai, unsupported message type received.")
                   }
               }
           }
    }

