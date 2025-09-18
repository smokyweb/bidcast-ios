//
//  SocketManager.swift
//  Whitetail Tactical
//
//  Created by Ankit-JAM-E-294 on 10/03/25.
//

import SocketIO
@MainActor
class SocketManagerService: NSObject, ObservableObject {
    static let shared = SocketManagerService()
    
    @Published var isConnected = false
    @Published var rooms: [RoomModel] = []
    @Published var chats: [ChatMessage] = []
    
    var onRoomsUpdated: (([String]) -> Void)?
    
    private var socket: SocketIOClient!
    private var socketManager: SocketManager!
    
    override private init() {
        super.init()
    }
    
    // MARK: - Setup Socket
    func setupSocket() {
        socketManager = SocketManager(
            socketURL: URL(string: "https://node.bidcast.betaplanets.com")!,
            config: [.log(false), .compress, .reconnects(true), .path("/socket.io")]
        )
        socket = socketManager.defaultSocket
        
        socket.on(clientEvent: .connect) { _, _ in
            self.isConnected = true
            print("✅ Socket connected")
        }
        socket.on(clientEvent: .disconnect) { data, _ in
            self.isConnected = false
            print("❌ Disconnected:", data)
        }
        socket.on(clientEvent: .error) { data, _ in
            print("⚠️ Socket error:", data)
        }
        
//        listenForRoomUpdates()
//        listenForChat()
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
        socket.removeAllHandlers()
        isConnected = false
    }
    
    // MARK: - Room
    func createRoom(_ roomData: [String: Any]) {
        guard socket.status == .connected else{
            if socket.status == .connecting || socket.status == .notConnected{
                print("Socket status \(socket.status)")
                setupSocket()
            }
            return
        }
        
        print("Socket status \(socket.status)")
        print("Creating Room \(roomData)")
        socket.emit("room_create", roomData)
    }
    
    func leaveRoom(_ roomData: [String: Any]) {
        guard socket.status == .connected else{
            if socket.status == .connecting || socket.status == .notConnected{
                print("Socket status \(socket.status)")
                setupSocket()
            }
            return
        }
        
        print("Socket status \(socket.status)")
        print("Creating Room \(roomData)")
        socket.emit("leave_room", roomData)
    }
    
    
    // MARK: - Chat
    func sendChat(roomId: String, message: String, userId: String) {
        guard isConnected else { return }
        let payload: [String: Any] = ["room_id": roomId, "message": message, "user_id": userId]
        socket.emit("chat", payload)
    }
    
//    private func listenForChat() {
//        socket.on("chat_get") { data, _ in
//            guard let json = data.first as? [String: Any] else { return }
//            do {
//                let decoded = try JSONSerialization.data(withJSONObject: json)
//                let chat = try JSONDecoder().decode(ChatMessage.self, from: decoded)
//                self.chats.append(chat)
//            } catch {
//                print("Decode error (Chat):", error)
//            }
//        }
//    }
}


struct RoomModel: Codable {
    let products: [ProductData]
    let room_id: String
    let seller: SellerModel
    let show_detail: String
    let thumbnail: String
    let viewer_count: Int
    let highest_bid: HighestBid?
    let is_live: Bool
    let time: String
    let show_id: String
    let allow_bid_for_all: Bool
    let bid_count_down: String
    let show_timer: String
    
    var id: String { room_id }
}

//struct ChatMessage: Codable, Identifiable {
//    let room_id: String
//    let message: String
//    let user_id: String
//    let timestamp: String?
//    var id: String { UUID().uuidString }
//}

struct HighestBid: Codable {
       let bid_amount, user_name, user_image, user_id, product_id: String
   }
