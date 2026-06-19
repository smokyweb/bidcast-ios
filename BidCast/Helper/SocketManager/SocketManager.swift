//
//  SocketManager.swift
//  Whitetail Tactical
//
//  Created by Ankit-JAM-E-294 on 10/03/25.
//

// MARK: - 🎁 Freebie Model -
struct FreebieModel: Codable, Identifiable {
    var id: Int?
    var freebie_id: Int?
    var randomizer_active_freebie_id: Int?
    var randomizer_template_id: Int?
    var template_id: Int?
    var show_id: String?
    var product_id: String?
    var duration: String?
    var room_id : String?
    var entry_cost: Double?
    var template_type: String?
    var randomizer_slots: [RandomizerSlot]?
    var slots: [RandomizerSlot]?
    
}
struct FreebieSocketPayload: Codable {
    var freebie: FreebieModel
    var users_list: [FreebieUser]?
}
struct FreebieWinnerPayload: Codable {
    var show_id: String?
    var room_id : String?
    var user: FreebieUser?
    var total: Int?
}
struct FreebieLiveUser: Codable {
    var show_id: String?
    var room_id : String?
    var users: [FreebieUser]?
    var total: Int?
    // memberwise init is synthesized; also expose a no-arg init for fallback
    init(show_id: String? = nil, room_id: String? = nil, users: [FreebieUser]? = nil, total: Int? = nil) {
        self.show_id = show_id; self.room_id = room_id; self.users = users; self.total = total
    }
}

struct FreebieUser: Identifiable {
    var id: Int?
    var name: String?
    var email: String?
    var username: String?
    var profile_image: String?
}

// Basecamp #9940079895 (2026-05-29 RETURN): flexible Codable for FreebieUser so
// a string `id` from the server ("123" vs 123) doesn't blow up the whole
// [FreebieUser] decode and leave liveViewers empty. This was the known
// non-optional-type-mismatch pattern that silently drops whole arrays.
extension FreebieUser: Codable {
    enum CodingKeys: String, CodingKey {
        case id, name, email, username, profile_image
    }
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        // Accept id as Int or String
        if let intId = try? c.decodeIfPresent(Int.self, forKey: .id) {
            self.id = intId
        } else if let strId = try? c.decodeIfPresent(String.self, forKey: .id) {
            self.id = Int(strId)
        } else {
            self.id = nil
        }
        self.name          = try? c.decodeIfPresent(String.self, forKey: .name)
        self.email         = try? c.decodeIfPresent(String.self, forKey: .email)
        self.username      = try? c.decodeIfPresent(String.self, forKey: .username)
        self.profile_image = try? c.decodeIfPresent(String.self, forKey: .profile_image)
    }
    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try? c.encodeIfPresent(id,            forKey: .id)
        try? c.encodeIfPresent(name,          forKey: .name)
        try? c.encodeIfPresent(email,         forKey: .email)
        try? c.encodeIfPresent(username,      forKey: .username)
        try? c.encodeIfPresent(profile_image, forKey: .profile_image)
    }
}

// MARK: - 🎁 Room Model -
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
    var bid_count_down: String?
    let show_timer: String?
    var is_room_created : Bool?
    var productCount : Int?
    var auction_type_id: Int?
    var category_id: String?
    var date: String?
    // Basecamp #9933883175 / #9933877362 (2026-05-27): seller-controlled
    // verified-buyers-only gate. Hydrated from the join_room payload that the
    // node socket server broadcasts (server-side patch deployed 2026-05-27).
    var is_verified_only: Bool?
    var id: String { room_id ?? "" }
}

// MARK: - 🎁 Highest Bid Model -
struct HighestBid: Codable {
    var bid_amount: String?
    var user_name: String?
    var user_image: String?
    var user_id: String?
    var product_id: String?
    var placed_at: String?

    var product_set_id: String?
    var product_set_item_id: Int?
    var product_set_item_unit_id: Int?

    enum CodingKeys: String, CodingKey {
        case bid_amount, user_name, user_image, user_id, product_id, placed_at
        case product_set_id, product_set_item_id, product_set_item_unit_id
    }

    init() {}

    // Basecamp #9955246140 (2026-06-02): CROSS-PLATFORM TOLERANT DECODE.
    // The PWA emits bid fields (bid_amount/user_id/product_id) as JSON numbers
    // while iOS emits them as strings. A strict synthesized decoder threw a
    // typeMismatch on number-where-String-expected, so a PWA buyer's bid made
    // the seller's decode fail silently (no bid shown, price stuck, no sold).
    // The socket server now normalizes these to strings, but decode tolerantly
    // here too (defense in depth) so a String OR a Number both work regardless
    // of who placed the bid.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        func str(_ key: CodingKeys) -> String? {
            if let s = try? c.decodeIfPresent(String.self, forKey: key) { return s }
            if let i = try? c.decodeIfPresent(Int.self, forKey: key) { return String(i) }
            if let d = try? c.decodeIfPresent(Double.self, forKey: key) {
                // render whole numbers without a trailing .0
                return d == d.rounded() ? String(Int(d)) : String(d)
            }
            return nil
        }
        func intVal(_ key: CodingKeys) -> Int? {
            if let i = try? c.decodeIfPresent(Int.self, forKey: key) { return i }
            if let s = try? c.decodeIfPresent(String.self, forKey: key) { return Int(s) }
            if let d = try? c.decodeIfPresent(Double.self, forKey: key) { return Int(d) }
            return nil
        }
        bid_amount = str(.bid_amount)
        user_name = try? c.decodeIfPresent(String.self, forKey: .user_name)
        user_image = try? c.decodeIfPresent(String.self, forKey: .user_image)
        user_id = str(.user_id)
        product_id = str(.product_id)
        placed_at = try? c.decodeIfPresent(String.self, forKey: .placed_at)
        product_set_id = str(.product_set_id)
        product_set_item_id = intVal(.product_set_item_id)
        product_set_item_unit_id = intVal(.product_set_item_unit_id)
    }
}
// MARK: - 🎁 Raid Model -
struct RaidInfo: Codable {
    var message: String?
    var source_room_id: String?
    var target_room_id: String?
    var rtcToken: String?

    enum CodingKeys: String, CodingKey {
        case message
        case source_room_id
        case target_room_id
        case rtcToken = "rtc_token"
    }

    enum FallbackCodingKeys: String, CodingKey {
        case rtcToken
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        source_room_id = try container.decodeIfPresent(String.self, forKey: .source_room_id)
        target_room_id = try container.decodeIfPresent(String.self, forKey: .target_room_id)
        rtcToken = try container.decodeIfPresent(String.self, forKey: .rtcToken)
        if rtcToken == nil {
            let fallback = try decoder.container(keyedBy: FallbackCodingKeys.self)
            rtcToken = try fallback.decodeIfPresent(String.self, forKey: .rtcToken)
        }
    }

    init(message: String? = nil, source_room_id: String? = nil, target_room_id: String? = nil, rtcToken: String? = nil) {
        self.message = message
        self.source_room_id = source_room_id
        self.target_room_id = target_room_id
        self.rtcToken = rtcToken
    }
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
    // Basecamp #9934003774 (2026-05-27): live viewer list for the host kick-UI.
    // Updated whenever active_show_users fires.
    @Published var liveViewers: [FreebieUser] = []
    @Published var viewerCount: Int = 0
    @Published var showTime: String = "00:00:00"
    @Published var bidTime: String = "00:00"
    @Published var bidAddedSeconds: Int = 0
    @Published var hasWon = false
    @Published var countdownTimer : Int = 30
    /// Published follow status for UI binding
    @Published var isFollowed: Bool = false
    @Published var lastActionSuccess: Bool = false
    @Published var currentFreebie: FreebieModel?
    @Published var hasHit60SecAPI = false

    
    // MARK: - Callbacks
    var onRoomsUpdated: (([String]) -> Void)?
    
    // MARK: - Private Properties
    var hasAddedListeners = false
    private var liveSchedulerTimer: Timer?
    private var socket: SocketIOClient!
    private var socketManager: SocketManager!
    private let logger = Logger(subsystem: "io.bidcast", category: "Socket")
    private var sustainedWatchWorkItem: DispatchWorkItem?
    
    // MARK: - Init
    override private init() {
        super.init()
    }

    
    // MARK: - Helpers
    func formatElapsedTime(seconds: Int) -> String {
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
    
    func secondsFromTimeString(_ time: String) -> Int {
        let components = time.split(separator: ":").map { Int($0) ?? 0 }

        if components.count == 3 {
            // HH:MM:SS
            return components[0] * 3600 + components[1] * 60 + components[2]
        } else if components.count == 2 {
            // MM:SS
            return components[0] * 60 + components[1]
        }

        return 0
    }

    
}

// MARK: - Socket Lifecycle
extension SocketManagerService {

    func setupSocket(onConnected: (() -> Void)? = nil) {
        socketManager = SocketManager(
            socketURL: URL(string: "https://node.bidcast.betaplanets.com")!,
            config: [.log(false), .compress, .reconnects(true), .path("/socket.io")]
        )
        
        socket = socketManager.defaultSocket
        if socket.status != .connected{
            socket.on(clientEvent: .connect) { [weak self] _, _ in
                guard let self else { return }
                
                
                logger.info("✅ Socket connected")
                // Basecamp #9940079895 (2026-05-29): the connect handler never
                // flipped `isConnected` to true, so every UI gate that checked
                // `socketManager.isConnected` (e.g. the host kick-buyer button)
                // saw `false` forever and silently no-op'd with
                // "Socket not connected". Mark connected here.
                self.isConnected = true
                if socket.status == .connected{
                    
                    onConnected?()
                }
                //            onConnected?()
            }
        }else{
            if socket.status == .connected{
                logger.info("✅ Socket connected")
                self.isConnected = true
                onConnected?()
            }
        }
        
        socket.on(clientEvent: .disconnect) { [weak self] data, _ in
            guard let self else { return }
            self.isConnected = false
            self.hasAddedListeners = false
            logger.warning("❌ Disconnected: \(String(describing: data))")
        }
        
        socket.on(clientEvent: .error) { [weak self] data, _ in
            self?.logger.error("⚠️ Socket error: \(String(describing: data))")
        }
        
        socket.connect()
        logger.info("✅ Socket connected")
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
}


//MARK: - Remove Lsitener -

extension SocketManagerService{
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
    func removeRoomHandler(){
        socket.off("room_update")
           socket.off("room_ended")
        print("🧹 Removed room listener")
    }
    
}

// MARK: - Raid Events -
extension SocketManagerService {
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
        socket.off("receiveRaid")
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
                
                if let sourceRoom = raidInfo.source_room_id {
                    logger.info("🛑 Raid transition from source room \(sourceRoom)")
                }

                completion(raidInfo)
            } catch {
                print("❌ Failed to decode RaidInfo:", error)
                completion(nil)
            }
        }
    }
    
}


// MARK: - Room Events
extension SocketManagerService {
    func createRoom(payload: [String: Any]) {
        performIfConnected {
            socket.emit("room_create", payload)
            logger.info("📡 Creating room: \(payload)")
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
        
    func listenForRoomEnded(onEnd: @escaping (_ roomId: String) -> Void) {
        socket.on("roomEnded") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let roomId = (json["room_end"] as? String) ?? (json["room_id"] as? String) else { return }

            if (json["raid"] as? Bool) == true {
                logger.info("🏁 Ignoring raid source-room end: \(roomId)")
                return
            }
            
            logger.info("🏁 Room ended: \(roomId)")
            
            DispatchQueue.main.async {
                // Remove room from active list
                self.rooms.removeAll { $0.room_id == roomId }
                
                // Trigger callback to the ViewModel or UI
                onEnd(roomId)
            }
        }
    }
    
}


// MARK: - Viewer & Timer Events
extension SocketManagerService {

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
            let totalSeconds = self.secondsFromTimeString(self.showTime)

                if totalSeconds >= 60 && !self.hasHit60SecAPI {
                   hasHit60SecAPI = true
                }
        }
    }
    
  
    func listenForBidTimer(roomId: String) {
        socket.on("bid_timer_update") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let roomID = json["room_id"] as? String,
                  roomID == roomId else { return }
            let remaining = (json["remaining"] as? Int)
                ?? Int("\(json["remaining"] ?? "")")
                ?? 0
            let addedSeconds = (json["added_seconds"] as? Int)
                ?? (json["addedSeconds"] as? Int)
                ?? Int("\(json["added_seconds"] ?? json["addedSeconds"] ?? "")")
                ?? 0
            
            bidTime = formatElapsedTime(seconds: remaining)
            if addedSeconds > 0 {
                bidAddedSeconds = addedSeconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
                    guard let self else { return }
                    if self.bidAddedSeconds == addedSeconds {
                        self.bidAddedSeconds = 0
                    }
                }
            }
        }
    }

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
}


// MARK: - Chat Events
extension SocketManagerService {

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

    // MARK: - Load chat history (Basecamp #9944417027, 2026-05-29)
    // The live `chat_get` socket event only delivers NEW messages after the
    // client has joined the room. On entering a room (host AND buyer) we pull
    // the existing transcript from REST so prior messages are visible.
    // GET /api/live_chat/{room_id} -> { success, room_id, chats: [...] }
    // Each chat element reuses CommentModel's coding keys (user_image,
    // user_name, message, user_id, room_id).
    func loadChatHistory(roomId: String) {
        let encodedRoom = roomId.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? roomId
        guard let url = URL(string: "https://backend.bidcast.betaplanets.com/api/live_chat/\(encodedRoom)") else {
            logger.warning("⚠️ loadChatHistory: bad URL for room \(roomId)")
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self else { return }
            if let error = error {
                self.logger.error("❌ loadChatHistory error: \(error.localizedDescription)")
                return
            }
            guard let data = data,
                  let root = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any],
                  let rawChats = root["chats"] as? [[String: Any]] else {
                return
            }
            var history: [CommentModel] = []
            for raw in rawChats {
                if let chatData = try? JSONSerialization.data(withJSONObject: raw),
                   let chat = try? JSONDecoder().decode(CommentModel.self, from: chatData) {
                    history.append(chat)
                }
            }
            guard !history.isEmpty else { return }
            DispatchQueue.main.async {
                // Prepend any history rows we don't already have, preserving order.
                let existingIDs = Set(self.chats.map { $0.id })
                let newOnes = history.filter { !existingIDs.contains($0.id) }
                guard !newOnes.isEmpty else { return }
                self.chats = newOnes + self.chats
                self.logger.info("📜 Loaded \(newOnes.count) chat history rows for \(roomId)")
            }
        }.resume()
    }
}



extension SocketManagerService {
    
    // MARK: - 1. Create Poll (Emit)
    
    func joinShowForPromotionalData(room_id:String,UserId : String) {
        performIfConnected {
            let payload: [String: Any] = [
                "room_id": room_id,
                "user_id": UserId,
            ]
            
            socket.emit("join_show", payload)
            print("📊 Sent join_show :", payload)
            sustainedWatchWorkItem?.cancel()
            
            // Create new delayed task
            let workItem = DispatchWorkItem { [weak self] in
                self?.sustainedWatchesForPromotionalData(room_id: room_id, UserId: UserId)
            }
            
            sustainedWatchWorkItem = workItem
            
            // ⏱ Fire after 30 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 30, execute: workItem)
            
        }
    }

    func sustainedWatchesForPromotionalData(room_id:String,UserId : String) {
        performIfConnected {
            let payload: [String: Any] = [
                "room_id": room_id,
                "user_id": UserId,
            ]

            socket.emit("sustained_watches", payload)
            print("📊 Sent sustained_watches :", payload)
        }
    }
    func leaveShow(showId:String,UserId : String) {
        performIfConnected {
            let payload: [String: Any] = [
                "show_id": showId,
                "user_id": UserId,
            ]

            socket.emit("leave_show", payload)
            print("📊 Sent sustained_watches :", payload)
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
   
}

extension SocketManagerService {

    func sendAddShowNote(roomId: String, showNote: String) {
        // Basecamp #9933402746 (2026-05-27 round 2): server-side add_show_note
        // performs an ownership check using payload.user_id — if user_id is
        // missing, the check fails String(owner) !== String(undefined) and
        // the update is silently dropped, so buyers never see the new note.
        // Include user_id from UserDefaults.userId.
        var payload: [String: Any] = [
            "room_id": roomId,
            "show_note": showNote
        ]
        if UserDefaults.userId > 0 {
            payload["user_id"] = UserDefaults.userId
        }

        performIfConnected {
            socket.emit("add_show_note", payload)
            logger.info("📤 Sent add_show_note: \(payload)")
        }
    }

    // Basecamp #9933402746 (2026-05-27 round 2): explicit on-demand request
    // for current show notes. Buyer side emits this after join_room to
    // ensure they get the current value even if the join_room broadcast was
    // missed (race / ordering / silent listener registration failure).
    func requestShowNote(roomId: String) {
        performIfConnected {
            socket.emit("request_show_note", ["room_id": roomId])
            logger.info("📤 Sent request_show_note for room \(roomId)")
        }
    }

    // Basecamp #9934003774 (2026-05-27 round 2): seller-side explicit fetch
    // for current viewer list. Trey reports the viewer-list sheet says "no
    // viewers" even when buyers are in the room. The standard active_show_users
    // broadcast only fires on join_show — if any buyer joined before the
    // seller's listener was registered, the seller has stale empty state.
    // Emitting this triggers the server to re-broadcast the current list.
    func requestActiveShowUsers(roomId: String) {
        performIfConnected {
            socket.emit("request_active_show_users", ["room_id": roomId])
            logger.info("📤 Sent request_active_show_users for room \(roomId)")
        }
    }
    
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
    
}

// MARK: - Emit Event: Pin Product
extension SocketManagerService {
    
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
    

    func listenForPinnedProductStatus(
        completion: @escaping (_ roomId: String, _ productId: String, _ message: String?, _ multipleProductId : [Int]) -> Void
    ) {
        socket.on("product_pinned") { data, _ in
            
            guard let json = data.first as? [String: Any],
                         let roomId = json["room_id"] as? String,
                         let productId = json["product_id"] as? Int,
                         let productIds = json["pinned_products"] as? [Int] else {
                       print("❌ Invalid product pinned payload:", data)
                       return
                   }
            
            let message = json["message"] as? String
            
            DispatchQueue.main.async {
                completion(roomId, "\(productId)", message,productIds)
            }
            
            self.logger.info(
                "📌 product_pinned received | roomId: \(roomId), productId: \(productId), message: \(message ?? "") , productIds : \(productIds)"
            )
        }
    }
    func listenForProductUnpinned(
        completion: @escaping (_ roomId: String, _ productId: String, _ message: String?) -> Void
    ) {
        socket.on("product_unpinned") { [weak self] data, _ in
            guard let self else { return }

            guard let json = data.first as? [String: Any],
                  let roomId = json["room_id"] as? String,
                  let productId = json["product_id"] as? Int else {
                print("❌ Invalid product_unpinned payload:", data)
                return
            }

            let message = json["message"] as? String

            DispatchQueue.main.async {
                completion(roomId, "\(productId)", message)
            }

            self.logger.info(
                "📌 product_unpinned received | roomId: \(roomId), productId: \(productId), message: \(message ?? "")"
            )
        }
    }
}

// MARK: - Auction & Bid Events -
extension SocketManagerService {

    func sendBid(payload: [String: Any]) {
        performIfConnected {
            socket.emit("place_bid", payload)
            logger.info("📡 Sending bid: \(payload)")
        }
    }

    func listenForBidRejected(forRoom roomId: String, completion: ((_ message: String) -> Void)? = nil) {
        socket.off("place_bid_rejected")
        socket.on("place_bid_rejected") { data, _ in
            guard let json = data.first as? [String: Any],
                  let incomingRoomId = json["room_id"] as? String,
                  incomingRoomId == roomId else {
                return
            }

            let message = json["message"] as? String ?? "Bid was not accepted. Please try again."
            DispatchQueue.main.async {
                completion?(message)
            }
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

    func startAuction(
        roomId: String,
        products: [String],
        startingBidAmount: String? = nil,
        requireTime: Int? = nil,
        counterBidTime: Int? = nil,
        suddenDeath: Bool? = nil,
        auctionTypeId:Int
    ) {
        performIfConnected {
//            var payload: [String: Any] = [
//                "room_id": roomId,
//                "products": products,
//                "starting_bid_amount": startingBidAmount,
//                "require_time": requireTime,
//                "sudden_death": suddenDeath,
//                "auction_type_id":auctionTypeId
//            ]
            var payload: [String: Any] = [
                "room_id": roomId,
                "products": products,
                "auction_type_id": auctionTypeId
            ]
            if let startingBidAmount {
                payload["starting_bid_amount"] = startingBidAmount
            }
            if let requireTime {
                payload["require_time"] = requireTime
            }
            if let suddenDeath {
                payload["sudden_death"] = suddenDeath
                
                if suddenDeath == false, let counterBidTime {
                    payload["counter_bid_time"] = counterBidTime
                }
            }

           
            hasWon = false
            socket.emit("start_auction", payload)
            logger.info("🚀 Sent start_auction: \(payload)")
        }
    }
    func listenForAuctionStarted(
        completion: @escaping (
            _ status:String,
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
            hasWon = false
            guard
                let json = data.first as? [String: Any],
                let roomId = json["room_id"] as? String
            else {
                print("❌ Invalid auction_started payload:", data)
                return
            }
            
            let startingBidAmount = json["starting_bid_amount"] as? String ?? ""
            let status = json["status"] as? String ?? ""
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
                    status,
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

    func addProductsToShow(roomId: String, productIds: [String]) {
        performIfConnected {
            let payload: [String: Any] = [
                "room_id": roomId,
                "product_ids": productIds
            ]
            socket.emit("add_products_to_show", payload)
            logger.info("📦 Emitted add products for room \(roomId): product_ids=\(productIds.joined(separator: ","))")
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

    
    func removeAuctionListeners() {
        socket.off("auction_next_product")
        socket.off("auction_started")
        print("🧹 Removed auction listeners")
    }
    
    func startAuctionBreakSpot(
           roomId: String,
           productSetId: Int,
           productSetItemId: Int,
           productSetItemUnitId: Int,
           startingBidAmount: Double,
           requireTime: Int,
           counterBidTime: Int,
           suddenDeath: Bool
       ) {
           performIfConnected {
               let payload: [String: Any] = [
                   "room_id": roomId,
                   "productSetId": productSetId,
                   "productSetItemId": productSetItemId,
                   "productSetItemUnitId": productSetItemUnitId,
                   "starting_bid_amount": startingBidAmount,
                   "require_time": requireTime,
                   "counter_bid_time": counterBidTime,
                   "sudden_death": suddenDeath
               ]
               
               hasWon = false
               socket.emit("start_auction_break_spot", payload)
               logger.info("🎁 Sent start_auction_break_spot: \(payload)")
           }
       }
       
       /// Listens for `auction_started_break_spot` event
       func listenForAuctionStartedBreakSpot(
           completion: @escaping (
            _ responseData:AuctionStartedBreakSpotResponse,
               _ status: String,
               _ roomId: String,
               _ productSetId: Int,
               _ productSetItemId: Int,
               _ productSetItemUnitId: Int,
               _ startingBidAmount: String,
               _ requireTime: Int,
               _ counterBidTime: Int,
               _ suddenDeath: Bool
           ) -> Void
       ) {
           socket.on("auction_started_break_spot") { [weak self] data, _ in
               guard let self,
                     let json = data.first as? [String: Any],
                     let jsonData = try? JSONSerialization.data(withJSONObject: json)
               else {
                   print("❌ Invalid socket payload")
                   return
               }
               hasWon = false
               do {
                   let response = try JSONDecoder().decode(
                       AuctionStartedBreakSpotResponse.self,
                       from: jsonData
                   )

                   self.countdownTimer = response.counterBidTime ?? 0

                   DispatchQueue.main.async {
                       completion(
                            response,
                           response.status ?? "",
                           response.roomId ?? "",
                           response.productSetId ?? 0,
                           response.productSetItemId ?? 0,
                           response.productSetItemUnitId ?? 0,
                           String(response.startingBidAmount ?? 0),
                           response.requireTime ?? 30,
                           response.counterBidTime ?? 0,
                           response.suddenDeath ?? false
                       )
                   }

                   self.logger.info("🎁 auction_started_break_spot received")

               } catch {
                   print("❌ Decoding error:", error)
               }
           }
       }
       
       /// Listens for `bid_timer_update_break_spot` event
       func listenForBidTimerUpdateBreakSpot(
           roomId: String,
           onUpdate: @escaping (_ remaining: Int) -> Void
       ) {
           socket.on("bid_timer_update_break_spot") { [weak self] data, _ in
               guard let self,
                     let json = data.first as? [String: Any],
                     let roomID = json["room_id"] as? String,
                     let remaining = json["remaining"] as? Int,
                     roomID == roomId else { return }
               
               DispatchQueue.main.async {
                   onUpdate(remaining)
               }
               
               self.logger.info("⏱️ bid_timer_update_break_spot: \(remaining)s remaining")
           }
       }
       
       /// Listens for `auction_ended_break_spot` event
       func listenForAuctionEndedBreakSpot(
           completion: @escaping (
               _ roomId: String,
               _ productSetId: Int,
               _ productSetItemId: Int,
               _ productSetItemUnitId: Int,
               _ message: String?
           ) -> Void
       ) {
           socket.on("auction_ended_break_spot") { [weak self] data, _ in
               guard let self else { return }
               
               guard
                   let json = data.first as? [String: Any],
                   let roomId = json["room_id"] as? String
               else {
                   print("❌ Invalid auction_ended_break_spot payload:", data)
                   return
               }
               
               let productSetId = json["productSetId"] as? Int ?? 0
               let productSetItemId = json["productSetItemId"] as? Int ?? 0
               let productSetItemUnitId = json["productSetItemUnitId"] as? Int ?? 0
               let message = json["message"] as? String
               
               DispatchQueue.main.async {
                   completion(roomId, productSetId, productSetItemId, productSetItemUnitId, message)
               }
               
               self.logger.info("🏁 auction_ended_break_spot received for room \(roomId)")
           }
       }
       
       /// Listens for `bid_finalized_break_spot` event
       func listenForBidFinalizedBreakSpot(
           completion: @escaping (
               _ roomId: String,
               _ productSetId: Int,
               _ productSetItemId: Int,
               _ productSetItemUnitId: Int,
               _ winner: HighestBid?
           ) -> Void
       ) {
           socket.on("bid_finalized_break_spot") { [weak self] data, _ in
               guard let self else { return }
               
               guard
                   let json = data.first as? [String: Any],
                   let roomId = json["room_id"] as? String
               else {
                   print("❌ Invalid bid_finalized_break_spot payload:", data)
                   return
               }
               
               let productSetId = json["productSetId"] as? Int ?? 0
               let productSetItemId = json["productSetItemId"] as? Int ?? 0
               let productSetItemUnitId = json["productSetItemUnitId"] as? Int ?? 0
               
               // Parse winner info
               var winner: HighestBid?
               if let winnerJson = json["winner"] as? [String: Any] {
                   do {
                       let decodedWinner = try JSONSerialization.data(withJSONObject: winnerJson)
                       winner = try JSONDecoder().decode(HighestBid.self, from: decodedWinner)
                   } catch {
                       print("❌ Failed to decode break spot winner:", error)
                   }
               }
               
               hasWon = true
               
               DispatchQueue.main.async {
                   completion(roomId, productSetId, productSetItemId, productSetItemUnitId, winner)
               }
               
               self.logger.info("🏆 bid_finalized_break_spot received for room \(roomId), winner: \(winner?.user_name ?? "unknown")")
           }
       }
       
       /// Listens for auction order failures after a winning bid.
    func listenForAuctionOrderFailed(
        completion: @escaping (
            _ roomId: String,
            _ userId: Int,
            _ message: String
        ) -> Void
    ) {
        let handleFailure: ([Any]) -> Void = { [weak self] data in
            guard let self,
                  let json = data.first as? [String: Any],
                  let roomId = json["room_id"] as? String
            else {
                print("❌ Invalid auction order failed payload:", data)
                return
            }

            let rawUserId = json["user_id"]
            let userId = (rawUserId as? Int) ?? Int(rawUserId as? String ?? "") ?? 0
            let message = json["message"] as? String
                ?? "Order failed after winning auction. Please check your payment and shipping details."

            DispatchQueue.main.async {
                completion(roomId, userId, message)
            }

            self.logger.error("❌ [\(roomId)] auction order failed | userId: \(userId)")
        }

        socket.off("auction_order_failed")
        socket.on("auction_order_failed") { data, _ in
            handleFailure(data)
        }

        socket.off("auction_order_failed_break_spot")
        socket.on("auction_order_failed_break_spot") { data, _ in
            handleFailure(data)
        }
    }

        /// Place a bid for break spot auction
        func placeBidBreakSpot(
            roomId: String,
            bidAmount: String,
            userName: String,
            userImage: String,
            userId: String,
            productSetId: Int,
            productSetItemId: Int,
            productSetItemUnitId: Int,
            productSetType: String
        ) {
            performIfConnected {
                let payload: [String: Any] = [
                    "room_id": roomId,
                    "bid_amount": bidAmount,
                    "user_name": userName,
                    "user_image": userImage,
                    "user_id": userId,
                    "product_set_id": productSetId,
                    "product_set_item_id": productSetItemId,
                    "product_set_item_unit_id": productSetItemUnitId,
                    "product_set_type": productSetType
                ]
                
                socket.emit("place_bid_break_spot", payload)
                logger.info("💰 Sent place_bid_break_spot: \(payload)")
            }
        }
        
        /// Listen for highest bid updates in break spot auction
    func listenForHighestBidBreakSpot(
        forRoom roomId: String,
        completion: ((_ highestBid: HighestBid?) -> Void)? = nil
    ) {
        socket.on("get_highest_bid_break_spot") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let incomingRoomId = json["room_id"] as? String else {
                print("❌ Invalid get_highest_bid_break_spot payload:", data)
                return
            }

            // Handle only matching room
            guard incomingRoomId == roomId else { return }

            var highestBid: HighestBid?

            /// 🔴 FIX: backend sends `get_highest_bid`, NOT `highest_bid`
            if let bidJson = json["get_highest_bid"] as? [String: Any] {
                do {
                    let decodedData = try JSONSerialization.data(withJSONObject: bidJson)
                    highestBid = try JSONDecoder().decode(HighestBid.self, from: decodedData)
                } catch {
                    print("❌ Failed to decode get_highest_bid_break_spot:", error)
                }
            }

            DispatchQueue.main.async {
                completion?(highestBid)
                self.logger.info(
                    "✅ [\(incomingRoomId)] Highest Bid: \(highestBid?.user_name ?? "unknown") - \(highestBid?.bid_amount ?? "0")"
                )
            }
        }
    }

        
        /// Remove break spot bid listeners
        func removeBreakSpotBidListeners() {
            socket.off("get_highest_bid_break_spot")
            print("🧹 Removed break spot bid listeners")
        }
    
       
       // MARK: - Remove Break Spot Listeners
       func removeBreakSpotListeners() {
           socket.off("auction_started_break_spot")
           socket.off("bid_timer_update_break_spot")
           socket.off("auction_ended_break_spot")
           socket.off("bid_finalized_break_spot")
           socket.off("auction_order_failed")
           print("🧹 Removed all break spot auction listeners")
       }
}


// MARK: - Poll Events -
extension SocketManagerService {

    func createPoll(poll: PollModel) {
        performIfConnected {

            let payload: [String: Any] = [
                "room_id": poll.roomId,
                "question": poll.question,
                "options": poll.options.map { $0.text },
                "duration": Int(poll.remainingTime) ?? 300
            ]

            socket.emit("create_poll", payload)
            print("📊 Sent create_poll:", payload)
        }
    }
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
    func observePollVoteUpdate(callback: @escaping (PollModel) -> Void) {
        socket.on("poll_vote_update") { data, _ in
            guard let json = data.first as? [String: Any] else {
                print("❌ poll_vote_update: Invalid data")
                return
            }

            print("🔄 poll_vote_update raw:", json)

            do {
                let jsonData = try JSONSerialization.data(withJSONObject: json)
                let poll = try JSONDecoder().decode(PollModel.self, from: jsonData)

                DispatchQueue.main.async {
                    callback(poll)
                }
            } catch {
                print("❌ poll_vote_update decode error:", error)
            }
        }
    }

   
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
    
   
    
    func removePollListeners() {
        socket.off("poll_created")
        socket.off("poll_ended")
        socket.off("poll_vote_update")
        socket.off("poll_countdown")
        socket.off("vote_error")
        
        print("🗑️ Removed all poll listeners")
    }
}


// MARK: - 🎁 Freebie Events
extension SocketManagerService {

    func createFreebie(room_id: String, productId: String, time: Int) {
        performIfConnected {
            let payload: [String: Any] = [
                "room_id": room_id,
                "product_id": productId,
                "time": time
            ]
            
            socket.emit("create-freebie", payload)
            logger.info("🎁 Sent create-freebie: \(payload)")
        }
    }

    func listenForFreebie(
        completion: ((_ freebie: FreebieModel, _ users: [FreebieUser]) -> Void)? = nil
    ) {
        socket.on("get-freebie") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any] else {
                self.logger.warning("⚠️ Invalid get-freebie payload: \(data)")
                return
            }

            do {
                let decodedData = try JSONSerialization.data(withJSONObject: json)
                let payload = try JSONDecoder().decode(FreebieSocketPayload.self, from: decodedData)

                DispatchQueue.main.async {
                    self.currentFreebie = payload.freebie
                    completion?(payload.freebie, payload.users_list ?? [])
                }

                self.logger.info(
                    "🎁 get-freebie received | showId=\(payload.freebie.show_id ?? ""), users=\(payload.users_list?.count ?? 0)"
                )

            } catch {
                self.logger.error("❌ get-freebie decode error: \(error.localizedDescription)")
            }
        }
    }
    
    func listenForUserJoinedShows(
        completion: ((_ freebie: FreebieLiveUser, _ users: [FreebieUser]) -> Void)? = nil
    ) {
        // Basecamp #9940079895 (2026-05-29 RETURN): the viewer-list sheet shows
        // "No viewers" even with buyers in the room. Two root causes fixed here:
        //
        // 1. FreebieUser.id was `Int?` decoded by standard Codable. If the
        //    server emits id as a JSON string ("123") instead of a number, the
        //    whole `[FreebieUser]` decode throws and liveViewers stays []. Fixed
        //    via the custom FreebieUser Codable extension above that handles
        //    both Int and String id values.
        //
        // 2. The payload shape from the server may differ from FreebieLiveUser.
        //    Added a multi-strategy decode: dict→FreebieLiveUser first, then
        //    bare-array fallback, so the list populates regardless of shape.
        //
        // Residual risk: `request_active_show_users` must be handled on the
        // Node server (emit `active_show_users` back to the room). If the
        // server doesn't implement that event, the on-demand refresh when the
        // host opens the sheet won't work; only viewers who join AFTER the
        // listener is registered will appear. Robin to verify server-side.
        socket.on("active_show_users") { [weak self] data, _ in
            guard let self else { return }

            var resolvedUsers: [FreebieUser] = []
            var resolvedPayload = FreebieLiveUser()

            // Strategy 1: dict payload → FreebieLiveUser
            if let json = data.first as? [String: Any],
               let rawData = try? JSONSerialization.data(withJSONObject: json),
               let payload = try? JSONDecoder().decode(FreebieLiveUser.self, from: rawData) {
                resolvedPayload = payload
                resolvedUsers = payload.users ?? []
                self.logger.info("active_show_users dict decode: \(resolvedUsers.count) viewer(s)")
            }
            // Strategy 2: bare array payload
            else if let arr = data.first as? [[String: Any]],
                    let rawData = try? JSONSerialization.data(withJSONObject: arr),
                    let users = try? JSONDecoder().decode([FreebieUser].self, from: rawData) {
                resolvedUsers = users
                self.logger.info("active_show_users array decode: \(resolvedUsers.count) viewer(s)")
            } else {
                self.logger.warning("⚠️ active_show_users: unrecognised payload shape: \(data)")
            }

            DispatchQueue.main.async {
                self.liveViewers = resolvedUsers
                completion?(resolvedPayload, resolvedUsers)
            }
        }
    }


    // MARK: - Kick User (Basecamp #9934003774, 2026-05-27)
    // Emits kick_user — host only. The socket server verifies the caller is
    // the show's owner before persisting + executing the kick.
    func kickUser(roomId: String, targetUserId: Int) {
        performIfConnected {
            let payload: [String: Any] = [
                "room_id": roomId,
                "target_user_id": targetUserId,
            ]
            socket.emit("kick_user", payload)
            logger.info("📤 Emitted kick_user: room=\(roomId) target=\(targetUserId)")
        }
    }

    // Listens for kick confirmation sent back to the host.
    func listenForKickSuccess(completion: @escaping (_ targetUserId: Int) -> Void) {
        socket.on("kick_user_success") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any],
                  let targetId = json["target_user_id"] as? Int else { return }
            DispatchQueue.main.async { completion(targetId) }
            logger.info("✅ kick_user_success: removed \(targetId)")
        }
    }

    // Basecamp #9940079895 round 1 (2026-05-28): listener for the server's
    // kick_user_error response (validation / permission / unknown failure).
    // Host UI uses this to surface an explicit failure toast instead of the
    // earlier behavior where a failed kick produced no UI feedback.
    func listenForKickError(completion: @escaping (_ message: String) -> Void) {
        socket.on("kick_user_error") { [weak self] data, _ in
            guard let self else { return }
            let msg = (data.first as? [String: Any])?["message"] as? String ?? "Could not remove buyer."
            DispatchQueue.main.async { completion(msg) }
            logger.warning("⚠️ kick_user_error: \(msg)")
        }
    }

    // Listens for the kicked_from_show event (sent to the buyer who was kicked).
    func listenForKickedFromShow(completion: @escaping (_ message: String) -> Void) {
        socket.on("kicked_from_show") { [weak self] data, _ in
            guard let self else { return }
            let msg = (data.first as? [String: Any])?["message"] as? String ?? "You have been removed from this show."
            DispatchQueue.main.async { completion(msg) }
            logger.info("⚡ kicked_from_show: \(msg)")
        }
    }

    // Basecamp #9956272376 (2026-06-02): the server rejects a join with
    // `join_room_error` (e.g. code "kicked" when the buyer was removed from the
    // show earlier, or any other join failure). The app previously had NO
    // listener for this event, so a rejected buyer's `room_create_get` never
    // arrived and they sat forever on the black "Loading show…" screen. Listen
    // for it and surface the message + let the caller dismiss the screen.
    func listenForJoinRoomError(completion: @escaping (_ message: String, _ code: String?) -> Void) {
        socket.off("join_room_error")
        socket.on("join_room_error") { [weak self] data, _ in
            guard let self else { return }
            let dict = data.first as? [String: Any]
            let msg = dict?["message"] as? String ?? "This show can’t be opened right now."
            let code = dict?["code"] as? String
            DispatchQueue.main.async { completion(msg, code) }
            logger.info("⛔️ join_room_error: \(msg) [\(code ?? "")]")
        }
    }

    func enterInFreebie(room_id: String, userId: Int) {
        performIfConnected {
            let payload: [String: Any] = [
                "room_id": room_id,
                "user_id": "\(userId)"
            ]
            
            socket.emit("enter-in-freebie", payload)
            logger.info("🙋‍♂️ Sent enter-in-freebie: \(payload)")
        }
    }
    
    func finalizeFreebie(room_id: String) {
        let payload: [String: Any] = [
            "room_id": room_id
        ]

        socket.emit("finalize-freebie", payload)

        logger.info("🎯 finalize-freebie emitted | showId=\(room_id)")
    }
    func removeFreebieuser(room_id: String,user_id:String) {
        let payload: [String: Any] = [
            "room_id": room_id,
            "user_id":user_id
        ]

        socket.emit(" remove-freebie-user", payload)

        logger.info("🎯 remove-freebie emitted | paload=\(payload)")
    }
    func listenForFreebieWinner(
        completion: @escaping (_ winner: FreebieUser) -> Void
    ) {
        socket.on("get-freebie-winner") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any] else {
                self.logger.warning("⚠️ Invalid winner payload: \(data)")
                return
            }

            do {
                let rawData = try JSONSerialization.data(withJSONObject: json)
                let payload = try JSONDecoder().decode(FreebieWinnerPayload.self, from: rawData)

                DispatchQueue.main.async {
                    completion(payload.user ?? FreebieUser())
                }

                self.logger.info(
                    "🏆 Freebie winner | showId=\(payload.show_id ?? "") "
                )

            } catch {
                self.logger.error("❌ Winner decode error: \(error)")
            }
        }
    }

    // Basecamp #9889548312 + #9929848961 (2026-05-26): Android already listens
    // for `freebie-spinning` and shows the buyer wheel during the spin phase.
    // iOS was missing this listener entirely, so buyers never saw the wheel
    // animate — only the static enter card and then the winner. Add a generic
    // listener that hands the raw payload (room_id, show_id, optional
    // winning_position) to the caller so the buyer UI can present the
    // shuffle / wheel animation on the same trigger.
    func listenForFreebieSpinning(
        completion: @escaping (_ roomId: String, _ showId: String, _ winningPosition: Int?) -> Void
    ) {
        socket.on("freebie-spinning") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any] else {
                self.logger.warning("⚠️ Invalid freebie-spinning payload: \(data)")
                return
            }
            let roomId = json["room_id"] as? String ?? ""
            let showId = (json["show_id"] as? String)
                      ?? (json["show_id"].flatMap { "\($0)" })
                      ?? ""
            let winningPos = json["winning_position"] as? Int
            DispatchQueue.main.async {
                completion(roomId, showId, winningPos)
            }
            self.logger.info("🎡 freebie-spinning | roomId=\(roomId) winningPos=\(winningPos.map { "\($0)" } ?? "nil")")
        }
    }
   

}



// MARK: - Tip Events
extension SocketManagerService {

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

    func removeTipListeners() {
        socket.off("tip_setting_updated")
        socket.off("tip_received")
        print("🗑️ Removed all tip listeners")
    }
   
}


// MARK: - Follow Events
extension SocketManagerService {

    func sendFollowUnfollow(followerId: String, followingId: String,showId : String) {
        let payload: [String: Any] = [
            "follower_id": followerId,
            "following_id": followingId,
            "show_id":showId
        ]
        
        performIfConnected {
            socket.emit("follow_unfollow", payload)
            logger.info("📤 Sent follow_unfollow: \(payload)")
        }
    }
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
   
    func removeFollowListener() {
        socket.off("user_follow_status")
        socket.off("follow_unfollow_status")
    }
    
}

// MARK: - Co-host / Multi-device Events
extension SocketManagerService {
    var socketId: String {
        socket?.sid ?? ""
    }

    func requestCoHostSecondary(roomId: String, userId: Int, showId: String) {
        let payload: [String: Any] = [
            "room_id": roomId,
            "user_id": userId,
            "show_id": showId
        ]
        performIfConnected {
            socket.emit("cohost_request_secondary", payload)
            logger.info("📤 cohost_request_secondary: \(payload)")
        }
    }

    func enterCoHostControlOnly(roomId: String, userId: Int, showId: String) {
        let payload: [String: Any] = [
            "room_id": roomId,
            "user_id": userId,
            "show_id": showId
        ]
        performIfConnected {
            socket.emit("cohost_enter_control_only", payload)
            logger.info("📤 cohost_enter_control_only: \(payload)")
        }
    }

    func takeOverCoHostVideo(roomId: String, userId: Int, showId: String) {
        let payload: [String: Any] = [
            "room_id": roomId,
            "user_id": userId,
            "show_id": showId
        ]
        performIfConnected {
            socket.emit("cohost_take_over_video", payload)
            logger.info("📤 cohost_take_over_video: \(payload)")
        }
    }

    func joinAsInvitedCoHost(roomId: String, userId: Int, showId: String, coHostId: Int?) {
        var payload: [String: Any] = [
            "room_id": roomId,
            "user_id": userId,
            "show_id": showId
        ]
        if let coHostId {
            payload["cohost_id"] = coHostId
        }
        performIfConnected {
            socket.emit("cohost_join", payload)
            logger.info("📤 cohost_join: \(payload)")
        }
    }

    // Basecamp #9968303929: added co_host_user_id so the node server can
    // identify which cohost participant to remove when the host revokes one.
    func leaveInvitedCoHost(roomId: String, userId: Int, showId: String, coHostId: Int?, coHostUserId: Int? = nil) {
        var payload: [String: Any] = [
            "room_id": roomId,
            "user_id": userId,
            "show_id": showId
        ]
        if let coHostId {
            payload["cohost_id"] = coHostId
        }
        if let coHostUserId {
            payload["co_host_user_id"] = coHostUserId
        }
        performIfConnected {
            socket.emit("cohost_leave", payload)
            logger.info("📤 cohost_leave: \(payload)")
        }
    }

    func listenForCoHostVideoHolderChanged(_ completion: @escaping (_ roomId: String, _ holderUserId: Int?, _ holderSocketId: String?) -> Void) {
        socket.off("cohost_video_holder_changed")
        socket.on("cohost_video_holder_changed") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any] else {
                logger.warning("⚠️ Invalid cohost_video_holder_changed payload: \(data)")
                return
            }
            let roomId = json["room_id"] as? String ?? ""
            let holderUserId = Self.intValue(json["video_holder_user_id"])
            let holderSocketId = json["video_holder_socket_id"] as? String
            DispatchQueue.main.async {
                completion(roomId, holderUserId, holderSocketId)
            }
        }
    }

    func listenForCoHostControlMode(_ completion: @escaping (_ roomId: String, _ userId: Int?) -> Void) {
        socket.off("cohost_control_mode")
        socket.on("cohost_control_mode") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any] else {
                logger.warning("⚠️ Invalid cohost_control_mode payload: \(data)")
                return
            }
            let roomId = json["room_id"] as? String ?? ""
            let userId = Self.intValue(json["user_id"])
            DispatchQueue.main.async {
                completion(roomId, userId)
            }
        }
    }

    func listenForCoHostError(_ completion: @escaping (_ message: String) -> Void) {
        socket.off("cohost_error")
        socket.on("cohost_error") { [weak self] data, _ in
            guard let self else { return }
            let json = data.first as? [String: Any]
            let message = json?["message"] as? String ?? "Unable to update cohost state."
            DispatchQueue.main.async {
                completion(message)
            }
        }
    }

    func removeCoHostListeners() {
        socket.off("cohost_video_holder_changed")
        socket.off("cohost_control_mode")
        socket.off("cohost_error")
    }

    private static func intValue(_ any: Any?) -> Int? {
        if let value = any as? Int { return value }
        if let value = any as? String { return Int(value) }
        if let value = any as? Double { return Int(value) }
        return nil
    }
}


// MARK: - Cleanup & Reset
extension SocketManagerService {

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
    func reset(with roomId: String) {
        stopLiveScheduler()
        
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

    // MARK: - 🎡 Randomizer template-based socket events (Build 313)

    /// `freebie-spinning` — seller initiated a spin; buyer pre-animates
    func listenForFreebieSpinning(completion: @escaping (_ roomId: String) -> Void) {
        socket.on("freebie-spinning") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any],
                  let rid = json["room_id"] as? String else {
                self.logger.warning("⚠️ Invalid freebie-spinning payload")
                return
            }
            DispatchQueue.main.async { completion(rid) }
            self.logger.info("🎡 freebie-spinning received | roomId=\(rid)")
        }
    }

    /// `get-freebie` with template metadata (slots, template_type, entry_cost)
    func listenForTemplateFreebieData(completion: @escaping (_ payload: RandomizerFreebiePayload) -> Void) {
        socket.on("get-freebie") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any] else { return }
            do {
                let decoded = try JSONSerialization.data(withJSONObject: json)
                let payload = try JSONDecoder().decode(RandomizerFreebiePayload.self, from: decoded)
                // Only forward if template data is present
                guard payload.template_type != nil || payload.slots != nil else { return }
                DispatchQueue.main.async { completion(payload) }
                self.logger.info("🎡 get-freebie (template) received | type=\(payload.template_type ?? "-")")
            } catch {
                self.logger.error("❌ get-freebie template decode error: \(error.localizedDescription)")
            }
        }
    }
}
