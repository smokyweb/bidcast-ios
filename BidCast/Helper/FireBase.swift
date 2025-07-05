//
//  FireBase.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/06/25.
//

import Foundation
import FirebaseDatabase



class FirebaseManager {
    static let shared = FirebaseManager()
    let databaseRef = Database.database().reference()
    private init() {}

    func createLiveSession(showId: String,
                           userId: String,
                           product: ProductData,
                           seller: SellerModel,
                           thumbnail: String,
                           time: String,
                           completion: ((Bool) -> Void)? = nil) {
        
        let roomId = "live_room_\(userId)_\(showId)"
        let currentTime = getCurrentTimeFormatted()
        let sessionData: [String: Any] = [
            "highestBid": "",
            "live": true,
            "product": product.toDictionary(),
            "roomId": roomId,
            "seller": seller.toDictionary(),
            "showDetail": "",
            "showId": showId,
            "thumbnail": thumbnail,
            "time": currentTime,
            "viewerCount": ""
        ]

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
    
    func getCurrentTimeFormatted() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_hh:mm:ss_a" 
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: Date())
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
        
        // Also observe if the whole node disappears
        ref.observe(.value) { snapshot in
            if !snapshot.exists() {
                print("🔥 Live session no longer exists: \(roomId)")
                onRemoved()
            }
        }
    }
    
    func observeNewLiveSessionNodes(onNewSession: @escaping () -> Void) {
        let ref = databaseRef.child("live_sessions")
        
        // Listen for new child nodes (new sessions)
        ref.observe(.childAdded) { snapshot in
            print("🆕 New live session added: \(snapshot.key)")
            onNewSession()
        }
    }
}
