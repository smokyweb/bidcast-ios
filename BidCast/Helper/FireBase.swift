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
    private let databaseRef = Database.database().reference()
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
   
}
