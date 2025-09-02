//
//  ABoutUsModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 16/05/25.
//

import Foundation


// MARK: - About Us Data
struct AboutUsModel: Codable {
    var company_name: String?
    var platform_name: String?
    var contact_email: String?
    var contact_phone: String?
    var logo: String?
    var mission: String?
    var features: [Feature]?
    var impact: [Impact]?
    var team: [TeamMember]?
    var social_media: [SocialMedia]?
    
   
}

// MARK: - Feature
struct Feature: Codable {
    var title: String?
    var description: String?
    var icon: String?
}


// MARK: - Impact
struct Impact: Codable {
    var label: String?
    var value: String?
}

// MARK: - Team Member
struct TeamMember: Codable {
    var name: String?
    var role: String?
    var image: String?
}

// MARK: - Social Media
struct SocialMedia: Codable {
    var platform: Int?
    var url: PlatformURL?
}

// MARK: - Platform URL
struct PlatformURL: Codable {
    var platform: String
    var url: String
}
