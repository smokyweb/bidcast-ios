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
    var isDone: Bool? = false

     var isLocked: Bool {
         status?.lowercased() == "locked"
     }
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

struct ProductDataModel: Codable {
    var id: Int?
    var user_id: Int?
    var category_id: Int?
    var title: String?
    var description: String?
    var quantity: Int?
    var variant : String?
    var purchased_quantity: Int?
    var pricing: Double?
    var flash_sale: Bool?
    var accept_offers: Bool?
    var reserve_for_live: Bool?
    var shipping_profile_id: Int?
    var status: String?
    var product_show: String?
    var images: [String]?
    var thumbnail: [String]?
    var created_at: String?
    var category: CategoryDataModel?
}



struct StoreScheduleShowModel : Codable{
   var user_id : Int?
    var title : String?
    var category_id : Int?
    var product_ids : [String]
    var date : String?
    var time : String?
    var auction_type_id : Int?
    var thumbnail : [String]?
    var img_thumbnail : [String]?
    var id : Int?
    var products : [ProductDataModel]?
}
