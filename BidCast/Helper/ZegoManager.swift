//
//  ZegoManager.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/06/25.
//

import Foundation
import ZegoExpressEngine
import SwiftUI

class ZegoManager: NSObject, ZegoEventHandler , ObservableObject {
    static let shared = ZegoManager()
    
    @Published var streamInterrupted: Bool = false
    @Published var errorTitle: String = "Stream Ended"
    @Published var errorMessage: String = "The live stream was interrupted or stopped."
    @Published var incomingComments: [CommentModel] = []
    @Published var alertType: BottomSheetType = .sheetType(icon: .alert, title: "", message: "", primaryBtnText: "", secondaryBtnText: "")
    @Published var isCommentsAvailable : Bool = false
    @StateObject var zimChat = ZIMChatManager()
    
    private override init() {
        super.init()
      
    }
    
    func createEngine() {
        let profile = ZegoEngineProfile()
        profile.appID = 1005763407
        profile.appSign = "73678be720c3ea2d871376882d27d21d5c2bc891363547424458f9febc8bf423"
        profile.scenario = .broadcast
        
        ZegoExpressEngine.createEngine(with: profile, eventHandler: nil)
        
        print("✅ Zego Engine created.")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            ZegoExpressEngine.shared().setEventHandler(self)
            //               ZegoExpressEngine.shared().enableIM(true)
            print("✅ Zego event handler attached.")
        }
    }
    
    
    // MARK: - ZegoEventHandler Methods
    
    
//    func onPlayerRecvSEI(_ streamID: String, data: Data) {
//        print("📡 Received SEI data on stream: \(streamID)")
//    }
//    
//    func onRoomStreamUpdate(_ roomID: String, updateType: ZegoUpdateType, streamList: [ZegoStream], extendedData: [AnyHashable : Any]?) {
//        print("🔄 Stream Update - RoomID: \(roomID), UpdateType: \(updateType.rawValue), StreamCount: \(streamList.count)")
//    }
//    
//    func onDebugError(_ errorCode: Int32, funcName: String, info: String) {
//        print("🐞 Debug Error - \(funcName): \(errorCode) - \(info)")
//    }
    
    func resetError() {
        streamInterrupted = false
    }
    
//    func onPlayerStateUpdate(_ streamID: String, state: ZegoPlayerState, errorCode: Int32, extendedData: [AnyHashable : Any]?) {
//        print("🔴 StreamID: \(streamID) | State: \(state.rawValue) | Error: \(errorCode)")
//
//        if state == .noPlay || errorCode != 0 {
//            DispatchQueue.main.async {
//                self.errorTitle = "Stream Ended"
//                self.errorMessage = "Stream has been stopped or interrupted."
//                self.streamInterrupted = true
//                self.alertType = .sheetType(
//                    icon: .alert,
//                    title:  self.errorTitle,
//                    message: self.errorMessage,
//                    primaryBtnText: AppString.ok.localized,
//                    secondaryBtnText:""
//                )
//            }
//        }
//    }
//    func onIMRecvBroadcastMessage(_ roomID: String, messageList: [ZegoBroadcastMessageInfo]) {
//        print("📥 [\(roomID)] Received \(messageList.count) broadcast messages")
//        for msg in messageList {
//            print("🗣️ \(msg.fromUser.userName): \(msg.message)")
//        }
//
//        DispatchQueue.main.async {
//            if !messageList.isEmpty {
//                self.isCommentsAvailable = true
//                self.incomingComments.append(contentsOf: messageList.map {
//                    Comment(image : UserDefaults.profileURL,username: $0.fromUser.userName, message: $0.message)
//                })
//            } else {
//                self.isCommentsAvailable = false
//            }
//        }
//    }
}

