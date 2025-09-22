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
    @Published var chats: [CommentModel] = []
    @Published  var viewerCount: Int = 0
    var onRoomsUpdated: (([String]) -> Void)?
    var liveSchedulerTimer: Timer?
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
        
        listenForRoomUpdates()
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
    func endStreaming(roomId: String) {
        guard socket.status == .connected else{
            if socket.status == .connecting || socket.status == .notConnected{
                print("Socket status \(socket.status)")
                setupSocket()
            }
            return
        }
        let payload: [String: Any] = ["room_id": roomId]
        print("Socket status \(socket.status)")
        print("Ending streaming Room \(payload)")
        socket.emit("endRoom", payload)
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
    func sendChat(roomId: String, message: String) {
        guard isConnected else { return }
        
        let payload: [String: Any] = ["room_id": roomId,
                                      "message": message,
                                      "user_id": "\(UserDefaults.userId)",
                                      "user_name":UserDefaults.userName,
                                      "user_image":UserDefaults.profileURL]
        socket.emit("chat", payload)
    }
    
    func listenForChat() {
        socket.on("chat_get") { data, _ in
            guard let json = data.first as? [String: Any] else {
                print("json Error \(data)")
                return }
            do {
                let decoded = try JSONSerialization.data(withJSONObject: json)
                let chat = try JSONDecoder().decode(CommentModel.self, from: decoded)
                //                self.chats.append(chat)
                DispatchQueue.main.async {
                    self.chats.append(chat)
                }
                print("chatList \(self.chats)")
            } catch {
                print("Decode error (Chat):", error)
            }
        }
    }
    
    func startLiveScheduler(roomId: String) {
        // Invalidate existing timer if running
        liveSchedulerTimer?.invalidate()
        
        // Send immediately once
        sendLiveScheduler(roomId: roomId)
        
        // Schedule every 270 seconds (4.5 minutes)
        liveSchedulerTimer = Timer.scheduledTimer(withTimeInterval: 270, repeats: true) { [weak self] _ in
            self?.sendLiveScheduler(roomId: roomId)
        }
        
        print("✅ LiveScheduler started for room: \(roomId)")
    }
    
    func stopLiveScheduler() {
        liveSchedulerTimer?.invalidate()
        liveSchedulerTimer = nil
        print("🛑 LiveScheduler stopped")
    }
    
    func sendLiveScheduler(roomId: String) {
        guard socket.status == .connected else {
            if socket.status == .connecting || socket.status == .notConnected {
                print("Socket status \(socket.status)")
                setupSocket()
            }
            return
        }
        
        let payload: [String: Any] = ["room_id": roomId]
        print("📡 Sending liveScheduler with payload:", payload)
        socket.emit("liveScheduler", payload)
    }
    
    func joinRoom(roomId: String,userId : Int = UserDefaults.userId) {
        guard socket.status == .connected else {
            if socket.status == .connecting || socket.status == .notConnected {
                print("Socket status \(socket.status)")
                setupSocket()
            }
            return
        }
        
        let payload: [String: Any] = ["room_id": roomId,"user_id" : userId]
        print("📡 Sending liveScheduler with payload:", payload)
        socket.emit("join_room", payload)
    }
    
    func leaveRoom(roomId: String,userId : Int = UserDefaults.userId) {
        guard socket.status == .connected else {
            if socket.status == .connecting || socket.status == .notConnected {
                print("Socket status \(socket.status)")
                setupSocket()
            }
            return
        }
        
        let payload: [String: Any] = ["room_id": roomId,"user_id" : userId]
        print("📡 Sending liveScheduler with payload:", payload)
        socket.emit("leave_room", payload)
    }
    
    
    func listenForRoomUpdates() {
        socket.on("room_create_get") { data, _ in
            guard let json = data.first as? [String: Any] else { return }
            do {
                let decoded = try JSONSerialization.data(withJSONObject: json)
                let room = try JSONDecoder().decode(RoomModel.self, from: decoded)
                
                if !self.rooms.contains(where: { $0.room_id == room.room_id }) {
                    self.rooms.append(room)
                }
                print("✅ Received RoomDetail: \(self.rooms)")
                let roomIDs = self.rooms.compactMap { $0.room_id }
                self.onRoomsUpdated?(roomIDs)
            } catch {
                print("❌ Decode error (Room):", error)
            }
              
        }
        
    }
    
    func listenForViewerCount() {
        socket.on("viewer_count") { data, _ in
            guard let json = data.first as? [String: Any],
                  let count = json["count"] as? Int else {
                print("❌ Invalid viewer count data:", data)
                return
            }
            
            // Update variable and trigger callback
            self.viewerCount = count
            
            print("👀 Viewer count updated:", count)
        }
    }
}

struct RoomModel: Codable {
    let products: [ProductData]?
    let room_id: String?
    let seller: SellerModel?
    let show_detail: String?
    let thumbnail: String?
    let viewer_count: String?
    let highest_bid: HighestBid?
    let is_live: Bool?
    let time: String?
    let show_id: String?
    let allow_bid_for_all: Bool?
    let bid_count_down: String?
    let show_timer: String?
    
    var id: String { room_id ?? "" }
}

struct HighestBid: Codable {
       let bid_amount, user_name, user_image, user_id, product_id: String?
   }
