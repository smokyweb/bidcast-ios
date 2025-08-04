//
//  ContactModel.swift
// BidSwipe
//
//  Created by JAM-E-265 on 25/01/24.
//

import Foundation

struct ContactModel : Codable{
    var status : String?
    var message : String?
    var error_type : String?
    var data : ContactDataModel?
}

struct FAQModel : Codable{
    var status : String?
    var message : String?
    var error_type : String?
    var data : [FAQDataModel]?
}

struct FAQDataModel : Codable{
    var id : Int?
    var question : String?
    var answer : String?
}

struct CategoryModel : Codable{
    var status : String?
    var message : String?
    var error_type : String?
    var data : [CategoryDataModel]?
}

struct CategoryDataModel : Codable{
    var id : Int?
    var name: String?
    var image: String?
    var thumbnail: String?
    var color: String?
    var subLabel : String?
    var extra_fields : [ExtraFieldModel]?
}

struct ExtraFieldModel : Codable{
//    var id = UUID()
    var label : String?
    var type : String?
    var options : [String]?
}
struct AuctionModel : Codable{
    var status : String?
    var message : String?
    var error_type : String?
    var data : [AuctionDataModel]?
}

struct AuctionDataModel : Codable{
    var id : Int?
    var name : String?
}


struct BusinessModel : Codable{
    var status : String?
    var message : String?
    var error_type : String?
    var data : [BusinessGetDataModel]?
}

struct UpdateBusinessModel : Codable{
    var status : String?
    var message : String?
    var error_type : String?
    var data : BusinessDataModel?
}

struct ContactDataModel : Codable{
    var id : Int?
    var question : String?
    var answer : String?
}

struct BusinessDataModel : Codable{
    var id,user_id : Int?
    var business_name,status :  String?
    var ein_number :  String?
    var business_email : String?
    var created_at : String?
    var updated_at :  String?
    
}

struct BusinessGetDataModel : Codable{
    var id : Int?
    var business_name,status :  String?
    var ein_number,user_id :  String?
    var business_email : String?
    var created_at : String?
    var updated_at :  String?
    
}
