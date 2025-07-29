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

   
    private init() {}

    func createLiveSession(showId: String,
                           userId: String,
                           product: ProductData,
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
            "live": true,
            "product": product.toDictionary(),
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
    
//    func getCurrentTimeFormatted() -> String {
//        let formatter = DateFormatter()
//        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.dateFormat = "yyyy-MM-dd_hh:mm:ss_a" 
//        formatter.amSymbol = "am"
//        formatter.pmSymbol = "pm"
//        return formatter.string(from: Date())
//    }
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
    func getCurrentTimestamp() -> Int {
        let now = Date()
        return Int(now.timeIntervalSince1970)
    }
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
    
    func observeLiveSessionRemoval(roomId: String, onRemoved: @escaping () -> Void) {
        let ref = databaseRef.child("live_sessions").child(roomId)
        ref.observe(.childRemoved) { snapshot in
            
           
            print("🔥 Live session node removed: \(snapshot)")
           
            onRemoved()
        }
        
        ref.observe(.value) { snapshot in
            if !snapshot.exists() {
                print("🔥 Live session no longer exists: \(roomId)")
                onRemoved()
            }
        }
    }
    
    func observeNewLiveSessionNodes(onNewSession: @escaping () -> Void) {
        let parentRef = databaseRef.child("live_sessions")

        // Listen for any new node added under live_sessions
        parentRef.observe(.childAdded) { snapshot in
            let childKey = snapshot.key
            let childRef = parentRef.child(childKey)

            print("🆕 Detected new node: \(childKey) — Waiting for full data...")

            // Observe data changes under the new node
            childRef.observe(.value) { snapshot in
                guard let data = snapshot.value as? [String: Any] else {
                    print("⚠️ Invalid data inside node: \(childKey)")
                    onNewSession()
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
                    print("⏳ Data still incomplete or not live in: \(childKey)")
                    return
                }

                print("✅ Full valid live session ready in node: \(childKey)")
                onNewSession()
            }
        }
    }

    
    func updateProductPrice(roomId: String, newPrice: String) {
        databaseRef.child("live_sessions").child(roomId).child("product").child("price").setValue(newPrice)
    }
    
    func observeProductChanges(
         roomId: String,
         onChange: @escaping (ProductData?) -> Void
     ) {
         databaseRef
             .child("live_sessions")
             .child(roomId)
             .child("product")
             .observe(.value) { snapshot in

                 guard let data = snapshot.value else {
                     onChange(nil)
                     return
                 }

                 if let jsonData = try? JSONSerialization.data(withJSONObject: data) {
                     do {
                         let model = try JSONDecoder().decode(ProductData.self, from: jsonData)
                         onChange(model)
                     } catch {
                         print("❌ Decoding Product Error: \(error)")
                         onChange(nil)
                     }
                 } else {
                     onChange(nil)
                 }
             }
     }
    
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
    

    func fetchMessages(forUserId userId: String, completion: @escaping ([ChatMessage]) -> Void) {
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
}
