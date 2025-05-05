//
//  ContactModel.swift
//  imperium
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
    var email :  String?
    var phone :  String?
    var message :  String?
    var image : String?
    var user_id : Int?
    var updated_at :  String?
    var created_at :  String?
    var id : Int?
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
