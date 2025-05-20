//
//  UserProfileUpdateResponseModal.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 30/01/24.
//

import Foundation

//MARK: - Skill Response Modal
struct UserSkillResponseModal: Codable {
    var skill, update_at, created_at: String?
    var user_id, id: Int?
}
