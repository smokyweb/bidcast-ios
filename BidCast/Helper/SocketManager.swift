//
//  SocketManager.swift
//  Whitetail Tactical
//
//  Created by Ankit-JAM-E-294 on 10/03/25.
//


//@MainActor
//class SocketManagerService: NSObject, ObservableObject {
//    static let shared = SocketManagerService()
//    
//    @Published var isConnected = false
//    @Published var rooms: [RoomModel] = []
//    @Published var chats: [CommentModel] = []
//    @Published  var viewerCount: Int = 0
//    @Published var showTime: String = "00:00:00"
//    @Published var bidTime: String = "00:00:00"
//    
//    
//    var onRoomsUpdated: (([String]) -> Void)?
//    var liveSchedulerTimer: Timer?
//    
//    private var socket: SocketIOClient!
//    private var socketManager: SocketManager!
//    
//    override private init() {
//        super.init()
//    }
//    
//    // MARK: - Setup Socket
//    func setupSocket() {
//        socketManager = SocketManager(
//            socketURL: URL(string: "https://node.bidcast.betaplanets.com")!,
//            config: [.log(false), .compress, .reconnects(true), .path("/socket.io")]
//        )
//        socket = socketManager.defaultSocket
//        
//        socket.on(clientEvent: .connect) { _, _ in
//            self.isConnected = true
//            print("✅ Socket connected")
//        }
//        socket.on(clientEvent: .disconnect) { data, _ in
//            self.isConnected = false
//            print("❌ Disconnected:", data)
//        }
//        socket.on(clientEvent: .error) { data, _ in
//            print("⚠️ Socket error:", data)
//        }
//        
//        listenForRoomUpdates()
//        //        listenForChat()
//        socket.connect()
//    }
//    
//    func disconnect() {
//        socket.disconnect()
//        socket.removeAllHandlers()
//        isConnected = false
//    }
//    
//    // MARK: - Room
//    func createRoom(_ roomData: [String: Any]) {
//        guard socket.status == .connected else{
//            if socket.status == .connecting || socket.status == .notConnected{
//                print("Socket status \(socket.status)")
//                setupSocket()
//            }
//            return
//        }
//        
//        print("Socket status \(socket.status)")
//        print("Creating Room \(roomData)")
//        socket.emit("room_create", roomData)
//    }
//    
//    // MARK: - Room
//    func sendBid(_ roomData: [String: Any]) {
//        guard socket.status == .connected else{
//            if socket.status == .connecting || socket.status == .notConnected{
//                print("Socket status \(socket.status)")
//                setupSocket()
//            }
//            return
//        }
//        
//        print("Socket status \(socket.status)")
//        print("Creating Room \(roomData)")
//        socket.emit("place_bid", roomData)
//    }
//    
//    func endStreaming(roomId: String) {
//        guard socket.status == .connected else{
//            if socket.status == .connecting || socket.status == .notConnected{
//                print("Socket status \(socket.status)")
//                setupSocket()
//            }
//            return
//        }
//        let payload: [String: Any] = ["room_id": roomId]
//        print("Socket status \(socket.status)")
//        print("Ending streaming Room \(payload)")
//        socket.emit("endRoom", payload)
//    }
//    
//    func leaveRoom(_ roomData: [String: Any]) {
//        guard socket.status == .connected else{
//            if socket.status == .connecting || socket.status == .notConnected{
//                print("Socket status \(socket.status)")
//                setupSocket()
//            }
//            return
//        }
//        
//        print("Socket status \(socket.status)")
//        print("Creating Room \(roomData)")
//        socket.emit("leave_room", roomData)
//    }
//    
//    
//    // MARK: - Chat
//    func sendChat(roomId: String, message: String) {
//        guard isConnected else { return }
//        
//        let payload: [String: Any] = ["room_id": roomId,
//                                      "message": message,
//                                      "user_id": "\(UserDefaults.userId)",
//                                      "user_name":UserDefaults.userName,
//                                      "user_image":UserDefaults.profileURL]
//        socket.emit("chat", payload)
//    }
//    
//    func listenForChat() {
//        socket.on("chat_get") { data, _ in
//            guard let json = data.first as? [String: Any] else {
//                print("json Error \(data)")
//                return }
//            do {
//                let decoded = try JSONSerialization.data(withJSONObject: json)
//                let chat = try JSONDecoder().decode(CommentModel.self, from: decoded)
//                //                self.chats.append(chat)
//                DispatchQueue.main.async {
//                    self.chats.append(chat)
//                }
//                print("chatList \(self.chats)")
//            } catch {
//                print("Decode error (Chat):", error)
//            }
//        }
//    }
//    
//    func startLiveScheduler(roomId: String) {
//        // Invalidate existing timer if running
//        liveSchedulerTimer?.invalidate()
//        
//        // Send immediately once
//        sendLiveScheduler(roomId: roomId)
//        
//        // Schedule every 270 seconds (4.5 minutes)
//        liveSchedulerTimer = Timer.scheduledTimer(withTimeInterval: 270, repeats: true) { [weak self] _ in
//            self?.sendLiveScheduler(roomId: roomId)
//        }
//        
//        print("✅ LiveScheduler started for room: \(roomId)")
//    }
//    
//    func stopLiveScheduler() {
//        liveSchedulerTimer?.invalidate()
//        liveSchedulerTimer = nil
//        print("🛑 LiveScheduler stopped")
//    }
//    
//    func sendLiveScheduler(roomId: String) {
//        guard socket.status == .connected else {
//            if socket.status == .connecting || socket.status == .notConnected {
//                print("Socket status \(socket.status)")
//                setupSocket()
//            }
//            return
//        }
//        
//        let payload: [String: Any] = ["room_id": roomId]
//        print("📡 Sending liveScheduler with payload:", payload)
//        socket.emit("liveScheduler", payload)
//    }
//    
//    func joinRoom(roomId: String,userId : Int = UserDefaults.userId) {
//        guard socket.status == .connected else {
//            if socket.status == .connecting || socket.status == .notConnected {
//                print("Socket status \(socket.status)")
//                setupSocket()
//            }
//            return
//        }
//        
//        let payload: [String: Any] = ["room_id": roomId,"user_id" : userId]
//        print("📡 Sending liveScheduler with payload:", payload)
//        socket.emit("join_room", payload)
//    }
//    
//    func leaveRoom(roomId: String,userId : Int = UserDefaults.userId) {
//        guard socket.status == .connected else {
//            if socket.status == .connecting || socket.status == .notConnected {
//                print("Socket status \(socket.status)")
//                setupSocket()
//            }
//            return
//        }
//        
//        let payload: [String: Any] = ["room_id": roomId,"user_id" : userId]
//        print("📡 Sending liveScheduler with payload:", payload)
//        socket.emit("leave_room", payload)
//    }
//    
//    
//    func listenForRoomUpdates() {
//        socket.on("room_create_get") { data, _ in
//            guard let json = data.first as? [String: Any] else { return }
//            do {
//                let decoded = try JSONSerialization.data(withJSONObject: json)
//                let room = try JSONDecoder().decode(RoomModel.self, from: decoded)
//                
//                if !self.rooms.contains(where: { $0.room_id == room.room_id }) {
//                    self.rooms.append(room)
//                }
//                print("✅ Received RoomDetail: \(self.rooms)")
//                let roomIDs = self.rooms.compactMap { $0.room_id }
//                self.onRoomsUpdated?(roomIDs)
//            } catch {
//                print("❌ Decode error (Room):", error)
//            }
//              
//        }
//        
//    }
//    
//    func listenForViewerCount() {
//        socket.on("viewerCount") { data, _ in
//            if let json = data.first as? [String: Any], let count = json["count"] as? Int {
//                // Case when the socket sends a dictionary
//                self.viewerCount = count
//                print("👀 Viewer count updated:", count)
//            } else if let count = data.first as? Int {
//                // Case when the socket sends [Int]
//                self.viewerCount = count
//                print("👀 Viewer count updated (array):", count)
//            } else {
//                print("❌ Invalid viewer count data:", data)
//            }
//        }
//    }
//
//    
//    func listenForShowTimer(roomId:String) {
//        socket.on("show_timer_update") { data, _ in
//            guard let json = data.first as? [String: Any] else {
//                print("❌ Invalid show timer data:", data)
//                return
//            }
//            
//            // Ensure room_id exists if you want to check for specific room
//            guard let roomID = json["room_id"] as? String,
//                  let elapsed = json["elapsed"] as? Int else {
//                print("❌ Missing keys in show timer data:", json)
//                return
//            }
//            
//            // Optionally, check if this is the room you care about
//            if roomID == roomId {
//                let time  = self.formatElapsedTime(seconds: elapsed)
//                self.showTime = time
//                print("Show Time: \(time)")
//                print("⏱ Elapsed time for \(roomId):", elapsed)
//            }
//        }
//    }
//    
//    func listenForBidTimer(roomId:String) {
//        socket.on("bid_timer_update") { data, _ in
//            guard let json = data.first as? [String: Any] else {
//                print("❌ Invalid bid timer data:", data)
//                return
//            }
//            
//            // Ensure room_id exists if you want to check for specific room
//            guard let roomID = json["room_id"] as? String,
//                  let elapsed = json["remaining"] as? Int else {
//                print("❌ Missing keys in bid timer data:", json)
//                return
//            }
//            
//            // Optionally, check if this is the room you care about
//            if roomID == roomId {
//                let time  = self.formatElapsedTime(seconds: elapsed)
//                self.bidTime = time
//                print("Bid Time: \(time)")
//                print("⏱ Elapsed time for \(roomId):", elapsed)
//            }
//        }
//    }
//    
//    func formatElapsedTime(seconds: Int) -> String {
//        let hours = seconds / 3600
//        let minutes = (seconds % 3600) / 60
//        let secs = seconds % 60
//        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
//    }
//    
//}

struct RoomModel: Codable {
    var products: [ProductData]?
    let room_id: String?
    let seller: SellerModel?
    let show_detail: String?
    let thumbnail: String?
    let viewer_count: String?
    var highest_bid: HighestBid?
    let is_live: Bool?
    let time: String?
    let show_id: String?
    let allow_bid_for_all: Bool?
    let bid_count_down: String?
    let show_timer: String?
    
    var id: String { room_id ?? "" }
}

struct HighestBid: Codable {
    var bid_amount: String?
    var user_name: String?
    var user_image: String?
    var user_id: String?
    var product_id: String?
    var placed_at: String?
}


import Foundation
import SocketIO
import Combine
import os

@MainActor
final class SocketManagerService: NSObject, ObservableObject {
    
    // MARK: - Shared Instance (Optional Singleton)
    static let shared = SocketManagerService()
    
    // MARK: - Published Properties
    @Published var isConnected = false
    @Published var rooms: [RoomModel] = []
    @Published var chats: [CommentModel] = []
    @Published var viewerCount: Int = 0
    @Published var showTime: String = "00:00:00"
    @Published var bidTime: String = "00:00:00"
    @Published var hasWon = false
    
    // MARK: - Callbacks
    var onRoomsUpdated: (([String]) -> Void)?
    
    // MARK: - Private Properties
    private var liveSchedulerTimer: Timer?
    private var socket: SocketIOClient!
    private var socketManager: SocketManager!
    private let logger = Logger(subsystem: "io.bidcast", category: "Socket")
    
    // MARK: - Init
    override private init() {
        super.init()
    }
    
    // MARK: - Setup
    func setupSocket() {
        socketManager = SocketManager(
            socketURL: URL(string: "https://node.bidcast.betaplanets.com")!,
            config: [.log(false), .compress, .reconnects(true), .path("/socket.io")]
        )
        
        socket = socketManager.defaultSocket
        
        socket.on(clientEvent: .connect) { [weak self] _, _ in
            guard let self else { return }
            self.isConnected = true
            logger.info("✅ Socket connected")
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, _ in
            guard let self else { return }
            self.isConnected = false
            logger.warning("❌ Disconnected: \(String(describing: data))")
        }
        
        socket.on(clientEvent: .error) { [weak self] data, _ in
            self?.logger.error("⚠️ Socket error: \(String(describing: data))")
        }
        
//        observeRoomUpdates()
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
        socket.removeAllHandlers()
        isConnected = false
        logger.info("🔌 Socket disconnected manually")
    }
    
    // MARK: - Common Guard
    private func performIfConnected(_ action: () -> Void) {
        guard socket.status == .connected else {
            if socket.status == .connecting || socket.status == .notConnected {
                logger.warning("⚠️ Socket not ready, reconnecting...")
                setupSocket()
            }
            return
        }
        action()
    }
    
    // MARK: - Emit Events
    func createRoom(payload: [String: Any]) {
        performIfConnected {
            socket.emit("room_create", payload)
            logger.info("📡 Creating room: \(payload)")
        }
    }
    
    func sendBid(payload: [String: Any]) {
        performIfConnected {
            socket.emit("place_bid", payload)
            logger.info("📡 Sending bid: \(payload)")
        }
    }
    
    func endStreaming(roomId: String) {
        performIfConnected {
            let payload = ["room_id": roomId]
            socket.emit("endRoom", payload)
            logger.info("📡 Ending streaming for room \(roomId)")
        }
    }
    
    func joinRoom(roomId: String, userId: Int = UserDefaults.userId, completion: @escaping (() -> Void) ) {
        performIfConnected {
            let payload = ["room_id": roomId, "user_id": userId] as [String : Any]
            socket.emit("join_room", payload)
            logger.info("📡 Joined room \(roomId)")
            observeRoomUpdates(completion: { room in
                completion()
            })
          
        }
    }
    
    func leaveRoom(roomId: String, userId: Int) {
        performIfConnected {
            let payload = ["room_id": roomId, "user_id": userId] as [String : Any]
            socket.emit("leave_room", payload)
            logger.info("📡 Left room \(roomId)")
        }
    }
    
    func sendChat(roomId: String, message: String, userId: Int, userName: String, userImage: String) {
        performIfConnected {
            let payload: [String: Any] = [
                "room_id": roomId,
                "message": message,
                "user_id": "\(userId)",
                "user_name": userName,
                "user_image": userImage
            ]
            socket.emit("chat", payload)
            logger.info("💬 Sent chat: \(message)")
        }
    }
    
//    // MARK: - Listen Events
//    func observeRoomUpdates() {
//        socket.on("room_create_get") { data, _ in
//            guard let json = data.first as? [String: Any] else { return }
//            do {
//                let decoded = try JSONSerialization.data(withJSONObject: json)
//                let room = try JSONDecoder().decode(RoomModel.self, from: decoded)
//                
//                if !self.rooms.contains(where: { $0.room_id == room.room_id }) {
//                    self.rooms.append(room)
//                }
////                print("✅ Received RoomDetail: \(self.rooms)")
//                let roomIDs = self.rooms.compactMap { $0.room_id }
//                self.onRoomsUpdated?(roomIDs)
//                self.logger.info("✅ Room updated: \(room.room_id ?? "")")
//            } catch {
//                self.logger.error("❌ Room decode error: \(error.localizedDescription)")
//            }
//        }
//    }
    
    func observeRoomUpdates(completion: ((_ room: RoomModel) -> Void)? = nil) {
        performIfConnected {
            socket.on("room_create_get") { [weak self] data, _ in
                guard let self else { return }
                guard let json = data.first as? [String: Any] else { return }
                
                do {
                    let decodedData = try JSONSerialization.data(withJSONObject: json)
                    let room = try JSONDecoder().decode(RoomModel.self, from: decodedData)
                    
                    // ✅ Append only if not already present
                    if !self.rooms.contains(where: { $0.room_id == room.room_id }) {
                        self.rooms.append(room)
                    }
                    
                    print("✅ Received RoomDetail: \(room.room_id ?? "Unknown")")
                    
                    // ✅ Notify listeners if needed
                    let roomIDs = self.rooms.compactMap { $0.room_id }
                    self.onRoomsUpdated?(roomIDs)
                    self.listenForViewerCount()
                    
                    // ✅ Trigger completion callback (optional)
                    completion?(room)
                    
                } catch {
                    print("❌ Decode error (Room):", error)
                }
            }
        }
    }
   

    
    func listenForChat(roomId: String) {
        socket.on("chat_get") {  data, _ in
           

            guard let json = data.first as? [String: Any] else {
                print("⚠️ Invalid chat data:", data)
                return
            }

            do {
                let decoded = try JSONSerialization.data(withJSONObject: json)
                let chat = try JSONDecoder().decode(CommentModel.self, from: decoded)

//                guard let messageRoomId = chat.roomId else {
//                    print("⚠️ Chat missing room_id — skipping:", json)
//                    return
//                }
                let messageRoomId = chat.roomId

                guard  messageRoomId == chat.roomId else {
                    print("⚠️ Chat missing room_id — skipping:", json)
                    return
                }
                // ✅ Use the non-optional `roomId` directly
                guard messageRoomId == roomId else {
                    print("🚫 Ignored chat from another room → \(messageRoomId)")
                    return
                }

                DispatchQueue.main.async {
                    if !self.chats.contains(where: { $0.id == chat.id }) {
                        self.chats.append(chat)
                        self.logger.info("💬 [\(messageRoomId)] Chat from \(chat.username): \(chat.message)")
                    }
                }

            } catch {
                self.logger.error("❌ Chat decode error: \(error.localizedDescription)")
            }
        }
    }

    
    func listenForViewerCount() {
        socket.on("viewerCount") { [weak self] data, _ in
            guard let self else { return }
            if let json = data.first as? [String: Any], let count = json["count"] as? Int {
                viewerCount = count
            } else if let count = data.first as? Int {
                viewerCount = count
            } else {
                logger.warning("❌ Invalid viewer count data: \(String(describing: data))")
            }
        }
    }
    
    func listenForShowTimer(roomId: String) {
        socket.on("show_timer_update") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let roomID = json["room_id"] as? String,
                  let elapsed = json["elapsed"] as? Int,
                  roomID == roomId else { return }
            
            showTime = formatElapsedTime(seconds: elapsed)
        }
    }
    
    func listenForBidTimer(roomId: String) {
        socket.on("bid_timer_update") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let roomID = json["room_id"] as? String,
                  let remaining = json["remaining"] as? Int,
                  roomID == roomId else { return }
            
            bidTime = formatElapsedTime(seconds: remaining)
        }
    }
    
    // MARK: - Timer Handling
    func startLiveScheduler(roomId: String) {
        stopLiveScheduler()
        sendLiveScheduler(roomId: roomId)
        
        liveSchedulerTimer = Timer.scheduledTimer(withTimeInterval: 270, repeats: true) { [weak self] _ in
            self?.sendLiveScheduler(roomId: roomId)
        }
    }
    
    func stopLiveScheduler() {
        liveSchedulerTimer?.invalidate()
        liveSchedulerTimer = nil
    }
    
    private func sendLiveScheduler(roomId: String) {
        performIfConnected {
            let payload = ["room_id": roomId]
            socket.emit("liveScheduler", payload)
            logger.info("📡 Sent liveScheduler for \(roomId)")
        }
    }
    
    // MARK: - Helpers
    private func formatElapsedTime(seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, secs)
    }
    
    func listenForRoomEnded(onEnd: @escaping (_ roomId: String) -> Void) {
        socket.on("roomEnded") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let roomId = json["room_end"] as? String else { return }
            
            logger.info("🏁 Room ended: \(roomId)")
            
            DispatchQueue.main.async {
                // Remove room from active list
                self.rooms.removeAll { $0.room_id == roomId }
                
                // Trigger callback to the ViewModel or UI
                onEnd(roomId)
            }
        }
    }
    func listenForBidFinalized(completion: ((_ roomId: String, _ productId: String, _ winner: HighestBid?) -> Void)? = nil) {
        socket.on("bid_finalized") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let roomId = json["room_id"] as? String else {
                print("❌ Invalid bid_finalized data:", data)
                return
            }
            
            // Parse winner info
            var winner: HighestBid?
                   if let winnerJson = json["winner"] as? [String: Any] {
                       do {
                           let decodedWinner = try JSONSerialization.data(withJSONObject: winnerJson)
                           winner = try JSONDecoder().decode(HighestBid.self, from: decodedWinner)
                       } catch {
                           print("❌ Failed to decode winner:", error)
                       }
                   }

                   // Parse product updates
                   var updatedProducts: [ProductData] = []
                   if let productsJson = json["products"] as? [[String: Any]] {
                       do {
                           let decodedData = try JSONSerialization.data(withJSONObject: productsJson)
                           updatedProducts = try JSONDecoder().decode([ProductData].self, from: decodedData)
                       } catch {
                           print("❌ Failed to decode products:", error)
                       }
                   }
//
            // Update product status in the room
            if let roomIndex = rooms.firstIndex(where: { $0.room_id == roomId }),
                      var updatedRoom = rooms[safe: roomIndex] {

                       // Merge updated products into existing list
                       if var existingProducts = updatedRoom.products {
                           for updatedProduct in updatedProducts {
                               if let productIndex = existingProducts.firstIndex(where: { $0.id == updatedProduct.id }) {
                                   existingProducts[productIndex] = updatedProduct
                               }
                           }
                           updatedRoom.products = existingProducts
                       }

                       // Update winner (highest bid)
                       updatedRoom.highest_bid = winner
                       hasWon = true

                       // Save changes to main array
                       DispatchQueue.main.async {
                           self.rooms[roomIndex] = updatedRoom
                           print("✅ Updated room \(roomId) with sold product and winner \(winner?.user_name ?? "unknown")")
                           print("✅ Updated roomdata  \(self.rooms)")
                           completion?(roomId, winner?.product_id ?? "", winner)
                       }
                   }

                   logger.info("✅ Bid finalized for room \(roomId), product \(winner?.product_id ?? "unknown")")

                   // Trigger completion callback
                   
        }
    }
    
    func listenForNextProduct(completion: ((_ roomId: String, _ nextProductId: String) -> Void)? = nil) {
        socket.on("next_product_set") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let roomId = json["room_id"] as? String else {
                print("❌ Invalid next_product_set data:", data)
                return
            }
            
            // Parse updated products
            var updatedProducts: [ProductData] = []
            if let productsJson = json["products"] as? [[String: Any]] {
                do {
                    let decodedData = try JSONSerialization.data(withJSONObject: productsJson)
                    updatedProducts = try JSONDecoder().decode([ProductData].self, from: decodedData)
                } catch {
                    print("❌ Failed to decode next products:", error)
                }
            }

            // Update room products
            if let roomIndex = rooms.firstIndex(where: { $0.room_id == roomId }),
               var updatedRoom = rooms[safe: roomIndex] {

                // Merge updated products into existing list
                if var existingProducts = updatedRoom.products {
                    for updatedProduct in updatedProducts {
                        if let productIndex = existingProducts.firstIndex(where: { $0.id == updatedProduct.id }) {
                            existingProducts[productIndex] = updatedProduct
                        }
                    }
                    updatedRoom.products = existingProducts
                }

                // Save changes to main array
                DispatchQueue.main.async {
                    self.rooms[roomIndex] = updatedRoom
                    print("✅ Updated room \(roomId) with next product set")
                    print("✅ Updated room data \(updatedRoom) with next product set")
                    completion?(roomId, updatedProducts.first(where: { $0.isCurrent })?.id ?? "")
                }
            }

            logger.info("✅ Next product set for room \(roomId)")
        }
    }


    func observeBidCountdown(for roomId: String,
                             onUpdate: @escaping (Int) -> Void,
                             onStart: @escaping () -> Void,
                             onComplete: @escaping () -> Void) {
        socket.on("bid_timer_update") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let roomID = json["room_id"] as? String,
                  let remaining = json["remaining"] as? Int,
                  roomID == roomId else { return }

            DispatchQueue.main.async {
                onUpdate(remaining)
                
               
                if remaining == 30 {
                    onStart()
                }
                
                
                if remaining == 0 {
                    self.listenForBidFinalized(completion: { roomId, productId, winner in 
                        onComplete()
                    })
                    
                }
            }
        }
    }
    
    func setNextProduct(roomId: String, productId: String) {
        performIfConnected {
            let payload: [String: Any] = [
                "room_id": roomId,
                "product_id": productId
            ]
            socket.emit("set_next_product", payload)
            logger.info("📦 Emitted next product for room \(roomId): product_id=\(productId)")
        }
    }
    
    func listenForHighestBid(forRoom roomId: String,
                             completion: ((_ highestBid: HighestBid?) -> Void)? = nil) {
        socket.on("get_highest_bid") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let incomingRoomId = json["room_id"] as? String else {
                print("❌ Invalid get_highest_bid payload:", data)
                return
            }
            
            // Only handle updates for the specified room
            guard incomingRoomId == roomId else {
                // Ignore events from other rooms
                return
            }
            
            // Parse highest bid info
            var highestBid: HighestBid?
            if let bidJson = json["get_highest_bid"] as? [String: Any] {
                do {
                    let decodedData = try JSONSerialization.data(withJSONObject: bidJson)
                    highestBid = try JSONDecoder().decode(HighestBid.self, from: decodedData)
                } catch {
                    print("❌ Failed to decode get_highest_bid:", error)
                }
            }
            
            // Optionally update your in-memory room list
            if let roomIndex = rooms.firstIndex(where: { $0.room_id == incomingRoomId }),
               var updatedRoom = rooms[safe: roomIndex] {
                
                updatedRoom.highest_bid = highestBid
                DispatchQueue.main.async {
                    self.rooms[roomIndex] = updatedRoom
                    print("✅ [\(incomingRoomId)] Highest Bid: \(highestBid?.user_name ?? "unknown") - \(highestBid?.bid_amount ?? "0")")
                    completion?(highestBid)
                }
            } else {
                DispatchQueue.main.async {
                    completion?(highestBid)
                }
            }
        }
    }


}



//set_next_product { "room_id", "product_id"}
//roomEnded
//Event =  allow_bid_for_all -> payload = room_id = abc , allow_bid_for_all = true/false
//get_highest_bid
//bid_finalized
