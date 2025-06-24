//  ZegoChat.swift
//  BidCast

import Foundation
import ZIM

class ZIMChatManager: NSObject, ObservableObject, ZIMEventHandler {
    
    private var zimEngine: ZIM?
    private let appID: UInt32 = 1005763407
    private let appSign: String = "73678be720c3ea2d871376882d27d21d5c2bc891363547424458f9febc8bf423"
    
    private var roomID: String = ""
    private let userID: String
    private let userName: String
    private var hasJoinedRoom = false
    
    @Published var isZIMLoggedIn: Bool = false
    @Published var messages: [String] = []
    
    var loginCompletion: (() -> Void)?
    
    init(userID: String, userName: String) {
        self.userID = userID
        self.userName = userName
        super.init()
        initializeZIM()
    }
    
    // MARK: - ZIM Initialization
    func initializeZIM() {
        let config = ZIMAppConfig()
        config.appID = appID
        config.appSign = appSign
        zimEngine = ZIM.create(with: config)
        zimEngine?.setEventHandler(self)
        login()
    }
    
    // MARK: - Login
    func login() {
        let userInfo = ZIMUserInfo()
        userInfo.userID = userID
        userInfo.userName = userName
        userInfo.userAvatarUrl = UserDefaults.profileURL
        
        zimEngine?.login(with: userInfo, token: "") { [weak self] errorInfo in
            guard let self = self else { return }
            if errorInfo.code.rawValue == 0 {
                print("babumoshai, ZIM login success!")
                print("🟢 Logging in with userID: \(userID), userName: \(userName)")
                self.isZIMLoggedIn = true
                self.loginCompletion?()
            } else {
                print("babumoshai, ZIM login failed: \(errorInfo.code)")
                // Optional: Retry login if needed
            }
        }
    }
    
    // MARK: - Room Management
    func updateRoomID(newRoomID: String) {
        if !roomID.isEmpty && roomID != newRoomID {
            zimEngine?.leaveRoom(by: roomID) { [weak self] _, error in
                guard let self = self else { return }
                if error.code.rawValue == 0 {
                    print("babumoshai, left old room successfully")
                    print("🛠 Switching to room: \(newRoomID)")
                } else {
                    print("babumoshai, failed to leave old room: \(error.code.rawValue)")
                }
                self.roomID = newRoomID
                self.joinRoom()
            }
        } else {
            self.roomID = newRoomID
            joinRoom()
        }
    }
    
    private func joinRoom() {
        zimEngine?.joinRoom(by: roomID) { [weak self] roomInfo, errorInfo in
            guard let self = self else { return }
            if errorInfo.code.rawValue == 0 {
                self.hasJoinedRoom = true
                print("babumoshai, joined ZIM room: \(roomInfo.baseInfo.roomID)")
                print("🟢 Joining room: \(roomID)")
            } else if errorInfo.code.rawValue == 6000322 { // Room not exist
                print("babumoshai, room does not exist, creating room...")
                self.createRoom()
            } else {
                print("babumoshai, failed to join room: \(errorInfo.code)")
            }
        }
    }
    
    private func createRoom() {
        let roomInfo = ZIMRoomInfo()
        roomInfo.roomID = roomID
        
        zimEngine?.createRoom(with: roomInfo) { [weak self] roomFullInfo, errorInfo in
            guard let self = self else { return }
            if errorInfo.code.rawValue == 0 {
                self.hasJoinedRoom = true
                print("babumoshai, room created successfully: \(roomFullInfo.baseInfo.roomID)")
                //                joinRoom()
            } else {
                print("babumoshai, failed to create room: \(errorInfo.code)")
            }
        }
    }
    
    // MARK: - Send Message
    func sendMessage(_ text: String) {
        
        guard isZIMLoggedIn else {
            print("❌ Cannot send, not logged in.")
            return
        }
        guard hasJoinedRoom else {
            print("❌ Cannot send, not joined in room.")
            return
        }
        guard !roomID.isEmpty else {
            print("❌ roomID is empty")
            return
        }

        let message = ZIMTextMessage(message: text)
        let sendConfig = ZIMMessageSendConfig()

        zimEngine?.sendRoomMessage(message, toRoomID: roomID, config: sendConfig) { [weak self] _, errorInfo in
            guard let self = self else { return }
            if errorInfo.code.rawValue == 0 {
                print("✅ Message sent: \(text)")
                DispatchQueue.main.async {
                    self.messages.append("Me: \(text)")
                }
            } else {
                print("❌ Failed to send message: \(errorInfo.code.rawValue)")
            }
        }
    }
    
    // MARK: - ZIM Event Handler
    func zim(_ zim: ZIM, receiveRoomMessage messages: [ZIMMessage], fromRoomID roomID: String) {
        for message in messages {
            if let textMessage = message as? ZIMTextMessage {
                DispatchQueue.main.async { [weak self] in
                    self?.messages.append("Other: \(textMessage.message)")
                }
                print("babumoshai, received message: \(textMessage.message)")
            }
        }
    }
    
    // MARK: - Leave Room
    func leaveCurrentRoom() {
        guard !roomID.isEmpty else { return }
        
        zimEngine?.leaveRoom(by: roomID) { [weak self] _, error in
            guard let self = self else { return }
            if error.code.rawValue == 0 {
                print("babumoshai, left room successfully")
                self.roomID = ""
            } else {
                print("babumoshai, failed to leave room: \(error.code.rawValue)")
            }
        }
    }
    
    // MARK: - Logout
    func logout() {
        zimEngine?.logout()
        print("babumoshai, logout called")
    }
}
