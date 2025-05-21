//
//  ScheduleModel.swift
//  BidCast
//
//  Created by Ankit-JAM-E-294 on 17/05/25.
//

import Foundation

struct LessonModel : Codable {
    var id: Int?
    var title : String?
    var video : String?
    var description : String?
    var status : String?
    var image : String?
    var isLocked: Bool { status?.lowercased() != "unlocked" }
}


struct TitleTipsModel : Codable {
    var tips: [TipsData]?
    var example : [String]?
    
}

struct TipsData : Codable {
    var icon: String?
    var title: String?
    var description: String?
}
