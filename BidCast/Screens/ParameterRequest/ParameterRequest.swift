//
//  ParameterRequest.swift
//  BidCast
//
//  Created by Abdul-JAM-E-157 on 31/08/24.
//

import UIKit


//MARK: - Generic Response Model
struct ResponseModel<T: Codable>: Codable {
    var status, message, error_type: String?
    var data: T?
}

//MARK: - Generic Paginated Response Model
struct ResponseModelPaginate<T: Codable>: Codable {
    var status, message, error_type: String?
    var data: T?
    var total, total_pages,total_records, current_page, per_page: Int?
}


//MARK: - Login
struct SignInRequest:Encodable {
    var email:String
    var password:String
//    var device_token:String
}

//MARK: - SignUpRequest
struct SignUpRequest:Encodable {
    var firstName:String
    var lastName:String
    var email:String
    var password:String
    var passwordConf:String
    var roleID : Int
    /// Optional referral code. iOS Parity P0.5 (2026-04-23): added to
    /// match Android's `CreateAccountFragment`, which accepts a referral
    /// code argument (also pre-filled by /invite/<code> deep links) and
    /// forwards it as `referral_code` multipart.
    var referralCode: String? = nil

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case passwordConf = "password_confirmation"
        case roleID = "role_id"
        case referralCode = "referral_code"
        case email, password
    }
}


//MARK: - ForgetPassword
struct ForgetRequest:Encodable {
    var email:String
}

//MARK: - VerifyPassword
struct VerifyPasswordRequest:Encodable {
    var password:String?
    var new_password:String?

}

//MARK: - VerifyPassword
struct CompanyAdressRequest:Encodable {
    var street_address:String?
    var address_2:String?
    var city:String?
    var state_id:String?
    var zip_code:String?
}

//MARK: - VerifyPassword
struct CompanyInfoRequest:Encodable {
    var company_name:String
    var service_zip_code:String
    var established_date:String
    var certifications:String
    var state_license_info:String
    var liblilty_insurance_info:String
    var bonding_info:String
    var specialties:String
    var phone:Int
}


//MARK: - VerifyOtp
struct VerifyOtpRequest:Encodable {
    var email:String
    var code:Int
}
struct ResetPasswordRequest:Encodable {
    var email:String
    var password:String
    var password_confirmation:String
}

struct DeviceDetailParam: Encodable{
    var device_token,platform,app_version : String
    var lat,long: String
    var timezone : String
}




struct SaveNewFieldGroup:Encodable {
    var fieldGroupName:String
    var UngroupField:String
    var city:String
    var state:String
    var country:String
}

struct AddStorageLocationRequest:Encodable {
    var location_name:String
    var unit_type:String
    var max_capacity:String

}


struct AddBaleStorageRequest:Encodable {
    var hayeType:String
    var cutDate:String
    var baleType:String
    var baleWeight:String
    var baleSize:String
    var toTotalNoOfUnit:String
    var forageAnalysis:String
    var fertilize:String
    var chemicals:String
    var lime:String

}


struct RemovalBaleRequest:Encodable {
    var bale_id:String
    var remove_bale:String
    var notes:String
    var removal_reason:String

}


//MARK: - LogoutDevice

struct LogoutDeviceRequest:Encodable {
    var device_token:String
}


//MARK: - Save Subscription Param
struct SaveSubscriptionParam:Encodable {
    var subscription:String
    var receipt:String
    var platform:String
}

struct SaveSubscriptionParam1:Encodable {
    var subscription:String
    var receipt:String
    var platform:String
    var originalTransactionId: String
}


//MARK: - hay Used Param
struct HayUsedParam:Encodable {
    var type_of_hay:String
    var filter : [String] = []
}


//MARK: - confirm - purchase Param
struct ConfirmPurchase:Encodable {
    var listing_id:String
    var quantity:String
    var location_id:String
}

//MARK: - ImageModel
struct ImageModel :Encodable {
    var url:String
    var keyName:String
    var mimeType:String
}

//MARK: - AlarmRequest
struct AlarmRequest :Encodable {
    var title, time, comment: String
    var days: String?
    var alarm_id: Int?
}

//MARK: - UpdatePasswordRequest.
struct UpdatePasswordRequest : Encodable{
    var current_password : String
    var password : String
    var password_confirmation : String
}

//MARK: LogoutRequest
struct LogoutRequest : Encodable{
    var device_token : String
}

//MARK: changeAlarmRequest
struct changeAlarmRequest : Encodable{
    var alarm_id: Int?
    var status : String?
}

//MARK: deleteAlarmRequest
struct deleteAlarmRequest : Encodable{
    var alarmId: Int
}

//MARK: UploadSongRequest
struct AddMusicRequest : Encodable{
    var category_id: Int?
    var title: String?
    var artist_name: String?
}

//MARK: changeAlarmRequest
struct CurrentWeatherRequest : Encodable{
    var lat: Double?
    var long : Double?
    var current_weather : String?
}



//MARK: SongModel.
struct SongRequest: Encodable {
    var category_id: Int?
}

//MARK: DeleteSongRequest.
struct DeleteSongRequest: Encodable {
    var musicId: Int
}

//MARK: DeleteSongFromCategoryRequest.
struct DeleteSongFromCategoryRequest: Encodable {
    var music_id: Int
}

//MARK: addFinalMusicRequest.
struct addFinalMusicRequest : Encodable{
    var category_id : Int
    var music_id : [Int]
}

//MARK: NewAlarmRequest.
struct NewAlarmRequest : Encodable{
    var alarm_id: Int?
    var title : String?
    var time : String?
    var days : [String]?
    var comment : String?
}

//MARK: SubscriptionsRequest.
struct AddSubscriptionsRequest : Encodable{
    var plan_id : Int?
    var receipt : String?
    var platform : String?
}

//MARK: DeleteProfileRequest.
struct DeleteProfileRequest : Encodable{
    var reason : String?
}

//MARK: EditProfileDetailsRequest.
struct EditProfileDetailsRequest:Encodable {
    var first_name : String?
    var last_name : String?
    var profile_image : String?
}

//MARK: ContactUsRequest.
struct ContactUsRequest : Encodable{
    var email : String?
    var phone : String?
    var message : String?
}
