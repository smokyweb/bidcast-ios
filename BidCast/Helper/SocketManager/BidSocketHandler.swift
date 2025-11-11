//  ChatSocketHandler.swift
//  BidCast
//
//  Created by Vivek_JAM_E-328 on 29/10/25.
//
import Foundation

@MainActor
final class BidSocketHandler: ObservableObject {
    @Published var rooms: [RoomModel] = []
    private let base = BaseSocketManager.shared

    func listenForBidFinalized(completion: @escaping (_ roomId: String, _ winner: HighestBid?) -> Void) {
        base.socket.on("bid_finalized") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let roomId = json["room_id"] as? String else { return }

            var winner: HighestBid?
            if let wJson = json["winner"] as? [String: Any] {
                do {
                    let data = try JSONSerialization.data(withJSONObject: wJson)
                    winner = try JSONDecoder().decode(HighestBid.self, from: data)
                } catch {
                    print("❌ Winner decode failed:", error)
                }
            }

            DispatchQueue.main.async {
                completion(roomId, winner)
            }
        }
    }

    func observeBidCountdown(for roomId: String,
                             onUpdate: @escaping (Int) -> Void,
                             onStart: @escaping () -> Void,
                             onComplete: @escaping () -> Void) {
        base.socket.on("bid_timer_update") { [weak self] data, _ in
            guard let self,
                  let json = data.first as? [String: Any],
                  let id = json["room_id"] as? String,
                  id == roomId,
                  let remaining = json["remaining"] as? Int else { return }

            DispatchQueue.main.async {
                onUpdate(remaining)
                if remaining == 30 { onStart() }
                if remaining == 0 { onComplete() }
            }
        }
    }

    func listenForNextProduct(completion: @escaping (_ roomId: String, _ nextProductId: String) -> Void) {
        base.socket.on("next_product_set") { data, _ in
            guard let json = data.first as? [String: Any],
                  let roomId = json["room_id"] as? String,
                  let products = json["products"] as? [[String: Any]] else { return }

            if let nextProduct = products.first(where: { $0["isCurrent"] as? Bool == true }),
               let nextId = nextProduct["id"] as? String {
                completion(roomId, nextId)
            }
        }
    }

    func listenForHighestBid(forRoom roomId: String,
                             completion: @escaping (HighestBid?) -> Void) {
        base.socket.on("get_highest_bid") { data, _ in
            guard let json = data.first as? [String: Any],
                  let incomingRoomId = json["room_id"] as? String,
                  incomingRoomId == roomId else { return }

            if let bidJson = json["get_highest_bid"] as? [String: Any] {
                do {
                    let decoded = try JSONSerialization.data(withJSONObject: bidJson)
                    let bid = try JSONDecoder().decode(HighestBid.self, from: decoded)
                    completion(bid)
                } catch {
                    print("❌ Highest bid decode error:", error)
                    completion(nil)
                }
            }
        }
    }
    
    func sendBid(payload: [String: Any]) {
        base.performIfConnected {
            base.socket.emit("place_bid", payload)
            base.logger.info("📡 Sending bid: \(payload)")
        }
    }
    
    func AllowBidForAll(roomId: String, allow_bid_for_all: Bool) {
        base.performIfConnected {
            let payload: [String: Any] = [
                "room_id": roomId,
                "allow_bid_for_all": allow_bid_for_all
            ]
            base.socket.emit("allow_bid_for_all", payload)
            base.logger.info("📦 Emitted next product for room \(roomId): allow_bid_for_all=\(allow_bid_for_all)")
        }
    }
    
    func getAllowBidForAll(forRoom roomId: String,
                           completion: ((_ isAllowed: Bool) -> Void)? = nil) {
        
        base.socket.on("allow_bid_for_all_get") { [weak self] data, _ in
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
}

