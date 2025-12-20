//
//  SocketManager.swift
//  Whitetail Tactical
//
//  Created by Ankit-JAM-E-294 on 10/03/25.
//

struct RoomModel: Codable {
    var products: [ProductDataModel1]?
    let room_id: String?
    let rtc_token: String?
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

struct RaidInfo: Codable {
    var message: String?
    var source_room_id: String?
    var target_room_id: String?
    var rtcToken: String?
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
    @Published var bidTime: String = "00:00"
    @Published var hasWon = false
    @Published var countdownTimer : Int = 30
    /// Published follow status for UI binding
    @Published var isFollowed: Bool = false
    @Published var lastActionSuccess: Bool = false
    
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
    
//     MARK: - Setup
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
//                setupSocket()
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
    
    func removeAllListeners() {
        
        // Remove Core listeners
        removeChatListener()
        removeViewerCountListener()
        removeBidTimerListener()
        removeRoomEndedListener()
        removeHighestBidtListener()
        removeAllowBidForAllListener()
        removeRoomCreateListener()
        removeBidFinalizedListener()
        removeNextProductSetListener()
    }

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
           
            print(data)
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
//                        self.logger.info("💬 [\(messageRoomId)] Chat from \(chat.username ?? ""): \(chat.message ?? "")")
                    }
                }

            } catch {
                self.logger.error("❌ Chat decode error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Remove chat listener
    func removeChatListener() {
        socket.off("chat_get")
        print("🧹 Removed chat listener for 'chat_get'")
    }
    
    func removeViewerCountListener() {
        socket.off("viewerCount")
        print("🧹 Removed viewer count listener for 'chat_get'")
    }
    
    func removeBidTimerListener() {
        socket.off("bid_timer_update")
        print("🧹 Removed bid_timer_update listener")
    }
    
    func removeRoomEndedListener() {
        socket.off("roomEnded")
        print("🧹 Removed roomEnded listener")
    }
    
    func removeHighestBidtListener() {
        socket.off("get_highest_bid")
        print("🧹 Removed Highest Bid listener")
    }
    
    func removeAllowBidForAllListener() {
        socket.off("allow_bid_for_all_get")
        print("🧹 Removed allow_bid_for_all_get listener")
    }
    
    func removeRoomCreateListener() {
        socket.off("room_create_get")
        print("🧹 Removed room_create listener")
    }
    
    func removeBidFinalizedListener() {
        socket.off("bid_finalized")
        print("🧹 Removed bid_finalized listener")
    }
    
    func removeNextProductSetListener() {
        socket.off("next_product_set")
        print("🧹 Removed next_product_set listener")
    }

    
    func listenForViewerCount() {
        socket.on("viewerCount") { [weak self] data, _ in
            guard let self else {
                return
            }
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
        
        if hours > 0 {
            // Show hours if present
            return String(format: "%02d:%02d:%02d", hours, minutes, secs)
        } else {
            // Otherwise only minutes + seconds
            return String(format: "%02d:%02d", minutes, secs)
        }
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
            var updatedProducts: [ProductDataModel1] = []
            if let productsJson = json["products"] as? [[String: Any]] {
                do {
                    let decodedData = try JSONSerialization.data(withJSONObject: productsJson)
                    updatedProducts = try JSONDecoder().decode([ProductDataModel1].self, from: decodedData)
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
            var updatedProducts: [ProductDataModel1] = []
            if let productsJson = json["products"] as? [[String: Any]] {
                do {
                    let decodedData = try JSONSerialization.data(withJSONObject: productsJson)
                    updatedProducts = try JSONDecoder().decode([ProductDataModel1].self, from: decodedData)
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
//                DispatchQueue.main.async {
                    self.rooms[roomIndex] = updatedRoom
                    print("✅ Updated room \(roomId) with next product set")
                    print("✅ Updated room data \(updatedRoom) with next product set")
//                    completion?(roomId, updatedProducts.first(where: { $0.isCurrent })?.id ?? "")
                completion?(roomId, "\(updatedProducts.first?.id ?? 0)")
//                }
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
                
               
                if remaining == self.countdownTimer {
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

    func AllowBidForAll(roomId: String, allow_bid_for_all: Bool) {
        performIfConnected {
            let payload: [String: Any] = [
                "room_id": roomId,
                "allow_bid_for_all": allow_bid_for_all
            ]
            socket.emit("allow_bid_for_all", payload)
            logger.info("📦 Emitted next product for room \(roomId): allow_bid_for_all=\(allow_bid_for_all)")
        }
    }
    func getAllowBidForAll(forRoom roomId: String,
                           completion: ((_ isAllowed: Bool) -> Void)? = nil) {
        
        socket.on("allow_bid_for_all_get") { [weak self] data, _ in
            guard let self = self,
                  let json = data.first as? [String: Any],
                  let incomingRoomId = json["room_id"] as? String,
                  incomingRoomId == roomId else {
                print("❌ Invalid allow bid for all payload:", data)
                completion?(false)
                return
            }
            
            if let isAllowed = json["allow_bid_for_all"] as? Bool {
                completion?(isAllowed)
            } else {
                completion?(false)
            }
        }
    }
    func sendRaidEvent(sourceRoomId: String,
                          targetRoomId: String,
                          sourceHostId: String,
                          targetHostId: String) {
           let payload: [String: Any] = [
               "source_room_id": sourceRoomId,
               "target_room_id": targetRoomId,
               "source_host_id": sourceHostId,
               "target_host_id": targetHostId
           ]
           
           socket.emit("createRaid", payload)
           print("📤 Sent createRaid:", payload)
       }
 
    
    func listenForRaidEvent(completion: @escaping (_ raidInfo: RaidInfo?) -> Void) {
        socket.on("receiveRaid") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any] else {
                print("❌ Invalid receiveRaid payload:", data)
                completion(nil)
                return
            }

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json)
                let raidInfo = try JSONDecoder().decode(RaidInfo.self, from: jsonData)
                print("📥 Received Raid Info:", raidInfo)
                
                // ✅ Example: stop listening for roomEnded in this room
                if let sourceRoom = raidInfo.source_room_id {
                    socket.off("roomEnded")
                    logger.info("🛑 Source room \(sourceRoom) stopped listening for roomEnded due to raid")
                }

                completion(raidInfo)
            } catch {
                print("❌ Failed to decode RaidInfo:", error)
                completion(nil)
            }
        }
    }
    
 
    
    // MARK: - Emit Event (Follow/Unfollow)
    /// Emits the follow_unfollow event with user IDs.
    /// - Parameters:
    ///   - followerId: The ID of the user performing the action.
    ///   - followingId: The ID of the user being followed/unfollowed.
    func sendFollowUnfollow(followerId: String, followingId: String) {
        let payload: [String: Any] = [
            "follower_id": followerId,
            "following_id": followingId
        ]
        
        performIfConnected {
            socket.emit("follow_unfollow", payload)
            logger.info("📤 Sent follow_unfollow: \(payload)")
        }
    }
    
    // MARK: - Listen for follow_unfollow_status
    /// Listens for the follow_unfollow_status event from the server.
    /// Server should respond with something like:
    /// `{ "success": true, "message": "Followed" }`
    func listenForFollowUnfollowStatus() {
        socket.on("follow_unfollow_status") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any] else {
                logger.warning("⚠️ Invalid follow_unfollow_status payload: \(data)")
                return
            }
            
            let success = json["success"] as? Bool ?? false
            let message = json["message"] as? String ?? ""
            
            DispatchQueue.main.async {
                self.lastActionSuccess = success
            }
            
            logger.info("✅ follow_unfollow_status received: success=\(success), message=\(message)")
        }
    }
    
    // MARK: - Listen for user_follow_status
    /// Called when a user joins a room, to check if they follow the seller.
    /// Example server response:
    /// `{ "user_id": "abc123", "seller_id": "xyz789", "is_followed": true }`
    func listenForUserFollowStatus() {
        socket.on("user_follow_status") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any],
                  let isFollowed = json["is_followed"] as? Bool else {
                logger.warning("⚠️ Invalid user_follow_status payload: \(data)")
                return
            }
            
            DispatchQueue.main.async {
                self.isFollowed = isFollowed
                self.logger.info("👤 user_follow_status received: is_followed=\(isFollowed)")
            }
            
            logger.info("👤 user_follow_status received: is_followed=\(isFollowed)")
        }
    }
    
    func listenForRunNextProductError(
        completion: @escaping (_ roomId: String, _ message: String?) -> Void
    ) {
        socket.on("run_next_product_error") { [weak self] data, _ in
            guard let self else { return }

            guard let json = data.first as? [String: Any],
                  let roomId = json["room_id"] as? String else {
                print("❌ Invalid run_next_product_error payload:", data)
                return
            }

            let message = json["message"] as? String

            DispatchQueue.main.async {
                completion(roomId, message)
            }

            self.logger.error("❌ run_next_product_error received for room \(roomId): \(message ?? "Unknown error")")
        }
    }

    
    func removeFollowListener() {
        socket.off("user_follow_status")
        socket.off("follow_unfollow_status")
    }
    

}

extension SocketManagerService {
    func reset(with roomId: String) {
        // Stop timers
        stopLiveScheduler()
        
        // Remove all socket handlers
//        socket?.removeAllHandlers()
        
//        socket.off("receiveRaid")
//        socket.off("allow_bid_for_all_get")
//        socket.off("get_highest_bid")
//        socket.off("next_product_set")
//        socket.off("bid_timer_update")
//        socket.off("bid_finalized")
//        socket.off("roomEnded")
//        socket.off("show_timer_update")
//        socket.off("viewerCount")
//        socket.off("room_create_get")
        
        endStreaming(roomId: roomId)
        
        removeChatListener()
        
        // Disconnect socket
        socket?.disconnect()
        
        // Clear published data
        DispatchQueue.main.async {
            self.isConnected = false
            self.rooms.removeAll()
            self.chats.removeAll()
            self.viewerCount = 0
            self.showTime = "00:00:00"
            self.bidTime = "00:00"
            self.hasWon = false
            self.isFollowed = false
            self.lastActionSuccess = false
        }
        
        logger.info("🧹 SocketManagerService fully reset.")
    }
}

extension SocketManagerService {
    
    // MARK: - 1. Create Poll (Emit)
    
    /// Triggers the creation of a new poll
    /// - Parameter poll: The poll model to create
    func createPoll(poll: PollModel) {
        performIfConnected {
            var payload: [String: Any] = [
                "poll_id": poll.pollId,
                "room_id": poll.roomId,
                "question": poll.question,
                "total_votes": poll.totalVotes,
                "remaining_time": poll.remainingTime,
                "is_active": poll.isActive
            ]

            var optionPayload: [[String: Any]] = []

            for opt in poll.options {
                optionPayload.append([
                    "text": opt.text.text,          // ✅ String
                    "vote_count": opt.voteCount,    // ✅ Int
                    "percentage": opt.percentage    // ✅ Double
                ])
            }

            payload["options"] = optionPayload

            socket.emit("create_poll", payload)
            print("📊 Sent create_poll:", payload)
        }
    }

    
    // MARK: - 2. Poll Created (Listen)
    
    /// Observes when a new poll is created
    /// - Parameter callback: Returns the full poll data
    func observePollCreated(callback: @escaping (PollModel) -> Void) {
        socket.on("poll_created") { data, _ in
            guard let json = data.first as? [String: Any] else {
                print("❌ poll_created: Invalid data format")
                return
            }
            print("📥 Received poll_created raw data:", json)
            do {
                let decoded = try JSONSerialization.data(withJSONObject: json)
                let poll = try JSONDecoder().decode(PollModel.self, from: decoded)
                print("🔄 Received poll_created:\(poll.pollId)")
                callback(poll)
            } catch {
                print("❌ poll_created decode error:", error)
            }
        }
    }
    
    // MARK: - 3. Poll Ended (Listen)
    
    /// Observes when a poll ends
    /// - Parameter callback: Returns the poll ID and room ID
    func observePollEnded(callback: @escaping (_ pollId: String) -> Void) {
        socket.on("poll_ended") { data, _ in
            guard let json = data.first as? [String: Any] else {
                print("❌ poll_ended: Invalid data format")
                return
            }
            
            let pollId = json["poll_id"] as? String ?? ""
            
            print("🛑 Received poll_ended → pollId: \(pollId)")
            
            callback(pollId)
        }
    }
    
    // MARK: - 4. Vote Poll (Emit)
    
    /// Emits a vote for a specific poll option
    /// - Parameters:
    ///   - pollId: The ID of the poll
    ///   - roomId: The ID of the room
    ///   - optionId: The ID of the selected option
    ///   - userId: The ID of the user voting
    func votePoll(poll: PollModel) {
        performIfConnected {
            var payload: [String: Any] = [
                "poll_id": poll.pollId,
                "room_id": poll.roomId,
                "question": poll.question,
                "total_votes": poll.totalVotes,
                "remaining_time": poll.remainingTime,
                "is_active": poll.isActive
            ]
            var optionPayload: [[String: Any]] = [[:]]
            for opt in poll.options {
                optionPayload.append(
                    [
                        "text": opt.text,
                        "vote_count": opt.voteCount,
                        "percentage": opt.percentage
                    ]
                )
            }
            payload["options"] = optionPayload
            socket.emit("vote_poll", payload)
            print("🗳️ Sent vote_poll:", payload)
        }
    }
    
    // MARK: - 5. Poll Vote Update (Listen)
    
    /// Observes real-time vote updates for a poll
    /// - Parameter callback: Returns the updated poll model
    func observePollVoteUpdate(callback: @escaping (PollModel) -> Void) {
        socket.on("poll_vote_update") { data, _ in
            guard let json = data.first as? [String: Any] else {
                print("❌ poll_vote_update: Invalid data format")
                return
            }
            
            print("🔄 Received poll_vote_update raw data:", json)
            do {
                let decoded = try JSONSerialization.data(withJSONObject: json)
                let poll = try JSONDecoder().decode(PollModel.self, from: decoded)
                print("🔄 Received poll_vote_update:\(poll.pollId)")
                callback(poll)
            } catch {
                print("❌ poll_vote_update decode error:", error)
            }
        }
    }
    
    // MARK: - 6. Poll Countdown (Listen)
    
    /// Observes real-time countdown updates for a poll
    /// - Parameter callback: Returns poll ID, room ID, and remaining time in seconds
    func observePollCountdown(callback: @escaping (_ pollId: String, _ roomId: String, _ remainingTime: TimeInterval) -> Void) {
        socket.on("poll_countdown") { data, _ in
            guard let json = data.first as? [String: Any] else {
                print("❌ poll_countdown: Invalid data format")
                return
            }
            
            let pollId = json["poll_id"] as? String ?? ""
            let roomId = json["room_id"] as? String ?? ""
            let remainingTime = json["remaining_time"] as? TimeInterval ?? 0
            
            print("⏱️ Received poll_countdown → pollId: \(pollId), roomId: \(roomId), remaining: \(remainingTime)s")
            
            callback(pollId, roomId, remainingTime)
        }
    }
    
    // MARK: - Additional Helper Functions
    
    /// Ends a poll manually (host action)
    /// - Parameters:
    ///   - pollId: The ID of the poll to end
    ///   - roomId: The ID of the room
    func endPoll(pollId: String, roomId: String) {
        performIfConnected {
            let payload: [String: Any] = [
                "poll_id": pollId,
                "room_id": roomId
            ]
            
            socket.emit("end_poll", payload)
            print("🛑 Sent end_poll:", payload)
        }
    }
    
    func sendPromotionEvent(userId: String, showId: String, promoteShowId: String) {
        performIfConnected {
            let payload: [String: Any] = [
                "user_id": userId,
                "show_id": showId,
                "promote_show_id": promoteShowId
            ]
            
            socket.emit("set_promotion_data", payload)
            print("🚀 Sent set_promotion_data event:", payload)
        }
    }
    
    /// Observes vote errors
    /// - Parameter callback: Returns poll ID, room ID, and error message
    func observeVoteError(callback: @escaping (_ pollId: String, _ roomId: String, _ message: String) -> Void) {
        socket.on("vote_error") { data, _ in
            guard let json = data.first as? [String: Any] else {
                print("❌ vote_error: Invalid data format")
                return
            }
            
            let pollId = json["poll_id"] as? String ?? ""
            let roomId = json["room_id"] as? String ?? ""
            let message = json["message"] as? String ?? "Vote error occurred"
            
            print("⚠️ Received vote_error → \(message)")
            
            callback(pollId, roomId, message)
        }
    }
    
    /// Removes all poll-related listeners
    func removePollListeners() {
        socket.off("poll_created")
        socket.off("poll_ended")
        socket.off("poll_vote_update")
        socket.off("poll_countdown")
        socket.off("vote_error")
        
        print("🗑️ Removed all poll listeners")
    }
}

extension SocketManagerService {

    // MARK: - Emit Event: Add Show Note
    /// Sends a show note to be stored in the database.
    /// - Parameters:
    ///   - roomId: Room identifier
    ///   - showNote: Note text
    func sendAddShowNote(roomId: String, showNote: String) {
        let payload: [String: Any] = [
            "room_id": roomId,
            "show_note": showNote
        ]

        performIfConnected {
            socket.emit("add_show_note", payload)
            logger.info("📤 Sent add_show_note: \(payload)")
        }
    }
    
    // MARK: - Listen: Get Show Notes Response
    /// Listens for show notes fetched from the server.
    /// Expected server payload example:
    /// `{ "success": true, "data": [ { "id": 1, "show_note": "...", "created_at": "..." } ] }`
    ///
    func listenForGetShowNote(completion: @escaping (String) -> Void) {
        socket.on("get_show_note") { [weak self] data, _ in
            guard let self = self else { return }

            guard let json = data.first as? [String: Any] else {
                logger.warning("⚠️ Invalid get_show_note payload: \(data)")
                return
            }

            let notes = json["show_note"] as? String ?? ""

            DispatchQueue.main.async {
                completion(notes)
            }

            logger.info("✅ get_show_note received, notesCount=\(notes.count)")
        }
    }
    
    func runNextProduct(roomId: String) {
        performIfConnected {
            let payload: [String: Any] = [
                "room_id": roomId
            ]
            socket.emit("run_next_product", payload)
            logger.info("📦 Emitted run_next_product for room \(roomId)")
        }
    }
    
    func listenForAuctionNextProduct(
        completion: @escaping (_ roomId: String, _ product: ProductDataModel1, _ source: String?) -> Void
    ) {
        socket.on("auction_next_product") { [weak self] data, _ in
            guard let self else { return }

            guard
                let json = data.first as? [String: Any],
                let roomId = json["room_id"] as? String,
                let productJson = json["product"] as? [String: Any]
            else {
                print("❌ Invalid auction_next_product payload:", data)
                return
            }

            do {
                let decodedData = try JSONSerialization.data(withJSONObject: productJson)
                let product = try JSONDecoder().decode(ProductDataModel1.self, from: decodedData)

                let source = json["source"] as? String

                DispatchQueue.main.async {
                    completion(roomId, product, source)
                }

                self.logger.info("✅ auction_next_product received for room \(roomId)")

            } catch {
                print("❌ Failed to decode auction_next_product:", error)
            }
        }
    }

    func listenForProductUnpinned(
        completion: @escaping (_ roomId: String, _ productId: String, _ message: String?) -> Void
    ) {
        socket.on("product_unpinned") { [weak self] data, _ in
            guard let self else { return }

            guard let json = data.first as? [String: Any],
                  let roomId = json["room_id"] as? String,
                  let productId = json["product_id"] as? String else {
                print("❌ Invalid product_unpinned payload:", data)
                return
            }

            let message = json["message"] as? String

            DispatchQueue.main.async {
                completion(roomId, productId, message)
            }

            self.logger.info(
                "📌 product_unpinned received | roomId: \(roomId), productId: \(productId), message: \(message ?? "")"
            )
        }
    }



    
    func startAuction(
        roomId: String,
        products: [String],
        startingBidAmount: String,
        requireTime: Int,
        counterBidTime: Int,
        suddenDeath: Bool
    ) {
        performIfConnected {
            let payload: [String: Any] = [
                "room_id": roomId,
                "products": products,
                "starting_bid_amount": startingBidAmount,
                "require_time": requireTime,
                "counter_bid_time": counterBidTime,
                "sudden_death": suddenDeath
            ]
            hasWon = false
            socket.emit("start_auction", payload)
            logger.info("🚀 Sent start_auction: \(payload)")
        }
    }
    func listenForAuctionStarted(
        completion: @escaping (
            _ roomId: String,
            _ products: [ProductDataModel1],
            _ startingBidAmount: String,
            _ requireTime: Int,
            _ counterBidTime: Int,
            _ suddenDeath: Bool
        ) -> Void
    ) {
        socket.on("auction_started") { [weak self] data, _ in
            guard let self else { return }

            guard
                let json = data.first as? [String: Any],
                let roomId = json["room_id"] as? String
            else {
                print("❌ Invalid auction_started payload:", data)
                return
            }
            
            let startingBidAmount = json["starting_bid_amount"] as? String ?? ""
            let requireTime = json["require_time"] as? Int ?? 0
            let counterBidTime = json["counter_bid_time"] as? Int ?? 0
            let suddenDeath = json["sudden_death"] as? Bool ?? false

            var products: [ProductDataModel1] = []

            // ✅ FIX: product is a SINGLE dictionary
            if let productJson = json["product"] as? [String: Any] {
                do {
                    let data = try JSONSerialization.data(withJSONObject: productJson)
                    let product = try JSONDecoder().decode(ProductDataModel1.self, from: data)
                    products = [product]   // ✅ wrap into array
                } catch {
                    print("❌ Failed to decode auction_started product:", error)
                }
            }

            self.countdownTimer = counterBidTime

            DispatchQueue.main.async {
                completion(
                    roomId,
                    products,
                    startingBidAmount,
                    requireTime,
                    counterBidTime,
                    suddenDeath
                )
            }

            self.logger.info("🔥 auction_started received for room \(roomId)")
        }
    }


    func removeAuctionListeners() {
        socket.off("auction_next_product")
        socket.off("auction_started")
        print("🧹 Removed auction listeners")
    }
    // MARK: - Emit Event: Get Show Notes
    /// Requests stored show notes for a room.
    /// - Parameter roomId: Room identifier
//    func getShowNote(roomId: String) {
//        let payload: [String: Any] = [
//            "room_id": roomId
//        ]
//
//        performIfConnected {
//            socket.emit("get_show_note", payload)
//            logger.info("📤 Sent get_show_note: \(payload)")
//        }
//    }
}

extension SocketManagerService {
    // MARK: - Emit Event: Pin Product
    /// Pins a product inside a room.
    /// - Parameters:
    ///   - roomId: Room identifier
    ///   - productId: Product identifier
    func sendPinProduct(roomId: String, productId: String) {
        let payload: [String: Any] = [
            "room_id": roomId,
            "product_id": productId
        ]
        
        performIfConnected {
            socket.emit("pin_product", payload)
            logger.info("📤 Sent pin_product: \(payload)")
        }
    }
    
    // MARK: - Listen: Product Pinned Status
    /// Listens for pinned/unpinned product updates.
    /// Expected server payload:
    /// { "product_id": "...", "pinned": Bool }
    func listenForPinnedProductStatus(
        completion: @escaping (_ roomId: String, _ productId: String, _ message: String?) -> Void
    ) {
        socket.on("product_pinned") { data, _ in
            
            guard let json = data.first as? [String: Any],
                  let roomId = json["room_id"] as? String,
                  let productId = json["product_id"] as? String else {
                print("❌ Invalid product_unpinned payload:", data)
                return
            }
            
            let message = json["message"] as? String
            
            DispatchQueue.main.async {
                completion(roomId, productId, message)
            }
            
            self.logger.info(
                "📌 product_pinned received | roomId: \(roomId), productId: \(productId), message: \(message ?? "")"
            )
        }
    }
    
}

// MARK: - Tip Events
extension SocketManagerService {

    // MARK: - Emit: Save Tip Settings
    /// Sends tip settings for a live show
    /// - Parameters:
    ///   - showId: The ID of the show
    ///   - tipMessage: The tip message to display
    ///   - showInLiveChat: Whether the tip message should appear in live chat
    func saveTipSettings(showId: String, tipMessage: String, showInLiveChat: Bool) {
        let payload: [String: Any] = [
            "show_id": showId,
            "tip_message": tipMessage,
            "show_in_live_chat": showInLiveChat
        ]
        
        performIfConnected {
            socket.emit("tip_setting_save", payload)
            logger.info("💰 Sent tip_setting_save: \(payload)")
        }
    }

    // MARK: - Listen: Tip Setting Updated
    /// Listen for updates to tip settings
    /// - Parameter completion: Returns showId, tipMessage, and showInLiveChat status
    func listenForTipSettingUpdated(completion: @escaping (_ showId: String, _ tipMessage: String, _ showInLiveChat: Bool) -> Void) {
        socket.on("tip_setting_updated") { data, _ in
            guard let json = data.first as? [String: Any],
                  let showId = json["show_id"] as? String,
                  let tipMessage = json["tip_message"] as? String,
                  let showInLiveChat = json["show_in_live_chat"] as? Bool else {
                self.logger.warning("⚠️ Invalid tip_setting_updated payload: \(data)")
                return
            }
            
            DispatchQueue.main.async {
                completion(showId, tipMessage, showInLiveChat)
            }
            
            self.logger.info("✅ tip_setting_updated received for show \(showId)")
        }
    }

    // MARK: - Emit: Send Tip
    /// Sends a tip during a live show
    /// - Parameters:
    ///   - showId: The ID of the show
    ///   - userId: The ID of the user sending the tip
    ///   - amount: The tip amount
    ///   - message: Optional message with the tip
    func sendTip(showId: String, userId: Int, amount: Double, message: String?) {
        var payload: [String: Any] = [
            "show_id": showId,
            "user_id": userId,
            "amount": amount
        ]
        
        if let message {
            payload["message"] = message
        }
        
        performIfConnected {
            socket.emit("send_tip", payload)
            logger.info("💸 Sent send_tip: \(payload)")
        }
    }

    

    // MARK: - Remove Tip Listeners
    func removeTipListeners() {
        socket.off("tip_setting_updated")
        socket.off("tip_received")
        print("🗑️ Removed all tip listeners")
    }
}
