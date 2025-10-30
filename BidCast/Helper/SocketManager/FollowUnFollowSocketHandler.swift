//
//  FollowUnFollowSocketHandler.swift
//  BidCast
//
//  Created by JamTech on 29/10/25.
//

import Foundation

@MainActor
final class FollowSocketHandler: ObservableObject {
    
    private let base = BaseSocketManager.shared
    
    /// Published follow status for UI binding
    @Published var isFollowed: Bool = false
    @Published var lastActionSuccess: Bool = false
    
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
        
        base.performIfConnected {
            base.socket.emit("follow_unfollow", payload)
            base.logger.info("📤 Sent follow_unfollow: \(payload)")
        }
    }
    
    // MARK: - Listen for follow_unfollow_status
    /// Listens for the follow_unfollow_status event from the server.
    /// Server should respond with something like:
    /// `{ "success": true, "message": "Followed" }`
    func listenForFollowUnfollowStatus() {
        base.socket.on("follow_unfollow_status") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any] else {
                base.logger.warning("⚠️ Invalid follow_unfollow_status payload: \(data)")
                return
            }
            
            let success = json["success"] as? Bool ?? false
            let message = json["message"] as? String ?? ""
            
            DispatchQueue.main.async {
                self.lastActionSuccess = success
            }
            
            base.logger.info("✅ follow_unfollow_status received: success=\(success), message=\(message)")
        }
    }
    
    // MARK: - Listen for user_follow_status
    /// Called when a user joins a room, to check if they follow the seller.
    /// Example server response:
    /// `{ "user_id": "abc123", "seller_id": "xyz789", "is_followed": true }`
    func listenForUserFollowStatus() {
        base.socket.on("user_follow_status") { [weak self] data, _ in
            guard let self else { return }
            guard let json = data.first as? [String: Any],
                  let isFollowed = json["is_followed"] as? Bool else {
                base.logger.warning("⚠️ Invalid user_follow_status payload: \(data)")
                return
            }
            
            DispatchQueue.main.async {
                self.isFollowed = isFollowed
            }
            
            base.logger.info("👤 user_follow_status received: is_followed=\(isFollowed)")
        }
    }
    
    // MARK: - Stop Listening (Cleanup)
    /// Removes all event listeners related to follow/unfollow actions.
    func removeFollowListeners() {
        base.socket.off("follow_unfollow")
        base.socket.off("follow_unfollow_status")
        base.socket.off("user_follow_status")
        base.logger.info("🧹 Removed follow/unfollow socket listeners")
    }
}
