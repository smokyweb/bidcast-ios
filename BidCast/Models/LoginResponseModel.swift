//
//  LoginResponseModel.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 18/01/24.
//

import Foundation


struct LoginResponce: Codable{
    var status: String = ""
    var message: String = ""
    var error_type: String = ""
    var data: SignInData?

}

struct SignInData:Codable{
    var id: Int?
    var name: String?
    var first_name: String?
    var last_name: String?
    var role_id: String?
    var location: String?
    var profile_image: String?
    var video_resume: String?
    var email: String?
    var created_at: String?
    var token: String?
    var user_role: String?
}
