//
//  JobActionResponse.swift
// BidSwipe
//
//  Created by Maneet-JAM-E-282 on 09/02/24.
//

import Foundation

struct JobActionResponse: Codable {
    var id, status: Int?
    var user_id, job_id, isScheduled, scheduledDate, scheduledTime: String?
}

struct CompanyResponse: Codable {
    var id: Int?
    var user_id, sub_user_id, permission, read_access,write_access,delete_access,created_at,updated_at: String?
}


struct CompanyUserResponse: Codable {
    var id: Int?
    var first_name, last_name, user_name, email,profile_image,phone,roles: String?
    var permission: [PermissionData]?
}

struct PermissionData: Codable {
    var id: Int?
    var user_id, sub_user_id, permission, read_access,write_access,delete_access,created_at,updated_at: String?
}



struct EmployerSaveResponse: Codable {
    var id, match_id: Int?
//    var user_id, job_id, status, is_employee_saved: String?
}

struct EmployerAvailability: Codable{
    var status,message,error_type: String?
}


struct GetAvailability:Codable{
    var status,message:String?
    var data: EmployerData?
}

struct EmployerData:Codable{
    var start_time,end_time,duration: String?
    var isCalSync: Bool?
    var day_name: [String]?
}

struct EmployerScheduleInterView: Codable{
    var status, message: String?
    var data: [InterViewTime]?
}

struct InterViewTime: Codable{
    var start_time, end_time: String?
}
