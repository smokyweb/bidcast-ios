////
////  ZegoChat.swift
////  BidCast
////
////  Created by Ankit-JAM-E-294 on 19/06/25.
////
//
//import Foundation
//import ZIM
//import SwiftUI
//
//class ZegoChatManager: NSObject, ZIMEventHandler, ObservableObject {
//    static let shared = ZegoChatManager()
//
//    private var zim: ZIM?
//    
//    @Published var messages: [Comment] = []
//
//    private override init() {
//        super.init()
//    }
//
//    func initZIM(appID: UInt32, appSign: String, userID: String, userName: String) {
//        let config = ZIMAppConfig()
//        config.appID = appID
//        zim = ZIM.create(with: config)
//        zim?.setEventHandler(self)
//
//        let userInfo = ZIMUserInfo()
//        userInfo.userID = userID
//        userInfo.userName = userName
//
//        zim?.login(with: userInfo, token: nil) { _, error in
//            if let error = error {
//                print("ZIM login error: \(error.code) \(error.message ?? "")")
//            } else {
//                print("ZIM login success")
//            }
//        }
//    }
//
//    func joinRoom(roomID: String) {
//        zim?.joinRoom(by: roomID) { _, error in
//            if let error = error {
//                print("Join room error: \(error.code)")
//            } else {
//                print("Joined room: \(roomID)")
//            }
//        }
//    }
//
//    func sendMessage(_ message: String, in roomID: String, from username: String) {
//        let msg = ZIMTextMessage(message: message)
//        zim?.sendRoomMessage(msg, to: roomID) { _, error in
//            if let error = error {
//                print("Send message failed: \(error.code)")
//            }
//        }
//        DispatchQueue.main.async {
//            self.messages.append(Comment(username: username, message: message))
//        }
//    }
//
//    func zim(_ zim: ZIM, roomMessageReceivedReceived messageList: [ZIMMessage], fromRoomID roomID: String) {
//        for message in messageList {
//            if let textMsg = message as? ZIMTextMessage {
//                DispatchQueue.main.async {
//                    self.messages.append(Comment(username: message.senderUserID, message: textMsg.message))
//                }
//            }
//        }
//    }
//}
