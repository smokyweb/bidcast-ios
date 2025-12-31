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

//MARK: - CreateEventModel
struct CreateEventModel: Codable{
    var status,message,error_type : String?
    var data: DataModel?
}

//MARK: - DataModel
struct DataModel: Codable {
    var access_token: String?
    var expires_in: Int?
    var refresh_token: String?
    var scope: String?
    var token_type: String?
}

//MARK: - JobUpsertParamter
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

//MARK: - JobSwipePatamter
struct JobSwipePatamter: Encodable {
    var job_id: Int
    var type: String
}
    
// MARK: - ContactModelParam
struct ContactModelParam: Encodable{
    var email : String
    var phone : String
    var message : String
    var image : String?
}

// MARK: - BusinessModelParam
struct BusinessModelParam: Encodable{
    var ein_number : String
    var business_email : String
    var id,business_name : String
    var file : String?
}

//MARK: - CreateWorkHistoryRequest
struct CreateWorkHistoryRequest: Codable {
    var current_job, job_title, contact, previous_work: String
}

//MARK: - UserPersonalInfo
struct UserPersonalInfo: Codable {
    var first_name, last_name, email, location, password: String
    var phone, description, profile_image: String
}

//MARK: - SubCompanyParam
struct SubCompanyParam: Codable {
    var first_name, last_name, email, user_name,phone: String
    var image: String
    var data : [AssignData]?
}

//MARK: - SubCompanyUserParam
struct SubCompanyUserParam: Codable {
    var first_name, last_name,phone: String
    var image: String
}

//MARK: - SubCompanyParamUpdate
struct SubCompanyParamUpdate: Codable {
    var first_name, last_name, email, user_id,phone: String
    var image: String
    var data : [AssignData]?
}

//MARK: - getSubCompanyParam
struct getSubCompanyParam: Codable {
    var user_id: String?
}

//MARK: - AssignData
struct AssignData: Codable {
    var permission, read,write,delete: String
}

//MARK: - SearchRequest
struct SearchRequest: Encodable {
    var search, type: String
    var page: Int
}

//MARK: - SearchRequestByJobId
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

//MARK: - ResponseModalPaginate
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


//MARK: - EmployeeJobIdRequest
struct EmployeeJobIdRequest: Encodable {
    var job_id, status,page: Int
}

//MARK: - EmployeeEducationRequest
struct EmployeeEducationRequest: Encodable {
    var qualification_id: Int
    var institute_name: String
    var graduation_date: String
}

//MARK: - EmpLanguageRequest
struct EmpLanguageRequest: Encodable {
    var language_id: String
}

//MARK: - PerformJobActionRequest
struct PerformJobActionRequest: Codable {
    var status:String
    var  job_id, user_id: Int
   
}

//MARK: - EmployerAvailabilityRequest
struct EmployerAvailabilityRequest: Codable {
    var day_name: [String]
    var duration, end_time, start_time: String
}

//MARK: - SaveJobRequest
struct SaveJobRequest: Encodable {
    var job_id: Int
}

//MARK: - ScheduleInterviewRequest
struct ScheduleInterviewRequest: Codable {
    var matched_id, scheduledDate, scheduledTime, timezone, scheduledEndTime: String
}

//MARK: - EmployerScheduleRequest
struct EmployerScheduleRequest: Codable{
    var date:String
    var employer_id: String
}

//MARK: - ReadNotification
struct ReadNotification: Encodable {
    var id: [String]
}

//MARK: - InterviewRescheduleStatusModel
struct InterviewRescheduleStatusModel: Encodable {
    var status: String
    var employer_id, job_id: Int
}


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

//MARK: - ResponseModelOffer
struct ResponseModelOffer<T: Codable>: Codable {
    var status, message, error_type: String?
    var data: T?
    var total,totalPage,currentPage, perPage,pending,accepted,declined: Int?
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
    var referralCode : String
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case passwordConf = "password_confirmation"
        case roleID = "role_id"
        case referralCode = "referral_code"
        case email, password
    }
}

//MARK: - DeviceDetail
struct DeviceDetailRequest : Encodable{
    var device_token : String
    var platform : String
    var app_version : String
    var time_zone : String
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
struct UpdateProductStatusRequest : Encodable{
    var status : String
    var product_id: String
}
struct promoteToolRequest : Encodable{
    var filter : String
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
    var sub_category_id : String?
    var width : String
    var length : String
    var weight : String
    var height : String
    var mail_class : String
    var processing_category : String
    var product_condition: String
}

struct TipParam : Encodable {
    var type : String
}

struct AddressRequest : Encodable {
    var type : String
    var name : String
    var phone_number,street_address,pincode,city,state : String
}

struct checkScheduleRequest : Encodable{
    var show_id : String?
    var date : String
    var time : String
}

struct AddressDefaultParam : Encodable {
    var address_id : String
}

struct PurchaseOrderRequuest : Encodable {
    var type : String?
    var status: String?
}

struct UpdatePreferenceRequest: Encodable{
    var country_of_residence: String?
    var direct_message: Int?
    var receive_gifts: Int?
    var enable_private_entry: Int?
    var show_reward_status: Int?
    var show_seller_tools: Int?
    var enable_clips: Int?
    var save_past_shows: Int?
    var activity_status: Int?
    var sync_phone_contacts: Int?
    var suggest_my_account: Int?
    var haptic_feedback: Int?
    var free_shipping: Bool?
}


struct UserProductRequest: Encodable{
    var user_id : String
    var category_id : String? = ""
    var page : Int
    var type: String? //live,flash_sale,reserve_for_live
    var sale_type: String? //auction,accept_offers
    var sort_by: String? //title_asc,title_desc,newest,oldest,price_low_high,price_high_low
    var search: String?
}

struct NotifyLiveUserRequest: Encodable{
    var live_user_id : Int
}


struct ProfileParamRequest : Encodable{
    var id : String
}

struct FollowRequest : Encodable {
    var following_id : String
    var show_id : String
}

struct SellerInfoRequest: Encodable {
    let seller_id: String
}

struct SellerReportRequest: Encodable {
    let seller_id: Int
    let category_id: Int
    let notes: String
}

struct FetchProductRequest : Encodable {
    var product_id : Int
}
struct AddCardRequest : Encodable{
    var card_token: String
}

struct UpdateCardRequest : Encodable{
    var card_id: String
    var name: String
    var exp_month: String
    var exp_year: String
}

struct DeleteCardRequest : Encodable{
    var card_id :String
}


struct StoreIDCardRequest : Encodable{
    var id_card :String
    var image : String
}

struct StorePhoneNumberRequest : Encodable{
    var phone_number : String
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
    var id : Int?
}

struct GetMyScheduleShowRequest : Encodable{
    var type : String?
//    var user_id : Int?
    var page : Int
}

struct GetTotalRatingRequest : Encodable{
    var seller_id : Int
}

struct AddRatingRequest : Encodable{
    var seller_id : Int
    var overall_rating : Double
    var shipping_rating : Double
    var packaging_rating : Double
    var accuracy_rating : Double
    var comment : String
}


struct ProductOrderListingRequest : Encodable{
    var type : String
    var page : Int
    var search: String?
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
    var gift_user_id: Int?
    var gift_msg: String?
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
    var page : Int
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

struct PurchaseOrderDetailsRequest : Encodable{
    var order_id : String
    var product_id: String
}


//MARK: extension
struct TransactionRequest : Encodable {
//    var id : String? = ""
    var page : Int
    var status: String?
}

struct StoreScheduleShowRequest: Encodable {
    var show_id : String?
    var title: String
    var date: String
    var time: String
    var category_id: String
    var auction_type_id: String
    var product_ids: String
//    var thumbnail : String
//    var isHazardiousMaterial: Bool
    var is_explicit: Bool
    var show_discoverability: String
    var repeat_value: String
    var is_repeat : Bool
    var language : String
    var thumbnail : String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case date
        case time
        case category_id
        case auction_type_id
        case product_ids = "product_ids[]"
//        case thumbnail = "thumbnail[]"
    }
}

struct ProductRequest : Encodable {
    var user_id: String?
    var search: String?
    var category_ids: String?
    var conditions: String?
    var min_price: String?
    var max_price: String?
    var status: String? //active,inactive, draft
    var marketplace: String? //true, false
    var page: Int
    var type: String? //live,flash_sale,reserve_for_live
    var sale_type: String? //buy_now, auction,accept_offers
    var sort_by: String? //title_asc, title_desc, newest, oldest, price_low_high, price_high_low
    var format: String? //asc, desc
}

struct GetLiveShowsRequest : Encodable{
    var type : String? = ""
    var category : String? = ""
    var search : String? = ""
    var page : String
}

struct LiveShowUpdateRequest : Encodable {
    var schedule_show_id : String
    var is_live : String
}

struct ItemListRequest : Encodable {
    var type : String
    var page : Int
}


struct FundTransferRequest : Encodable {
    var amount : Int
}

struct getShowRequest : Encodable {
    var show_id : Int
}


struct UpdateProfileRequest : Encodable {
    var first_name  : String
    var last_name : String
    var username  : String
    var bio : String
}

struct countRequest : Encodable {
    var room_id : String
    var event : String
}

struct StorePromoteShowRequest: Codable {
    var scheduleShowId: String
    var promoteShowId: String
    
    // Coding keys to map the properties to different JSON keys
    enum CodingKeys: String, CodingKey {
        case scheduleShowId = "schedule_show_id"
        case promoteShowId = "promote_show_id"
    }
}

struct StoreBidRequest : Encodable{
    var schedule_show_id : String
    var user_id : String
    var product_id : String
    var bid_price : String
}

struct PageRequest : Encodable{
    var page : Int
}

struct sellerVerification {
    var phone_verification : Int?
    var cardToken : Int?
}



struct CardDefaultRequest : Encodable {
    var card_id : String
}

struct CategoryRequest  : Encodable {
    var category_id : String?
    var type : String?
    var search : String?
    var get_count: Bool = true
}

struct DeleteShippingProfileRequest  : Encodable {
    var shipping_profile_id: Int
}


struct StoreShippingRequest  : Encodable {
    var name: String
    var size: String
    var weight: String
    var maxItems: Bool
    var additionalWeight: Bool
    var shipping_profile_id: Int?
}

struct ShowOverviewRequest  : Encodable {
    var show_id: String
}



struct SubCategoryRequest  : Encodable {
    var category_ids : [Int]?
}

struct FavCategoryRequest  : Encodable {
    var category_ids : [Int]?
    var sub_category_ids : [Int]?
}


struct SendChatNotification : Encodable{
    var receiver_id : Int
    var message  : String
}

struct ImageUploadRequest : Encodable {
    var images : String
    
    enum CodingKeys: String, CodingKey {
        case images = "images[]"
    }
}


struct DeleteProduct : Encodable{
    var product_id : Int
}


struct BlockUserRequest : Encodable{
    var blocked_id : Int
}

struct BlockUserList : Encodable{
    var blocked_by : Bool?
}

struct TipAmountRequest : Encodable{
    var seller_id : String
    var amount: String
    var card_number: String
}

struct SellerAnalyticsRequest : Encodable{
    var filter : String?
    var start_date: String?
    var end_date: String?
}

struct ExportDetailsRequest : Encodable{
    var filter : String?
    var start_date: String?
    var end_date: String?
    var type: String?
}

struct SalesPerformanceRequest : Encodable{
    var filter : String
    var year: String
    var month: String?
}

struct VisitorsAnalyticsRequest : Encodable{
    var filter : String
    var year: String
    var month: String?
}

struct AgoraTokenRequest : Encodable{
    var channelName : String
    var uid: Int
}

