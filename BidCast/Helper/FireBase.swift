//
//  FireBase.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/06/25.
//

import Foundation
import FirebaseDatabase
import UIKit
import AVFoundation
import BottomSheet
import SwiftUICore


class FirebaseManager {
    static let shared = FirebaseManager()
    let databaseRef = Database.database().reference()
    private var newSessionHandle: DatabaseHandle?
    private let interval: TimeInterval = 280
    
    @Published var countdown: Int = 30
    
    private var timer: Timer?
    //    var bidTimers: [String: Timer] = [:]
    private var valueHandle: DatabaseHandle?
    var bidTimers: [String: Timer] = [:]
    var remainingSeconds: [String: Int] = [:]
    
    private init() {}
    
    //MARK: Create live session
    func createLiveSession(showId: String,
                           userId: String,
                           product: [ProductData],
                           seller: SellerModel,
                           thumbnail: String,
                           time: String,
                           date : String,
                           completion: ((Bool) -> Void)? = nil) {
        
        let roomId = "live_room_\(userId)_\(showId)"
        //        let timestamp = convertDateAndTimeToTimestamp(date: date, time: time)
        let timestamp = getCurrentTimestamp()
        print("📅 Timestamp: \(timestamp)")
        
        let sessionData: [String: Any] = [
            "highestBid": "",
            "isLive": true,
            "products": product.map { $0.toDictionary() },
            "roomId": roomId,
            "seller": seller.toDictionary(),
            "showDetail": "",
            "showId": showId,
            "thumbnail": thumbnail,
            "time": timestamp,
            "viewerCount": ""
        ]
        
        print(sessionData)
        
        databaseRef.child("live_sessions").child(roomId).setValue(sessionData) { error, _ in
            if let error = error {
                print("❌ Failed to write live session: \(error.localizedDescription)")
                completion?(false)
            } else {
                print("✅ Live session created successfully in Firebase for room: \(roomId)")
                completion?(true)
            }
        }
    }
    
    
    //MARK: Delete node after end of live stream
    func checkAndDeleteLiveSession(roomId: String, completion: ((Bool) -> Void)? = nil) {
        let ref = databaseRef.child("live_sessions").child(roomId)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                // 🔥 Exists → delete
                ref.removeValue { error, _ in
                    if let error = error {
                        print("❌ Failed to delete: \(error.localizedDescription)")
                        completion?(false)
                    } else {
                        print("🗑️ Live session deleted: \(roomId)")
                        completion?(true)
                    }
                }
            } else {
                print("ℹ️ No session exists for room: \(roomId)")
                completion?(false)
            }
        }
    }
    
    //MARK: TimeStamp to string
    func convertDateAndTimeToTimestamp(date: String, time: String) -> Int? {
        let dateTimeString = "\(date) \(time)" // "2025-08-26 16:00:00"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = .current  // or .utc if needed
        
        if let combinedDate = formatter.date(from: dateTimeString) {
            return Int(combinedDate.timeIntervalSince1970)
        } else {
            return nil
        }
    }
    
    //MARK: Current Timestamp
    func getCurrentTimestamp() -> String {
        let now = Date()
        return String(Int(now.timeIntervalSince1970))
    }
    
    //MARK: Live session dATA
    func getLiveSessionData(roomId: String, completion: @escaping (_ data: [String: Any]?) -> Void) {
        let ref = databaseRef.child("live_sessions").child(roomId)
        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let data = snapshot.value as? [String: Any] {
                print("✅ Live session data fetched for room: \(roomId)")
                completion(data)
            } else {
                print("ℹ️ No live session data found for room: \(roomId)")
                completion(nil)
            }
        }
    }
    
    //MARK: All Live sessions
    func fetchAllLiveSessions(completion: @escaping (_ sessions: [String]) -> Void) {
        let ref = databaseRef.child("live_sessions")
        ref.observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [String: Any] else {
                print("ℹ️ No live sessions found in Firebase.")
                completion([])
                return
            }
            
            // ✅ Extract all room IDs
            let roomIds = Array(value.keys)
            print("✅ Firebase room IDs: \(roomIds)")
            completion(roomIds)
        }
    }
    
    //MARK: Live session ended
    func observeLiveSessionRemoval(roomId: String, onRemoved: @escaping () -> Void) {
        let ref = databaseRef.child("live_sessions").child(roomId)
        
        
        ref.observe(.value) { snapshot in
            if !snapshot.exists() {
                print("🔥 Live session no longer exists: \(roomId)")
                onRemoved()
                return
            }
            
            if let value = snapshot.value as? [String: Any],
               let isLive = value["isLive"] as? Bool,
               isLive == false {
                print("🔥 Live session isLive is false: \(roomId)")
                onRemoved()
            }
        }
        
    }
    //MARK: Get New Live stream shows
    func observeNewLiveSessionNodes(onNewSession: @escaping () -> Void) {
        let parentRef = databaseRef.child("live_sessions")
        
        
        parentRef.observe(.childAdded) { snapshot in
            let childKey = snapshot.key
            
            print("🆕 Detected new node: \(childKey) — Checking for full data...")
            
            
            guard let data = snapshot.value as? [String: Any] else {
                print("⚠️ Invalid data in new node: \(childKey)")
                return
            }
            
            guard
                let roomId = data["roomId"] as? String,
                let isLive = data["isLive"] as? Bool,
                let showId = data["showId"] as? String,
                let thumbnail = data["thumbnail"] as? String,
                isLive == true,
                !roomId.isEmpty,
                !showId.isEmpty,
                !thumbnail.isEmpty
            else {
                print("⏳ Incomplete or not live — Ignoring: \(childKey)")
                return
            }
            
            print("✅ Valid new live session detected in node: \(childKey)")
            onNewSession()
        }
    }
    
    
    //MARK: - Bidding
    func updateHighestBid(
        roomId: String,
        bidAmount: String,
        bidderId: String,
        bidderName: String,
        bidderProfileImage: String,
        status: String = "process",
        onSold: @escaping (_ bidData: [String: Any]?) -> Void
    ) {
        let bidData: [String: Any] = [
            "bidAmount": bidAmount,
            "userId": bidderId,
            "userName": bidderName,
            "userImage": bidderProfileImage,
            "productStatus": status
        ]
        
        let bidPath = databaseRef
            .child("live_sessions")
            .child(roomId)
            .child("highestBid")
        
        let timerKey = roomId
        
        // ✅ Save highest bid to Firebase
        bidPath.setValue(bidData) { error, _ in
            if let error = error {
                print("❌ Failed to update highest bid: \(error.localizedDescription)")
            } else {
                print("✅ Highest bid updated")
                
                // ✅ Start timer only if not running
                if self.bidTimers[timerKey] == nil {
                    self.remainingSeconds[timerKey] = 30
                    self.startCountdownTimer(for: roomId, onSold: onSold)
                }
            }
        }
    }
    func startCountdownTimer(for roomId: String, onSold: @escaping (_ bidData: [String: Any]?) -> Void) {
        let timerKey = roomId
        let countdownRef = databaseRef.child("live_sessions").child(roomId).child("bidCountDown")
        
        // Initial countdown
        self.remainingSeconds[timerKey] = 30
        countdownRef.setValue(30)
        
        bidTimers[timerKey] = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            guard let secondsLeft = self.remainingSeconds[timerKey] else { return }
            
            if secondsLeft <= 1 {
                timer.invalidate()
                self.bidTimers.removeValue(forKey: timerKey)
                self.remainingSeconds.removeValue(forKey: timerKey)
                
                countdownRef.removeValue() // Remove countdown from Firebase
                print("⏰ Countdown finished — finalizing bid")
                self.finalizeWinningBid(roomId: roomId, onSold: onSold)
            } else {
                let newSeconds = secondsLeft - 1
                self.remainingSeconds[timerKey] = newSeconds
                countdownRef.setValue(newSeconds) // 🔥 Sync with Firebase
                print("⏱️ \(newSeconds)s left for room \(roomId)")
            }
        }
    }
    
    func finalizeWinningBid(roomId: String, onSold: @escaping (_ bidData: [String: Any]?) -> Void) {
        let winnerRef = databaseRef.child("live_sessions").child(roomId).child("highestBid")
        
        winnerRef.observeSingleEvent(of: .value) { snapshot in
            guard var bidData = snapshot.value as? [String: Any] else {
                onSold(nil)
                return
            }
            
            // 1️⃣ Mark productStatus = sold
            bidData["productStatus"] = "sold"
            winnerRef.setValue(bidData)
            
            // 2️⃣ Remove the first product
            let productRef = self.databaseRef.child("live_sessions").child(roomId).child("product")
            productRef.observeSingleEvent(of: .value) { snapshot in
                var productArray = snapshot.value as? [[String: Any]] ?? []
                
                if !productArray.isEmpty {
                    productArray.removeFirst()
                    productRef.setValue(productArray)
                }
                
                // 3️⃣ Callback with final bid info
                onSold(bidData)
                
                // 4️⃣ Remove the bid
                winnerRef.removeValue()
            }
        }
    }
    
    
    func observeCountdown(for roomId: String, onUpdate: @escaping (Int) -> Void) {
        let countdownRef = databaseRef.child("live_sessions").child(roomId).child("bidCountDown")
        
        countdownRef.observe(.value) { snapshot in
            if let seconds = snapshot.value as? Int {
                print("🟡 Countdown update: \(seconds)s")
                onUpdate(seconds)
            } else {
                print("🟥 Countdown removed or finished")
                onUpdate(0) // timer finished
            }
        }
    }
    
    //
    //    func observeProductChanges(roomId: String, onChange: @escaping ([ProductData]) -> Void) {
    //        databaseRef.child("live_sessions").child(roomId).child("product")
    //            .observe(.value) { snapshot in
    //                guard let value = snapshot.value as? [[String: Any]] else {
    //                    onChange([])
    //                    return
    //                }
    //
    //                let products: [ProductData] = value.compactMap { dict in
    //                    guard let id = dict["id"] as? String,
    //                          let category = dict["category"] as? String,
    //                          let name = dict["name"] as? String,
    //                          let price = dict["price"] as? String,
    //                          let images = dict["images"] as? String,
    //                          let isCurrent = dict["isCurrent"] as? Bool,
    //                          let status = dict["status"] as? String else {
    //                        return nil
    //                    }
    //
    //                    return ProductData(
    //                        category: category,
    //                        id: id,
    //                        image: images,
    //                        name: name,
    //                        price: price,
    //                        status: status,
    //                        isCurrent: isCurrent
    //                    )
    //                }
    //
    //                onChange(products)
    //            }
    //    }
    
    //MARK: -  Viewwer count
    func observeViewerCount(
        roomId: String,
        onChange: @escaping (Int) -> Void
    ) {
        let ref = databaseRef.child("live_sessions").child(roomId).child("viewerCount")
        ref.observe(.value) { snapshot in
            if let countString = snapshot.value as? String, let count = Int(countString) {
                onChange(count)
            } else if let count = snapshot.value as? Int {
                onChange(count)
            } else {
                onChange(0) // Default if missing or malformed
            }
        }
    }
    func removeNewSessionObserver() {
        if let handle = newSessionHandle {
            databaseRef.child("live_sessions").removeObserver(withHandle: handle)
            newSessionHandle = nil
            print("✅ Removed new session observer")
        }
    }
    
    //MARK: -  Chat MSG
    
    func fetchMessageList(forUserId userId: String, completion: @escaping ([ChatMessage]) -> Void) {
        var allMessages: [ChatMessage] = []
        
        let dbRef = Database.database().reference().child("chat_list").child(userId)
        
        dbRef.observeSingleEvent(of: .value) { snapshot in
            for child in snapshot.children {
                guard let userSnap = child as? DataSnapshot,
                      let data = userSnap.value as? [String: Any] else { continue }
                
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let message = try JSONDecoder().decode(ChatMessage.self, from: jsonData)
                    allMessages.append(message)
                } catch {
                    print("Decoding failed:", error)
                }
            }
            
            completion(allMessages.sorted { $0.timestamp > $1.timestamp }) // Latest first
        }
    }
    
    
    func fetchMessages(for roomId: String, completion: @escaping ([ChatMessageModel]) -> Void) {
        let ref = Database.database().reference().child("chats").child(roomId).child("messages")
        
        ref.observe(.value) { snapshot in
            var messages: [ChatMessageModel] = []
            for child in snapshot.children {
                if let childSnap = child as? DataSnapshot,
                   let dict = childSnap.value as? [String: Any] {
                    let msg = ChatMessageModel(id: childSnap.key, from: dict)
                    messages.append(msg)
                }
            }
            messages.sort { $0.timestamp < $1.timestamp }
            completion(messages)
        }
    }
    
    
    //MARK: -  Observing time
    //MARK: prevent show from goest is lIve to false
    func startObservingSessionTimer(roomId: String, onIntervalReached: @escaping () -> Void) {
        let ref = databaseRef.child("live_sessions").child(roomId).child("time")
        
        // Remove previous observer if any
        if let handle = valueHandle {
            ref.removeObserver(withHandle: handle)
        }
        
        self.valueHandle = ref.observe(.value, with: { snapshot in
            guard let timestampString = snapshot.value as? String,
                  let timestamp = TimeInterval(timestampString) else {
                print("⛔️ Invalid or missing timestamp string")
                return
            }
            
            self.timer?.invalidate()
            
            let currentTime = Date().timeIntervalSince1970
            let elapsed = currentTime - timestamp
            let remaining = self.interval - elapsed
            
            print("⏱️ Elapsed: \(elapsed), Remaining: \(remaining)")
            
            if remaining <= 0 {
                print("🚀 Time already passed, firing immediately...")
                self.fireAction(roomId: roomId, onIntervalReached: onIntervalReached)
            } else {
                self.timer = Timer.scheduledTimer(withTimeInterval: remaining, repeats: false) { _ in
                    self.fireAction(roomId: roomId, onIntervalReached: onIntervalReached)
                }
            }
        })
    }
    
    
    
    func fireAction(roomId: String, onIntervalReached: @escaping () -> Void) {
        onIntervalReached()
        
        let newTimestamp =  getCurrentTimestamp()
        let timestampRef = databaseRef.child("live_sessions").child(roomId).child("time")
        print(timestampRef)
        timestampRef.setValue(newTimestamp)
        print("✅ Timestamp updated to: \(newTimestamp)")
    }
    
    func stopObserving() {
        timer?.invalidate()
        timer = nil
        if let handle = valueHandle {
            databaseRef.removeObserver(withHandle: handle)
            print("❌ Firebase observer removed")
            valueHandle = nil
        }
    }
    
    
    enum SetProductError: Error {
        case productNotFound
        case alreadyCurrent
        case firebaseError(String)
    }
    
    func setProductAsCurrent(roomId: String, selectedID: String, completion: @escaping (Result<Void, SetProductError>) -> Void) {
        let ref = Database.database().reference()
        let productsRef = ref.child("live_sessions").child(roomId).child("products")
        
        productsRef.observeSingleEvent(of: .value) { snapshot in
            guard var products = snapshot.value as? [[String: Any]] else {
                completion(.failure(.productNotFound))
                return
            }
            
            var productFound = false
            var isAlreadyCurrent = false
            
            for (index, var product) in products.enumerated() {
                guard let productId = product["id"] as? String else { continue }
                
                if productId == selectedID {
                    productFound = true
                    if product["isCurrent"] as? Bool == true {
                        isAlreadyCurrent = true
                        break
                    }
                }
            }
            
            if !productFound {
                completion(.failure(.productNotFound))
                return
            }
            
            if isAlreadyCurrent {
                completion(.failure(.alreadyCurrent))
                return
            }
            
            // Update isCurrent flags
            for (index, var product) in products.enumerated() {
                if let productId = product["id"] as? String {
                    product["isCurrent"] = (productId == selectedID)
                    products[index] = product
                }
            }
            
            // Save updated list
            productsRef.setValue(products) { error, _ in
                if let error = error {
                    completion(.failure(.firebaseError(error.localizedDescription)))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
