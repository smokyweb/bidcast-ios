////  ZegoChat.swift
////  BidCast
//
//import Foundation
//import ZIM
//import ZegoExpressEngine
//
//class ZIMChatManager: NSObject, ObservableObject {
//    
//    static let shared = ZIMChatManager()
//    
//    private var zim: ZIM?
//    @Published var messages: [CommentModel] = []
//    
//    var userID = ""
//    var userName = ""
//    var roomID = ""
//    var onJOin : () -> () = {  }
//    
//    func initialize(appID: UInt32, appSign: String) {
//        self.messages.removeAll()
//        if zim != nil {
//            print("⚠️ Babumoshai, ZIM already initialized! Returning existing instance.")
//            return
//        }
//        print("✅ Babumoshai, initializing ZIM at \(Date())")
//        let config = ZIMAppConfig()
//        config.appID = appID
//        config.appSign = appSign
//        zim = ZIM.create(with: config)
//        //            zim?.setEventHandler(self)
//        zim?.setEventHandler(ZIMGlobalEventHandler.shared)
//        print("🧩 Babumoshai, ZIM instance memory: \(Unmanaged.passUnretained(zim!).toOpaque())")
//        
//    }
//    
//    func login(userID: String, userName: String) {
//        self.userID = userID
//        self.userName = userName
//        
//        let userInfo = ZIMUserInfo()
//        userInfo.userID = userID
//        userInfo.userName = userName
//        
//        zim?.login(with: userInfo) { errorInfo in
//            if errorInfo.code.rawValue == 0 {
//                print("✅ ZIM login success babumoshai!")
//            } else {
//                print("❌ ZIM login failed babumoshai: \(errorInfo.message)")
//            }
//        }
//    }
//    
//    func joinRoom(roomID: String) {
//        guard let zim = zim else {
//            print("❌ Babumoshai, ZIM not initialized!")
//            return
//        }
//        zim.setEventHandler(ZIMGlobalEventHandler.shared)
//        self.roomID = roomID
//        let roomInfo = ZIMRoomInfo()
//        roomInfo.roomID = roomID
//        
//        let config = ZIMRoomAdvancedConfig()
//        //        config.isUserStatusNotify = true
//        
//        zim.enterRoom(with: roomInfo, config: config) { roomFullInfo, errorInfo in
//            if errorInfo.code.rawValue == 0 {
//                print("✅ Babumoshai, joined ZIM room: \(roomID)")
//                self.onJOin()
//            } else {
//                print("❌ Babumoshai, failed to join room: \(errorInfo.message)")
//            }
//        }
//    }
//    
//    func sendMessage(message: String, roomId: String,image : String,name:String) {
////        let payload: [String: Any] = [
////            "userName": name,
////            "userImage": image,
////            "userId": UserDefaults.userId
////        ]
////        
////        // Serialize extended data to JSON string
////        guard let jsonData = try? JSONSerialization.data(withJSONObject: payload) else {
////            print("❌ Failed to serialize extended JSON")
////            return
////        }
////        let extendedData = String(data: jsonData, encoding: .utf8) ?? ""
////        
////        // ✅ Use only message text here
////        let zimMessage = ZIMTextMessage(message: message)
////        zimMessage.extendedData = extendedData // attach extended data
////        
////        let sendConfig = ZIMMessageSendConfig()
////        sendConfig.priority = .high
////        
////        let notification = ZIMMessageSendNotification()
////        
////        guard let zim = zim else {
////            print("❌ Babumoshai, ZIM not initialized!")
////            return
////        }
////        
////        zim.sendMessage(
////            zimMessage,
////            toConversationID: roomId,
////            conversationType: .room,
////            config: sendConfig,
////            notification: notification
////        ) { _, errorInfo in
////            if errorInfo.code.rawValue == 0 {
////                print("✅ Message sent babumoshai!")
////                let newComment = CommentModel(
////                    image: image,
////                    username: name,
////                    message: message,
////                    userId: "\(UserDefaults.userId)"
////                )
////                DispatchQueue.main.async {
////                    self.messages.append(newComment)
////                }
////            } else {
////                print("❌ Message failed babumoshai: \(errorInfo.message)")
////            }
////        }
////    
//    }
//    
//    
//    func logout() {
//        zim?.logout()
//    }
//    
//    func handleIncomingMessage(username: String, message: String, userImage: String,userId:String) {
////        let newComment = CommentModel(
////            image:userImage,
////            username: username,
////            message:message ,
////            userId:userId
////        )
////        DispatchQueue.main.async {
////            self.messages.append(newComment)
////        }
//    }
//}
//
//
//
//class ZIMGlobalEventHandler: NSObject, ZIMEventHandler {
//    static let shared = ZIMGlobalEventHandler()
//    
//    func zim(_ zim: ZIM, connectionStateChanged state: ZIMConnectionState, event: ZIMConnectionEvent, extendedData: [AnyHashable : Any]) {
//        print("🔥 Babumoshai, GLOBAL connection state changed: \(state.rawValue)")
//    }
//    func zim(_ zim: ZIM, roomMessageReceived messageList: [ZIMMessage], info: ZIMMessageReceivedInfo, fromRoomID: String) {
//        for msg in messageList {
//            if let textMsg = msg as? ZIMTextMessage {
//                print("💬 raw text: \(textMsg.message)")
//                print("📦  extended data: \(textMsg.extendedData)")
//                
//                var username = msg.senderUserID
//                var avatarUrl = ""
//                var userId = msg.senderUserID
//                let extended = textMsg.extendedData
//                // ✅ Now parse user info from `extendedData`
//                if let data = extended.data(using: .utf8),
//                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
//                    
//                    username = json["userName"] as? String ?? msg.senderUserID
//                    avatarUrl = json["userImage"] as? String ?? ""
//                    userId = json["userId"] as? String ?? msg.senderUserID
//                }
//                
//                ZIMChatManager.shared.handleIncomingMessage(
//                    username: username,
//                    message: textMsg.message,
//                    userImage: avatarUrl,
//                    userId: userId
//                )
//            }
//        }
//    }
//
//}
