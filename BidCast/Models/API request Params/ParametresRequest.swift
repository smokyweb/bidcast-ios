//
//  ParametresRequest.swift
// BidSwipe
//
//  Created by Abdul-JAM-E-157 on 18/01/24.
//

import Foundation

// MARK: - Education
struct Education: Codable {
    var education_name, education_date: String
}

// MARK: - Image
struct Imagee: Codable {
    var image: String
}

// MARK: - InterestedJob
struct InterestedJob: Codable {
    var job_id: String
}

// MARK: - Language
struct Languages: Codable {
    var name: String
}

// MARK: - LicenseCertification
struct LicenseCertification: Codable {
    var license_certificate: String
}

// MARK: - Skill
struct Skill: Codable {
    var skill: String
}

// MARK: - VolunteerExperience
struct VolunteerExperience: Codable {
    var volunteer_experience: String
}

// MARK: - WorkHistory
struct WorkHistory: Codable {
    var id: Int?
    var job_title, company_name, location: String?
    var employment_type, location_type: String?
    var start_date, end_date: String?
    var profile_headline, description, industry: String?
    var contact_info: String?
    var created_at, updated_at: String?
}

    // MARK: - WorkHistory
struct CreateWorkHistory: Codable {
    var id: Int?
    var job_title, company_name, location: String?
    var employment_type, location_type: String?
    var start_date, end_date: String?
    var profile_headline, description, industry: String?
    var contact_info: String?
    var created_at, updated_at: String?
}

//MARK: - CreateProfileSection1
struct CreateUserProfSection: Codable {
    var is_student, most_recent_job_title, most_recent_company, your_dream_job, job_category_id: String?
    var profile_image: String?
}




//MARK: - Generic Response Modal
struct ResponseModal<T: Codable>: Codable {
    var status, message, error_type: String?
    var data: T
}

//MARK: - Job Paramters
struct GetJobParameter: Codable {
    var currentPage: Int
    var type, search: String
}

struct CreateEventModel: Codable{
    var status,message,error_type : String?
    var data: DataModel?
}

struct DataModel: Codable {
    var access_token: String?
    var expires_in: Int?
    var refresh_token: String?
    var scope: String?
    var token_type: String?
}

//MARK: - Create Update Job Parameter
struct JobUpsertParamter: Codable {
    var id: Int?
    var title: String
    var salary_type, salary: String
    var hours_schedule: String
    var type, description: String
    var benefits: String
    var experience, licensure: String
    var qualification_id, education_field: String
    var is_licensure_required,is_education_required:String
    var location_type_id: String
}

//MARK: - Swipe Job Parameter
struct JobSwipePatamter: Encodable {
    var job_id: Int
    var type: String
}
    
// MARK: - ContactUs
struct ContactModelParam: Encodable{
    var email : String
    var phone : String
    var message : String
    var image : String?
}

struct BusinessModelParam: Encodable{
    var ein_number : String
    var business_email : String
    var id,business_name : String
    var file : String?
}

//MARK: - Create Work History Request
struct CreateWorkHistoryRequest: Codable {
    var current_job, job_title, contact, previous_work: String
}

struct UserPersonalInfo: Codable {
    var first_name, last_name, email, location, password: String
    var phone, description, profile_image: String
}


struct SubCompanyParam: Codable {
    var first_name, last_name, email, user_name,phone: String
    var image: String
    var data : [AssignData]?
}


struct SubCompanyUserParam: Codable {
    var first_name, last_name,phone: String
    var image: String
}

struct SubCompanyParamUpdate: Codable {
    var first_name, last_name, email, user_id,phone: String
    var image: String
    var data : [AssignData]?
}

struct getSubCompanyParam: Codable {
    var user_id: String?
}
struct AssignData: Codable {
    var permission, read,write,delete: String
}

//MARK: - Search Job/Employee Request
struct SearchRequest: Encodable {
    var search, type: String
    var page: Int
}

struct SearchRequestByJobId: Encodable {
    var search, type: String
//    var page: Int
    var job_id :Int
}

    //MARK: - Generic Paginated Response Modal
//struct ResponseModalPaginate<T: Codable>: Codable {
//    var status, message, error_type: String?
//    var data: T
//    var total, totalPage, currentPage, perPage: Int?
//}

struct ResponseModalPaginate<T: Codable>: Codable {
    var status: String?
    var message: String?
    var error_type: String?
    var data: T
    var total: Int?
    var totalPage: Int?
    var currentPage: Int?
    var perPage: Int?

    enum CodingKeys: String, CodingKey {
        case status
        case message
        case error_type
        case data
        case total
        case totalPage
        case currentPage
        case perPage
    }
}


//MARK: - Employee By Job ID
struct EmployeeJobIdRequest: Encodable {
    var job_id, status,page: Int
}

struct EmployeeEducationRequest: Encodable {
    var qualification_id: Int
    var institute_name: String
    var graduation_date: String
}

struct EmpLanguageRequest: Encodable {
    var language_id: String
}

struct PerformJobActionRequest: Codable {
    var status:String
    var  job_id, user_id: Int
   
}

struct EmployerAvailabilityRequest: Codable {
    var day_name: [String]
    var duration, end_time, start_time: String
}

struct SaveJobRequest: Encodable {
    var job_id: Int
}

struct ScheduleInterviewRequest: Codable {
    var matched_id, scheduledDate, scheduledTime, timezone, scheduledEndTime: String
}

struct EmployerScheduleRequest: Codable{
    var date:String
    var employer_id: String
}

//MARK: - Save Device Detail
struct DeviceDetailModal: Encodable {
    var device_token, device_platform, device_version: String
}

//MARK: - Read Notification
struct ReadNotification: Encodable {
    var id: [String]
}

//MARK: - Interview Status Model
struct InterviewRescheduleStatusModel: Encodable {
    var status: String
    var employer_id, job_id: Int
}


//MARK: For BidCast

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
//  var device_token:String
}

//MARK: - SignUpRequest
struct SignUpRequest:Encodable {
    var firstName:String
    var lastName:String
    var email:String
    var password:String
    var passwordConf:String
    var roleID : Int
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case passwordConf = "password_confirmation"
        case roleID = "role_id"
        case email, password
    }
}

//MARK: - Contact US
struct ContactUsRequest:Encodable {
    var name:String
    var email:String
    var subject:String
    var message:String
    
    enum CodingKeys: String, CodingKey {
        case name
        case email
        case subject
        case message
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

//MARK: InventoryRequest
struct InventoryRequest : Encodable{
    var status : String
}

//MARK: Store Product param

struct StoreProductParam : Encodable{
    var category_id : String
    var title: String
    var description  :String
    var quantity : String
    var pricing : String
    var flash_sale : String
    var accept_offers : String
    var reserve_for_live : String
    var shipping_profile_id : String
    var status : String
}

struct TipParam : Encodable {
    var type : String
}

struct AddressRequest : Encodable {
    var type : String
    var name : String
    var phone_number,street_address,pincode : String
}

struct AddressDefaultParam : Encodable {
    var address_id : String
}


struct UpdatePreferenceRequest: Encodable{
    var country_of_residence: String
    var direct_message: Int
    var receive_gifts: Int
    var enable_private_entry: Int
    var show_reward_status: Int
    var show_seller_tools: Int
    var enable_clips: Int
    var save_past_shows: Int
    var activity_status: Int
    var sync_phone_contacts: Int
    var suggest_my_account: Int
    var haptic_feedback: Int
}


struct UserProductRequest: Encodable{
    var user_id : Int
}

struct NotifyLiveUserRequest: Encodable{
    var live_user_id : Int
}


struct ProfileParamRequest : Encodable{
    var id : String
}

struct FollowRequest : Encodable {
    var following_id : String
}

struct FetchProductRequest : Encodable {
    var product_id : Int
}
struct AddCardRequest : Encodable{
    var card_token :String
}

struct DeleteCardRequest : Encodable{
    var card_id :String
}


struct StoreIDCardRequest : Encodable{
    var id_card :String
    var image : String
}

struct StorePhoneNumberRequest : Encodable{
    var phone_number : Int
}

struct OtpVerifyRequest : Encodable{
    var otp : Int
}

struct StorePaymentMethodRequest : Encodable{
    var card_token : String
}

struct BuyerIdentityStoreRequest : Encodable{
    var image : String
}


struct DeleteNotificationRequest : Encodable{
    var id : Int
}

struct GetMyScheduleShowRequest : Encodable{
    var type : String
}

struct ProductOrderListingRequest : Encodable{
    var type : String
}

struct ProductPurchaseDetailRequest : Encodable{
    var shipping_id : Int
    var product_id : Int
}

struct ProductOrderRequest : Encodable{
    var shipping_id: Int
    var product_id: Int
    var card_id: String
    var promo_code: String
    var send_as_gift: Int
    var gift_user_id: Int
    var gift_msg: String
    var shipping_charges: Int
    var tax_amount: Int
    var sub_total: Int
    var total: Int
    var discount: Int?
}

struct ProductOrderDetailRequest : Encodable{
    var order_id : Int
}

struct MakeOfferRequest : Encodable{
    var amount : String
    var product_id : Int
}

struct MakeOfferListRequest : Encodable{
    var product_id : Int?
}

struct OfferUpdateStatusRequest : Encodable{
    var offer_id : Int
    var status : String
}

struct TransactionHistoryListingRequest : Encodable{
    var id : Int
}

struct SearchingRequest : Encodable{
    var search : String
}

struct PromoCodeRequest : Encodable{
    var promo_code : String
}

struct OrderRecieptRequest : Encodable{
    var order_id : String
}


//MARK: extension
struct TransactionRequest : Encodable {
    var id : String? = ""
}
